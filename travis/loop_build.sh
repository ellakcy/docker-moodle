#!/bin/bash

# The script required the Following Environmental Variables:
# DB_TYPE in order to specify the database type

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
DOCKERFILE_ALPINE_FPM="dockerfiles/fpm_alpine/Dockerfile"

LATEST=310
LATEST_LTS=39

case $DOCKERFILE_PATH in
    "dockerfiles/apache/Dockerfile") SERVER_FLAVOR="apache";;
    "dockerfiles/fpm_alpine/Dockerfile") SERVER_FLAVOR="fpm_alpine";;
esac

mkdir -p ${SCRIPTPATH}/../logs/

# File must end with new line
FILE="${SCRIPTPATH}/../versions.txt"
echo >> "${FILE}"

DB_FLAVORS=("mysqli" "pgsql" "all")

for DB_TYPE in "${DB_FLAVORS[@]}"; do
    
    DB_FLAVOR=""

    case $DB_TYPE in
        "mysqli" ) DB_FLAVOR="mysql_maria" ;;
        "pgsql" ) DB_FLAVOR="postgresql";;
        *) DB_FLAVOR="mulitbase"
    esac

    while read -r VERSION; do

        if [ "${VERSION}" == "" ]; then
            continue
        fi

        VERSION_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_${VERSION}"

        VERSION_TYPE_TAG=""

        if [[ $VERSION == $LATEST_LTS ]]; then
            VERSION_TYPE_TAG="-t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_lts"
        fi

        if [[ $VERSION == $LATEST ]]; then
            VERSION_TYPE_TAG="${VERSION_TYPE_TAG} -t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}_latest -t ellakcy/moodle:${DB_FLAVOR}_${SERVER_FAVOR}" 
            if [[ $SERVER_FAVOR == "apache" ]] && [[ $DB_FLAVOR = "mulitbase" ]]; then
                VERSION_TYPE_TAG=" ${VERSION_TYPE_TAG} -t  ellakcy/moodle:latest"
            fi
        fi

        echo "Running: docker build -f ${DOCKERFILE_PATH} ${VERSION_TYPE_TAG} ${VERSION_TAG} --no-cache --force-rm . "
        docker build --build-arg DB_TYPE=${DB_TYPE} --build-arg VERSION=${VERSION}  -f ${DOCKERFILE_PATH} ${VERSION_TYPE_TAG} ${VERSION_TAG} --force-rm ${SCRIPTPATH}/.. 2>&1 | tee ${SCRIPTPATH}/../logs/build_${SERVER_FAVOR}_${DB_FAVOR}_${VERSION}.log 2>&1
    done < "${FILE}"
done

docker system prune -f