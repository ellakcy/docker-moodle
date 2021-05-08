#!/bin/bash

cat << 'DETECT_MARIA' > detect_mariadb.php
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