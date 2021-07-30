#!/bin/bash

# The script required the Following Environmental Variables:
# DB_TYPE in order to specify the database type
# VERSION in order to specify the moodle version

DOCKERFILE_ALPINE_FPM="dockerfiles/fpm_alpine/Dockerfile"

SERVER_FAVOR="apache"

DOCKERFILE=${1}


case $DOCKERFILE in
    "dockerfiles/fpm_alpine/Dockerfile") SERVER_FAVOR="fpm_alpine";;
    "dockerfiles/fpm/Dockerfile") SERVER_FAVOR="fpm";;
    *)  SERVER_FAVOR="apache";;
esac

DB_FLAVOR=""

case $DB_TYPE in
    "mysqli" ) DB_FLAVOR="mysql_maria" ;;
    "pgsql" ) DB_FLAVOR="postgresql";;
    *) DB_FLAVOR="mulitibase"
esac

TAGS=("${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}")

if [[ $VERSION == $LATEST_LTS ]]; then
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_lts")
fi

if [[ $VERSION == $LATEST ]]; then
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_latest")
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}")
    if [[ $SERVER_FAVOR == "apache" ]] && [[ $DB_FLAVOR = "mulitbase" ]]; then
        TAGS+=("latest")
    fi
fi

PARAMS=${TAGS[@]/#/"-t ellakcy/moodle:"}

echo "Running:" 
echo "docker build --build-arg DB_TYPE=${DB_FLAVOR} -f ${DOCKERFILE} ${PARAMS} --force-rm . "
docker build --build-arg DB_TYPE=${DB_FLAVOR} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${PARAMS} --force-rm .

BRANCH=${GITHUB_REF##*/}

if [[ $BRANCH == 'master' ]]; then
    for tag in "${TAGS[@]}"; do
        docker image push ellakcy/moodle:$tag
    done

fi