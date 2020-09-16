#!/bin/bash


if [ $VERSION != $LATEST_LTS ]; then
    echo "Version is not the latest exiting"
    exit 0;
fi


git clone https://github.com/ellakcy/moodle-compose.git ./moodle-compose

cp ./travis/.env_testing_compose ./moodle-compose/.env
cd moodle-compose

FLAVOR=""
case $DOCKERFILE
    'dockerfiles/fpm_alpine/Dockerfile') FLAVOR='alpine_fpm';;
    'dockerfiles/apache/Dockerfile') FLAVOR='apache';;
esac

DB_FLAVOR=''
case $DB_TYPE
    'mysqli')  DB_FLAVOR='mysql';;
    'postgresql') DB_FLAVOR='postgresql';;
esac

cd ./moodle-compose

ln -s docker-compose_${DB_TYPE}_${FLAVOR} docker-compose.yml

docker-compose up -d

sleep 3

# Test that files are rsynced
moved_files=$(docker-compose logs | grep "/var/www/html/" | wc -m)

if [ $moved_files -le 0 ]; then
    >&2 echo "Files are not rsynced with the /var/www/html"
    exit 1
fi;

# Test that installation is performed

sleep 2;

# Test that I can visit 0.0.0.0:8082
curl 