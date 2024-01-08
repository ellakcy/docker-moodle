#!/bin/bash

# Even though some containers may not have some support for a specific db
# We provide a generic entrypoint for better maintainance

# Ping Database function
function pingdb {
    OK=0
    for i in $(seq 1 100); do
      echo "Pinging database attempt ${count} into ${MOODLE_DB_HOST}:${MOODLE_DB_PORT}" 
      if  $(php -r "is_resource(@fsockopen(\"${MOODLE_DB_HOST}\",intval(\"${MOODLE_DB_PORT}\")))?exit(0):exit(1);") ; then
        echo "Can connect into database"
        OK=1
        break
      fi
      sleep 5
    done


    if [ $OK -eq 1 ]; then
      echo "Database type: "${MOODLE_DB_TYPE}
      echo "DB Type: "${MOODLE_DB_TYPE}
    else
      echo >&2 "Can't connect into database"
      exit 1
    fi
}

# Ι use heredoc in order to save space in my docker image by removing a dedicated layer for it.
cat << 'DETECT_MARIA' > /opt/detect_mariadb.php
<?php
/**
* @param string $host The database host
* @param string | int $port The database port
* @param string $database The database itself
* @return string
*/
function gererateDbConnectionString($host,$port,$database) {
  $connectionString="mysql:host=$host;dbname=$database;port=$port";
  return $connectionString;
}

/**
* @param PDO $pdo
* @return String
*/
function detectMysqlOrMariaDb(PDO $pdo){
  $version=$pdo->query('select version()')->fetchColumn();
  if(preg_match("/^(\d*\.?)*-MariaDB-.*$/",$version)){
    return 'mariadb';
  } else {
    return 'mysqli';
  }
}

/**
* Connection info
*/
$host=getenv('MOODLE_DB_HOST');
$port=getenv('MOODLE_DB_PORT');
$database=getenv('MOODLE_DB_NAME');
$username=getenv('MOODLE_DB_USER');
$password=getenv('MOODLE_DB_PASSWORD');

try {
  $connectionString=gererateDbConnectionString($host,$port,$database);
  $pdo=new PDO($connectionString,$username,$password);
  echo detectMysqlOrMariaDb($pdo);
  exit(0);
} catch (PDOExcetion $e) {
  file_put_contents('php://stderr',$e->getMessage(),FILE_APPEND);
  exit(1);
}
DETECT_MARIA


echo "Moving files into web folder"
rsync -rvad --chown www-data:www-data /usr/src/moodle/* /var/www/html/

echo "Fixing files and permissions"
chown -R www-data:www-data /var/www/html
find /var/www/html -iname "*.php" | xargs chmod 655

echo "placeholder" > /var/moodledata/placeholder
chown -R www-data:www-data /var/moodledata
chmod 777 /var/moodledata

HAS_MySQL_SUPPORT=$(php -m | grep -i mysql | grep -v "mysqlnd" | wc -w)
HAS_POSTGRES_SUPPORT=$(php -m | grep -i pgsql |wc -w)

if [ -f "/etc/db_type" ]; then
  MOODLE_DB_TYPE=$(cat /etc/db_type)
fi

echo "Installing moodle with ${MOODLE_DB_TYPE} support"

if [ "${MOODLE_DB_TYPE}" == "mysql" ]; then
  MOODLE_DB_TYPE="mysqli"
fi

if [ $HAS_MySQL_SUPPORT -gt 0 ] && [ "${MOODLE_DB_TYPE}" = "mysqli" ]; then

  echo "Trying for mysql database"

  : ${MOODLE_DB_HOST:="moodle_db"}
  : ${MOODLE_DB_PORT:=3306}

    echo "Setting up the database connection info"
  : ${MOODLE_DB_USER:=${DB_ENV_MYSQL_USER:-root}}
  : ${MOODLE_DB_NAME:=${DB_ENV_MYSQL_DATABASE:-'moodle'}}

  if [ "$MOODLE_DB_USER" = 'root' ]; then
    : ${MOODLE_DB_PASSWORD:=$DB_ENV_MYSQL_ROOT_PASSWORD}
  else
    : ${MOODLE_DB_PASSWORD:=$DB_ENV_MYSQL_PASSWORD}
  fi

  pingdb
  MOODLE_DB_TYPE=$(php /opt/detect_mariadb.php)
  echo ${MOODLE_DB_TYPE}
  if [ "${MOODLE_DB_TYPE}" = "mysqli" ]; then
    sed -e "s/trim(getenv('MOODLE_DB_TYPE'))/'mysqli'/" /usr/src/moodle/config.php > /var/www/html/config.php
  elif [ "${MOODLE_DB_TYPE}" = "mariadb" ]; then
    sed -e "s/trim(getenv('MOODLE_DB_TYPE'))/'mariadb'/" /usr/src/moodle/config.php > /var/www/html/config.php
  fi

elif [ $HAS_MySQL_SUPPORT -gt 0 ] && [ "${MOODLE_DB_TYPE}" = "mariadb" ]; then

  echo "Trying for mariadb database"

  : ${MOODLE_DB_HOST:="moodle_db"}
  : ${MOODLE_DB_PORT:=3306}

    echo "Setting up the database connection info"
  : ${MOODLE_DB_USER:=${DB_ENV_MYSQL_USER:-root}}
  : ${MOODLE_DB_NAME:=${DB_ENV_MYSQL_DATABASE:-'moodle'}}

  if [ "$MOODLE_DB_USER" = 'root' ]; then
    : ${MOODLE_DB_PASSWORD:=$DB_ENV_MYSQL_ROOT_PASSWORD}
  else
    : ${MOODLE_DB_PASSWORD:=$DB_ENV_MYSQL_PASSWORD}
  fi

  pingdb
  sed -e "s/trim(getenv('MOODLE_DB_TYPE'))/'mariadb'/" /usr/src/moodle/config.php > /var/www/html/config.php

elif [ $HAS_POSTGRES_SUPPORT -gt 0 ] && [ "$MOODLE_DB_TYPE" = "pgsql" ]; then

  MOODLE_DB_TYPE="pgsql"

  : ${MOODLE_DB_HOST:="moodle_db"}
  : ${MOODLE_DB_PORT:=5432}

    echo "Setting up the database connection info"

  : ${MOODLE_DB_NAME:=${DB_ENV_POSTGRES_DB:-'moodle'}}
  : ${MOODLE_DB_USER:=${DB_ENV_POSTGRES_USER}}
  : ${MOODLE_DB_PASSWORD:=$DB_ENV_POSTGRES_PASSWORD}

  pingdb
  sed -e "s/trim(getenv('MOODLE_DB_TYPE'))/'pgsql'/" /usr/src/moodle/config.php > /var/www/html/config.php
  sleep 5
else
  echo >&2 "No database support found"
  exit 1
fi


if [ -z "$MOODLE_DB_PASSWORD" ]; then
  echo >&2 'error: missing required MOODLE_DB_PASSWORD environment variable'
  echo >&2 '  Did you forget to -e MOODLE_DB_PASSWORD=... ?'
  echo >&2
  exit 1
fi

echo "Configuring driver"
chown www-data:www-data /var/www/html/config.php

echo "Installing moodle"
php /var/www/html/admin/cli/install_database.php \
          --adminemail=${MOODLE_ADMIN_EMAIL} \
          --adminuser=${MOODLE_ADMIN} \
          --adminpass=${MOODLE_ADMIN_PASSWORD} \
          --agree-license

php admin/cli/purge_caches.php

exec "$@"
