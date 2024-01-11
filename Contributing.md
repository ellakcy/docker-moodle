# Notes for Contributors
First of all thank you for providing a helping hand into out efforts.

## Builging image:

It is recomended to use the vagrant vm. In order to get access run:

```
vagrant up
vagrant ssh
```
The cd into `~/code` project. Afterwards you need to export the following env variables:

Variable | Required to export | Dev Only | desc
--- | --- | ---
VERSION | YES | NO | The moodle version without dots eg for moodle `4.3` use `403`
PHP_VERSION | NO | NO | For the PHP version to use eg use `8.0` for php 8
DRY_RUN | NO | YES | If set as 1 will not build the docker images it will just print the build arguments
CACHE_ENABLE | NO | YES | If set 1 it builds the docker images without --no-cache


Then you must run the following script:

```
bash .github/build_docker.sh
```

The script can receive the following values as argument:

1. `dockerfiles/fpm_alpine/Dockerfile` for alpine fpm images
2. `dockerfiles/fpm/Dockerfile` for debian fpm images
3. `dockerfiles/apache/Dockerfile` for apache httpd based images running on debian

If no argument the `dockerfiles/apache/Dockerfile` is assumed.

## HTTP timeout
In case of an arror that mentions:

```
UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=60)
```

Export the following enviromental variables:

```
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
```

## Testing built images

### Running tool

At `./test_tool` folder exists a utility tool that generates docker-compose image in `./docker-compose` folders. In order to run you must launch Vagrant vm then ssh into it:

```
vagrant up
vagrant ssh
```

Then you must visit the `./code/test_tool` and run:

```
python3 main.py ^image_name^
```

That will create a distince docker-compose in its own folder. In prder to launch it run:

```
cd ~/code/docker-compose/^image_name^
docker-compose up -d
```

The `^image_name^` is the built tag via `.github/build_docker.sh` script.

### Db versions

The tool used by default the `latest` version of each of the following databases:

1. mysql
2. mariadb
3. Postgresql