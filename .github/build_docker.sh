#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "${BASH_SOURCE}")
# Absolute path this script is in, thus /home/user/bin
BASEDIR=$(dirname ${SCRIPT})

source ${BASEDIR}/config.sh

DOCKERFILE_ALPINE_FPM="dockerfiles/fpm_alpine/Dockerfile"

SERVER_FAVOR="apache"

DOCKERFILE=${1}


case $DOCKERFILE in
    "dockerfiles/fpm_alpine/Dockerfile") SERVER_FAVOR="fpm_alpine";;
    "dockerfiles/fpm/Dockerfile") SERVER_FAVOR="fpm";;
    *)  SERVER_FAVOR="apache";;
esac

DB_FLAVOR=""
BUILD_NUMBER=$(date +"%Y%m%d%H%M")

case $DB_TYPE in
    "mysqli" ) DB_FLAVOR="mysql_maria" ;;
    "pgsql" ) DB_FLAVOR="postgresql";;
    *) DB_FLAVOR="mulitibase"
esac

TAGS=("${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}")
TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}_${BUILD_NUMBER}")
if [[ $VERSION == $LATEST_LTS ]]; then
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_lts")
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_lts_${BUILD_NUMBER}")
fi

if [[ $VERSION == $LATEST ]]; then
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_latest")
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_latest_${BUILD_NUMBER}")
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}")
    TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_${BUILD_NUMBER}")
    if [[ $SERVER_FAVOR == "apache" ]] && [[ $DB_FLAVOR = "mulitbase" ]]; then
        TAGS+=("latest")
        TAGS+=("latest_${BUILD_NUMBER}")
    fi
fi

PARAMS=${TAGS[@]/#/"-t ellakcy/moodle:"}

echo "Running:" 
echo "docker build --build-arg DB_TYPE=${DB_TYPE} -f ${DOCKERFILE} ${PARAMS} --force-rm . "
docker build --build-arg DB_TYPE=${DB_TYPE} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${PARAMS} --force-rm --no-cache .

BRANCH=${GITHUB_REF##*/}

if [[ $BRANCH == 'master' ]]; then
    for tag in "${TAGS[@]}"; do
        docker image push ellakcy/moodle:$tag
    done

fi