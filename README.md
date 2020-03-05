docker-moodle [![Build Status](https://travis-ci.org/ellakcy/docker-moodle.svg?branch=master)](https://travis-ci.org/ellakcy/docker-moodle)
=============

A Docker image that installs and runs the latest Moodle stable, with external MySQL, Mariadb or Postgresql Database and automated installation with a default predefined administrator user. Also all the images are availalbe via [docker hub](https://hub.docker.com/r/ellakcy/moodle/).

## Buidling

Buidling the required images using this repo is a liitle laborious and the whole process is described in the `CONTRIBUTING.md` file.

## Available Images

With apache based on `php:7.2-apache` image:

VERSION | mysql or mariadb | postgresql | all databases (mysql, mariadb, postgresql)
--- | --- | --- | ---
3.5 | `ellakcy/moodle:mysql_maria_apache_35` `ellakcy/moodle:mysql_maria_apache_lts`  | `ellakcy/moodle:postgresql__apache_35` `ellakcy/moodle:postgresql_apache_lts` |  `ellakcy/moodle:multibase_apache_35` `ellakcy/moodle:multibase_apache_lts` 
3.6 | `ellakcy/moodle:mysql_maria_apache_36` | `ellakcy/moodle:postgresql_apache_36` | `ellakcy/moodle:multibase_apache_36`
3.7 | `ellakcy/moodle:mysql_maria_apache_37` | `ellakcy/moodle:postgresql_apache_37` | `ellakcy/moodle:multibase_apache_37`
3.8 | `ellakcy/moodle:mysql_maria_apache_38` `ellakcy/moodle:mysql_maria_apache_latest` `ellakcy/moodle:mysql_maria_apache`  | `ellakcy/moodle:postgresql__apache_38` `ellakcy/moodle:postgresql_apache_latest` `ellakcy/moodle:postgresql_apache` |  `ellakcy/moodle:multibase_apache_38` `ellakcy/moodle:multibase_apache_latest`  `ellakcy/moodle:multibase_apache` `ellakcy/moodle:latest`

With fpm based on `php:7.2-fpm-alpine` image:

VERSION | mysql or mariadb | postgresql | all databases
--- | --- | --- | ---
3.5 | `ellakcy/moodle:mysql_maria_apache_35` `ellakcy/moodle:mysql_maria_apache_lts`  | `ellakcy/moodle:postgresql__apache_35` `ellakcy/moodle:postgresql_apache_lts` |  `ellakcy/moodle:multibase_apache_35` `ellakcy/moodle:multibase_apache_lts` 
3.6 | `ellakcy/moodle:mysql_maria_apache_36` | `ellakcy/moodle:postgresql_apache_36` | `ellakcy/moodle:multibase_apache_36`
3.7 | `ellakcy/moodle:mysql_maria_apache_37` | `ellakcy/moodle:postgresql_apache_37` | `ellakcy/moodle:multibase_apache_37`
3.8 | `ellakcy/moodle:mysql_maria_apache_38` `ellakcy/moodle:mysql_maria_apache_latest` `ellakcy/moodle:mysql_maria_apache`  | `ellakcy/moodle:postgresql__apache_38` `ellakcy/moodle:postgresql_fpm_alpine_latest` `ellakcy/moodle:postgresql_apache` |  `ellakcy/moodle:multibase_apache_38` `ellakcy/moodle:multibase_fpm_alpine_latest`  `ellakcy/moodle:multibase_fpm_alpine_latest`

The following images are not maintained any more, though there are still archived for historical reasons and available in docker hub:

* `ellakcy/moodle:apache_base` : A base image over apache, where you just can base your own moodle image for the database you want.
* `ellakcy/moodle:mysql_maria_apache`: An image where provides moodle installation supporting mysql or mariadb.
* `ellakcy/moodle:postgresql_apache`:  An image where provides moodle installation supporting postgresql.
* `ellakcy/moodle:alpine_fpm_base`: A base image over alpine and fpm, where you just can base your own moodle image for the database you want.
* `ellakcy/moodle:mysql_maria_fpm_alpine`: An alpine-based image using fpm supporting mysql and mariadb.
* `ellakcy/moodle:postgresql_fpm_alpine`: An alpine-based image using fpm supporting postgresql.


## Run

> We also developed a [docker-compose](https://github.com/ellakcy/moodle-compose) solution.
> We strongly reccomend using this one.

### Running images manually

#### Apache based solutions

To spawn a new instance of Moodle:

* ... using MySQL:

  ```
  docker run -d --name DB -e MYSQL_DATABASE=moodle -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_ONETIME_PASSWORD=yes -e MYSQL_USER=^a database user^ -e MYSQL_PASSWORD=^a database password^ mysql:5.7
  docker run -d -P --name moodle --link DB:DB -e MOODLE_DB_HOST=DB -e MOODLE_URL=http://0.0.0.0:8080 -p 8080:80 ellakcy/moodle:mysql_maria_apache_^VERSION^
  ```
  > ** NOTICE **
  > For now due to the way that mysql authenticates its users, is working with vesrsion 5.7 version of mysql and **earlier**

* ... using MariaDB:

  ```
  docker run -d --name DB -e MYSQL_DATABASE=^a database name^ -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_ONETIME_PASSWORD=yes -e MYSQL_USER=^a database user^ -e MYSQL_PASSWORD=^a database password^ mariadb:10.2
  docker run -d -P --name moodle --link DB:DB -e MOODLE_DB_HOST=DB -e MOODLE_URL=http://0.0.0.0:8080 -e MOODLE_DB_TYPE="mariadb" -p 8080:80 ellakcy/moodle:mysql_maria_apache_^VERSION^
  ```
  > ** NOTICE **
  > Please use Mariadb 10.2 and **earlier** for the same reasons as mysql one.

* ... using PostgreSQL:

  ```
  docker run --name=DB -e POSTGRES_USER=^a database user^ -e POSTGRES_PASSWORD=^a database password^ -e POSTGRES_DB=^a database name^ -d postgres
  docker run -d -P --name moodle --link DB:DB -e MOODLE_DB_HOST=DB -e MOODLE_URL=http://0.0.0.0:8080 -e MOODLE_DB_TYPE="pgsql" -p 8080:80 ellakcy/moodle:postgresql_apache_^VERSION^
  ```

Then you can visit the following URL in a browser to get started:

```
http://0.0.0.0:8080

```

> NOTICE: In case you need to keep the data persisted use volumes both in database and moodle containers.
> NOTICE 2: `^VERSION` indicates the moodle version. For the latest lts just use `lts` or ofor the latest non lts use `latest` 


##### Alpine with Fpm based solutions

For fpm solutions is recomended to use docker-compose. For **production** use is reccomended the to use the repo https://github.com/ellakcy/moodle-compose .

## Enviromental variables

Also you can use the following extra enviromental variables (using `-e` option on `docker run` command):

### Enviromental Variables for Default user settings:

A default user is generated during installation. Please provide different credentials during installation.

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_URL` | http://0.0.0.0 | The URL the site will be served from
`MOODLE_ADMIN` | *admin* | The default administrator's username
`MOODLE_ADMIN_PASSWORD` | *Admin~1234* | The default administrator's password - **CHANGE IN PRODUCTION*
`MOODLE_ADMIN_EMAIL` | *admin@example.com* | The default dministrator's email

### Enviromental Variables for Database settings:

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_DB_HOST` | | The url that the database is accessible
`MOODLE_DB_PASSWORD` | | The password for the database
`MOODLE_DB_USER` | | The username of the database
`MOODLE_DB_NAME` | | The database name
`MOODLE_DB_PORT` | | The port that the database is accessible

### Enviromental Variables for Email settings

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_EMAIL_TYPE_QMAIL` | false | Whether will use qmail as email (MTA)[https://en.wikipedia.org/wiki/Message_transfer_agent].
`MOODLE_EMAIL_HOST` | | The host of the smtp server. If not provided then it won't send emails.

### Enviromental Variables for reverse proxy

Variable Name | Default value | Description
---- | ------ | ------
`MOODLE_REVERSE_LB` | false | Whether the moodle rins behind a load balancer or not.
`MOODLE_SSL` | false | Whether the moodle runs behind an ssl-enabled load balancer.

### Volumes

For now you can use the following volumes:

* **/var/moodledata** In order to get all the stored  data.
* **/var/www/html** Containing the moodle source code. This is used by nginx as well.

## Using SSL Reverse proxy

### Via nginx

In case you want to use the nginx as reverse http proxy is recommended to provide the following settings:

```
server {
  listen  449 ssl;
  server_name  ^your_domain^;

  ssl_certificate     ^path_to_cert^;
  ssl_certificate_key ^path_to_key^;
  ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers         HIGH:!aNULL:!MD5;

  location / {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # In case or running another port please replace the value bellow.
        proxy_pass http://^local_url_and_port^;
  }
}
```

Where:
* `^your_domain^`: The domain that the moodle is available. Keep in mind that this value is the same in the `MOODLE_URL` enviromental variable.
* `^local_url_and_port^`: Url that the reverse proxy will forward the requests.
* `^path_to_cert^`,`^path_to_key^`: The certificate and its key.

As you can see the reverse proxy **DOES NOT** provide the http **Host** header according to [this](https://moodle.org/mod/forum/discuss.php?d=339370) issue.

Also keep in mind to set the following docker enviromental variables `MOODLE_REVERSE_LB` and `MOODLE_SSL` into **true** as well.



## Caveats

### Moodle related

The following aren't handled, considered, or need work:
* moodle cronjob (should be called from cron container)
* log handling (stdout?)
* email (does it even send?)

### Docker related

Also in case of an error that mentions:

```
UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=60)
```

Export the following enviromental variables:

```
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
```

## Credits

This is a fork of [jmhardison/docker-moodle](https://github.com/jmhardison/docker-moodle).
