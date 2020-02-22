#!/bin/bash

DOCKERFILE_ALPINE_FPM="dockerfiles/fpm_alpine/Dockerfile"

SERVER_FAVOR="apache"

if [[ $DOCKERFILE == $DOCKERFILE_ALPINE_FPM ]]; then
    SERVER_FAVOR="fpm_alpine"
fi

DB_FLAVOR=""
case $DB_TYPE in
    "mysqli" ) DB_FLAVOR="mysql_maria" ;;
    "pgsql" ) DB_FLAVOR="postgresql" ;;
    *) DB_FLAVOR="mulitbase"
esac

VERSION_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}"

VERSION_TYPE_TAG=""

case $VERSION in
    "${LATEST_LTS}" ) VERSION_TYPE_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_lts" ;;
    "${LATEST}" ) VERSION_TYPE_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_latest" 
    if [[ $SERVER_FAVOR == "apache" ]]; then
        VERSION_TYPE_TAG=" ${VERSION_TYPE_TAG} -t  ellakcy/moodle:latest"
    fi;;
esac 


docker build -f ${DOCKERFILE} ${VERSION_TYPE_TAG} ${VERSION_TAG} --no-cache --force-rm .