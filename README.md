docker-moodle
=============

A Docker image that installs and runs the latest Moodle stable, with external MySQL, Mariadb or Postgresql Database and automated installation with a default predefined administrator user. Also all the images are availalbe via [docker hub](https://hub.docker.com/r/ellakcy/moodle/).

## Buidling

Buidling the required images using this repo is a liitle laborious and the whole process is described in the `CONTRIBUTING.md` file.

## Available Images

All available images are listed in: https://hub.docker.com/r/ellakcy/moodle/tags?page=1&ordering=-name

Each flavor is seperates by database support, version and either if is it based on apache, or alpine via fpm.
To be more specific:

Image naming Pattern | PHP execution type | Mysql Support | Mariadb Support | Postgresql Support
 --- | --- | --- | --- | --- 
 `mulitbase_apache_^VERSION^` | apache  | YES | YES | YES 
 `mysql_maria_apache_^VERSION^` | apache | YES | YES | NO 
 `postgresql_apache_^VERSION^` | apache  | NO | NO | YES 
 `mulitbase_alpine_fpm_^VERSION^` | fpm (running on alpine linux) | YES | YES | YES 
 `mysql_maria_alpine_fpm_^VERSION^` | fpm (running on alpine linux) | YES | YES | NO 
 `postgresql_alpine_fpm_^VERSION^` | fpm (running on alpine linux)  | NO | NO | YES 
 `mulitbase_fpm_^VERSION^`   | fpm | YES | YES | YES 
 `mysql_maria_fpm_^VERSION^` | fpm | YES | YES | NO 
 `postgresql_fpm_^VERSION^`  | fpm  | NO | NO | YES 


The `^VERSION^` is a 2-3 digit number the first digit follows the major version and the rest of them follow the minor version. For example the `mulitbase_apache_39` runs the moodle 3.9 whilst `mulitbase_apache_310` runs the moodle 3.10 .

Also for the latest moodle version we also ship the following images:

Image | PHP execution type | Mysql Support | Mariadb Support | Postgresql Support
 --- | --- | --- | --- | --- 
`latest` | apache  | YES | YES | YES
 `mulitbase_apache_latest` | apache  | YES | YES | YES 
 `mysql_maria_apache_latest` | apache | YES | YES | NO 
 `postgresql_apache_latest` | apache  | NO | NO | YES 
 `mulitbase_alpine_fpm_latest` | fpm (running on alpine linux) | YES | YES | YES 
 `mysql_maria_alpine_fpm_latest` | fpm (running on alpine linux) | YES | YES | NO 
 `postgresql_alpine_fpm_latest` | fpm (running on alpine linux)  | NO | NO | YES 
 `mulitbase_fpm_latest` | fpm | YES | YES | YES 
 `mysql_maria_fpm_latest` | fpm | YES | YES | NO 
 `postgresql_fpm_latest` | fpm  | NO | NO | YES 

Whilst for the most recent moodle lts we ship:

Image | PHP execution type | Mysql Support | Mariadb Support | Postgresql Support
 --- | --- | --- | --- | --- 
 `mulitbase_apache_lts` | apache  | YES | YES | YES 
 `mysql_maria_apache_lts` | apache | YES | YES | NO 
 `postgresql_apache_lts` | apache  | NO | NO | YES 
 `mulitbase_alpine_fpm_lts` | fpm (running on alpine linux) | YES | YES | YES 
 `mysql_maria_alpine_fpm_lts` | fpm (running on alpine linux) | YES | YES | NO 
 `postgresql_alpine_fpm_lts` | fpm (running on alpine linux)  | NO | NO | YES 
 `mulitbase_fpm_lts` | fpm | YES | YES | YES 
 `mysql_maria_fpm_lts` | fpm | YES | YES | NO 
 `postgresql_fpm_lts` | fpm | NO | NO | YES 

All images are shipped with php **8.0**.

## Specific PHP version

> For greater stability and unexpected interruptions we reccomend to use the approach locking moodle and php version.

Default php is 8.0 whereas images with php 7.4 and 8.1 are shipped as well:

Image naming Pattern | PHP execution type | Mysql Support | Mariadb Support | Postgresql Support
 --- | --- | --- | --- | --- 
 `mulitbase_apache_php^PHP_VERSION^_^MOODLE_VERSION^` | apache  | YES | YES | YES 
 `mysql_maria_apache_php^PHP_VERSION^_^MOODLE_VERSION^` | apache | YES | YES | NO 
 `postgresql_apache_php^PHP_VERSION^_^MOODLE_VERSION^` | apache  | NO | NO | YES 
 `mulitbase_alpine_fpm_php^PHP_VERSION^_^MOODLE_VERSION^` | fpm (running on alpine linux) | YES | YES | YES 
 `mysql_maria_alpine_fpm_php^PHP_VERSION^_^MOODLE_VERSION^` | fpm (running on alpine linux) | YES | YES | NO 
 `postgresql_alpine_fpm_php^PHP_VERSION^_^MOODLE_VERSION^` | fpm (running on alpine linux)  | NO | NO | YES 
 `mulitbase_fpm_php^PHP_VERSION^_^MOODLE_VERSION^`   | fpm | YES | YES | YES 
 `mysql_maria_fpm_php^PHP_VERSION^_^MOODLE_VERSION^` | fpm | YES | YES | NO 
 `postgresql_fpm_php^PHP_VERSION^_^MOODLE_VERSION^`  | fpm  | NO | NO | YES 

Replace the `^PHP_VERSION^` the follwoig bellow .
The current php versions are:

* `8.1`
* `8.0`
* `7.4`

Whereas the build moodle versions are:
* `311`
* `400`
* `401`
* `402`
* `403`

## Unsupported moodle versions

All moodle versions **bellow** `3.11` are not build and supported via out solution. 

## Supported Database Versions:
The database support is described into moodles documentation depending the moodle version. The installer will point you to appropriate version if you follow these steps:

#### **STEP 1**

Create a docker-compose.yml with a db version mentioned upon https://moodledev.io/docs/4.3/gettingstarted/requirements

#### **STEP 2**: 

Run it locally and look at container's log (via `docker log` command). At invorrect version the installer (via entrypoint script) will point an error similar to:

```
== Environment ==
!! database mariadb (10.2.44-MariaDB-1:10.2.44+maria~bionic) !!
[System] version 10.6.7 is required and you are running 10.2.44 - 
```

In order to retrieve the logs follow these commands:
```
# create docker-compose
cd ./folder_where_docker-compose_is
docker-compose up -d
docker ps --filter ancestor=ellakcy/moodle
# Then copy the container id and run
docker logs -f ^container_id^
```

Also at `docker ps` command above we can also use a specific tag as well for example:

```
docker ps --filter ancestor=ellakcy/moodle:multibase_apache_403
```


## Build Cycle and build versions

We aim to deliver freshly images on weekly basis. Each build image is tagged with the build date in a format `_YmdHi`, without build date is the latest build, for example the image `mysql_maria_apache_latest` is the latest built image whilst `mysql_maria_apache_latest_202108112012` is the image built at `2021-08-11 20:12`. At docker hub you can look at [tags](https://hub.docker.com/r/ellakcy/moodle/tags) section for the latest or older builds.

## Run
> We also strongly recomend to create a docker-compose.yml and run using docker-compose in case that our solution mentioned above, does not fit your needs. The moodle-compose ( https://github.com/ellakcy/moodle-compose ) we developped is no longer supported 

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
> NOTICE 2: `^VERSION` indicates the moodle version. For the latest lts just use `lts` or for the latest non lts use `latest` 
> Notice 3: In case your moodle installation is shipped via 

#### Alpine with Fpm based solutions

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
