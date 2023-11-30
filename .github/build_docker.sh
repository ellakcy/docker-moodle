#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "${BASH_SOURCE}")
# Absolute path this script is in, thus /home/user/bin
BASEDIR=$(dirname ${SCRIPT})

source ${BASEDIR}/config.sh

PHP_VERSION=${PHP_VERSION:=${DEFAULT_PHP}}

if [ "$PHP_VERSION" == "${DEFAULT_PHP}" ]; then
    echo "$PHP_VERSION is same to ${DEFAULT_PHP}"
fi

DOCKERFILE_ALPINE_FPM="dockerfiles/fpm_alpine/Dockerfile"
SERVER_FAVOR="apache"

DOCKERFILE=${1}

case $DOCKERFILE in
    "dockerfiles/fpm_alpine/Dockerfile") SERVER_FAVOR="fpm_alpine";;
    "dockerfiles/fpm/Dockerfile") SERVER_FAVOR="fpm";;
    *)  SERVER_FAVOR="apache";;
esac

declare -a DB_FLAVORS = ("mysql_maria","postgresql","multibase")

BUILD_NUMBER=$(date +"%Y%m%d%H%M")

FINAL_TAGS=()

function generateTags(){
        
    local TAG=${1}
    local DB_FLAVOR=${2}

    local COMMON="${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}"
    local COMMON_PHP_VERSION="${COMMON}_php${PHP_VERSION}"

    #trim    
    TAG=$TAG

    if [ ! -z ${TAG} ]; then TAG="_${TAG}"; fi

    VERSIONS=("${COMMON_PHP_VERSION}${TAG}" "${COMMON_PHP_VERSION}${TAG}_${BUILD_NUMBER}")

    if [ "$PHP_VERSION" == "${DEFAULT_PHP}" ]; then
        VERSIONS+=( "${COMMON}${TAG}" "${COMMON}${TAG}_${BUILD_NUMBER}")
    fi

    echo ${VERSIONS[*]}

}

for DB_FLAVOR in ${DB_FLAVORS[@]}; do

    case $DB_FLAVOR in
        "mysql_maria" ) TARGET="mysql_maria" ;;
        "postgresql" ) TARGET="postgresql";;
        *) TARGET="mulitibase"
    esac

    TAGS=()

    TAGS+=( $(generateTags $DB_FLAVOR) )

    if [[ $VERSION == $LATEST_LTS ]]; then
        TAGS+=( $(generateTags lts) )
    fi

    if [[ $VERSION == $LATEST ]]; then
        TAGS+=(  $(generateTags latest ) )
        TAGS+=( $(generateTags ${SERVER_FAVOR} ))

        if [ "$PHP_VERSION" == "${DEFAULT_PHP}" ]; then
            TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_${BUILD_NUMBER}")
        fi
        
        TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_php${PHP_VERSION}_${BUILD_NUMBER}")

        if [[ $SERVER_FAVOR == "apache" ]] && [[ $DB_FLAVOR = "mulitbase" ]]; then
            if [ $PHP_VERSION==${DEFAULT_PHP} ];then
                TAGS+=("latest" "latest_${BUILD_NUMBER}")
            fi

            TAGS+=("latest_php${PHP_VERSION}" "latest_php${PHP_VERSION}_${BUILD_NUMBER}")
        fi
    fi

    PARAMS=${TAGS[@]/#/"-t ellakcy/moodle:"}

    echo "Running:" 
    echo "docker build --build-arg DB_TYPE=${DB_TYPE} -f ${DOCKERFILE} ${PARAMS} --force-rm . "

    docker build --pull --build-arg PHP_VERSION=${PHP_VERSION} --build-arg DB_TYPE=${DB_TYPE} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${PARAMS} --force-rm --no-cache .

done

BRANCH=${GITHUB_REF##*/}

if [[ $BRANCH == 'master' ]]; then
    for tag in "${FINAL_TAGS[@]}"; do
        docker image push ellakcy/moodle:$tag
    done
fi