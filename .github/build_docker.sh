#!/bin/bash

# The script required the Following Environmental Variables:
# DB_TYPE in order to specify the database type
# VERSION in order to specify the moodle version

DOCKERFILE_ALPINE_FPM="dockerfiles/fpm_alpine/Dockerfile"

SERVER_FAVOR="apache"

DOCKERFILE=${1}

echo "Building $DOCKERFILE VERSION $VERSION FLAVOR $DB_TYPE " 

# if [[ $DOCKERFILE == $DOCKERFILE_ALPINE_FPM ]]; then
#     SERVER_FAVOR="fpm_alpine"
# fi

case DOCKERFILE in
    "dockerfiles/fpm_alpine/Dockerfile") SERVER_FAVOR="fpm_alpine";;
    "dockerfiles/fpm/Dockerfile") SERVER_FAVOR="fpm";;
    *)  SERVER_FAVOR="apache";;
esac

DB_FLAVOR=""

case $DB_TYPE in
    "mysqli" ) DB_FLAVOR="mysql_maria" ;;
    "pgsql" ) DB_FLAVOR="postgresql";;
    *) DB_FLAVOR="mulitbase"
esac

VERSION_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}"

VERSION_TYPE_TAG=""

if [[ $VERSION == $LATEST_LTS ]]; then
    VERSION_TYPE_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_lts"
fi

if [[ $VERSION == $LATEST ]]; then
    VERSION_TYPE_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_latest -t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}" 
    if [[ $SERVER_FAVOR == "apache" ]] && [[ $DB_FLAVOR = "mulitbase" ]]; then
        VERSION_TYPE_TAG=" ${VERSION_TYPE_TAG} -t  ellakcy/moodle:latest"
    fi
fi

echo "Running:" 
echo "docker build --build-arg DB_TYPE=${DB_TYPE} -f ${DOCKERFILE} ${VERSION_TYPE_TAG} ${VERSION_TAG} --force-rm . "
docker build --build-arg DB_TYPE=${DB_TYPE} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${VERSION_TYPE_TAG} ${VERSION_TAG} --force-rm .

BRANCH=${GITHUB_REF##*/}

if [[ $BRANCH == 'master' ]]; then
    docker image push --all-tags ellakcy/moodle
fi