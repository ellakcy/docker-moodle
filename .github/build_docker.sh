#!/bin/bash -e

#############################################################################
# THIS SCRIPT, FOR A SUCCESSFULL RUN, REQUIRES THESE ENVIRONMENTAL VARIABLES:
#
# VERSION : The moodle version without dots eg for moodle 4.3 use 403
# PHP_VERSION : For the PHP version to use.
# DRY_RUN  : If set as 1 will not build the docker images it will just pront the build arguments 
# CACHE_ENABLE : If set 1 it builds the docker images without --no-cache
# 
# Also a single argument must be provided for the dockerfile:
# 
# dockerfiles/fpm_alpine/Dockerfile : for fpm using alpine
# dockerfiles/fpm/Dockerfile : for debian based fpm
# dockerfiles/fpm_alpine/Dockerfile: for apache
#
# If not provided is it assumes as an apache image
# ###########################################################################


# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "${BASH_SOURCE}")
# Absolute path this script is in, thus /home/user/bin
BASEDIR=$(dirname ${SCRIPT})

source ${BASEDIR}/config.sh

PHP_VERSION=${PHP_VERSION:=${DEFAULT_PHP}}

if [ "$PHP_VERSION" == "${DEFAULT_PHP}" ]; then
    echo "$PHP_VERSION is same to ${DEFAULT_PHP}"
fi

SERVER_FAVOR="apache"

DOCKERFILE=${1}

case $DOCKERFILE in
    "dockerfiles/fpm_alpine/Dockerfile") SERVER_FAVOR="fpm_alpine";;
    "dockerfiles/fpm/Dockerfile") SERVER_FAVOR="fpm";;
    *) DOCKERFILE="dockerfiles/apache/Dockerfile"; SERVER_FAVOR="apache";;
esac

DB_FLAVORS=("mysql_maria" "postgresql" "multibase")

BUILD_NUMBER=$(date +"%Y%m%d%H%M")

# Aggregates all available tags
FINAL_TAGS=()

MULTIBASE_PARAMS=()
POSTGRES_PARAMS=()
MYSQL_PARAMS=()

function generateTags(){
        
    local TAG=${2}
    local DB_FLAVOR=${1}

    # VERSION is env variable, and indicates the moodle version we build upon
    local COMMON_WITHOUT_VERSION="${DB_FLAVOR}_${SERVER_FAVOR}"
    local COMMON="${COMMON_WITHOUT_VERSION}_${VERSION}"
    local COMMON_PHP_VERSION="${COMMON}_php${PHP_VERSION}"

    #trim    
    TAG=$TAG

    if [ ! -z ${TAG} ]; then TAG="_${TAG}"; fi

    VERSIONS=("${COMMON_PHP_VERSION}${TAG}" "${COMMON_PHP_VERSION}${TAG}_${BUILD_NUMBER}")

    if [ "$PHP_VERSION" == "${DEFAULT_PHP}" ]; then
        VERSIONS+=( "${COMMON}${TAG}" "${COMMON}${TAG}_${BUILD_NUMBER}")
        
        # Check is done outside the function
        if [[ "$TAG" == '_latest' ]] || [[ "$TAG" == '_lts' ]] ; then
          VERSIONS+=("${COMMON_WITHOUT_VERSION}${TAG}"  "${COMMON_WITHOUT_VERSION}_${BUILD_NUMBER}${TAG}")
        fi
    fi


    echo ${VERSIONS[*]}

}

# Pulling extention installer
docker pull mlocati/php-extension-installer

for DB_FLAVOR in ${DB_FLAVORS[@]}; do

    echo "GENERATING TAGS for ${DB_FLAVOR} and ${SERVER_FAVOR}"

    TAGS=( $(generateTags $DB_FLAVOR) )

    if [[ $VERSION == $LATEST_LTS ]]; then
        TAGS+=( $(generateTags $DB_FLAVOR lts) )
    fi

    if [[ $VERSION == $LATEST ]]; then
        TAGS+=(  $(generateTags ${DB_FLAVOR} latest ) )
        TAGS+=( $(generateTags ${DB_FLAVOR} ${SERVER_FAVOR} ))
        
        TAGS+=("${DB_FLAVOR}_${SERVER_FAVOR}_php${PHP_VERSION}_${BUILD_NUMBER}")

        if [[ $SERVER_FAVOR == "apache" ]] && [[ $DB_FLAVOR = "multibase" ]]; then
            if [ $PHP_VERSION==${DEFAULT_PHP} ];then
                TAGS+=("latest" "latest_${BUILD_NUMBER}")
            fi

            TAGS+=("latest_php${PHP_VERSION}" "latest_php${PHP_VERSION}_${BUILD_NUMBER}")
        fi


    fi

    PARAMS=${TAGS[@]/#/"-t ellakcy/moodle:"}

     case $DB_FLAVOR in
        "mysql_maria" ) MYSQL_PARAMS=$PARAMS ;;
        "postgresql" )  POSTGRES_PARAMS=$PARAMS;;
        *) MULTIBASE_PARAMS=$PARAMS
    esac
    
    FINAL_TAGS+=($TAGS)
done

if [ "$DRY_RUN" == "1" ]; then 
    
    echo "DRY RUN MODE NO IMAGES ARE BUILT"
    echo "# MYSQL #" > ./debug.txt
    echo ${MYSQL_PARAMS} >> ./debug.txt
    echo "# POSTGRES #" >> ./debug.txt
    echo ${POSTGRES_PARAMS} >> ./debug.txt
    echo "# MULTIBASE #" >> ./debug.txt
    echo ${MULTIBASE_PARAMS} >> ./debug.txt

    sed -i 's/\s*-t\s*/\n/g' ./debug.txt

    cat ./debug.txt

    exit 0;
fi

CACHE_ARG="--no-cache"

if [ "$CACHE_ENABLE" == "1" ]; then
    CACHE_ARG=""
fi

DOCKER_BUILDKIT=1  docker build --target multibase ${CACHE_ARG} --pull --build-arg PHP_VERSION=${PHP_VERSION} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${MULTIBASE_PARAMS} .
DOCKER_BUILDKIT=1  docker build --target postgres  --build-arg CACHEBUST=${BUILD_NUMBER} --build-arg PHP_VERSION=${PHP_VERSION} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${POSTGRES_PARAMS} .
DOCKER_BUILDKIT=1  docker build --target mysql_maria --build-arg CACHEBUST=${BUILD_NUMBER} --build-arg PHP_VERSION=${PHP_VERSION} --build-arg VERSION=${VERSION} -f ${DOCKERFILE} ${MYSQL_PARAMS} .


BRANCH=${GITHUB_REF##*/}

if [[ $BRANCH == 'master' ]]; then
    for tag in "${FINAL_TAGS[@]}"; do
        docker image push ellakcy/moodle:$tag
    done
fi