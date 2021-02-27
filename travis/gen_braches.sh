#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

DB_FLAVORS=("all" "mysqli" "pgsql")
DOCKERFILES=("dockerfiles/fpm_alpine/Dockerfile" "dockerfiles/apache/Dockerfile")

git fetch

while read VERSION; do
    for DB_FLAVOR in $DB_FLAVORS; do
        for DOCKERFILE in $DOCKERFILES; do
            echo $VERSION
            case $DOCKERFILE in
                "dockerfiles/fpm_alpine/Dockerfile") SERVER_FLAVOR='fpm';;
                "dockerfiles/apache/Dockerfile") SERVER_FLAVOR='apache';;
            esac

            BRANCH="version/${VERSION}_${DB_FLAVOR}_${SERVER_FLAVOR}"
            if [[ $(git ls-remote origin ${BRANCH} | wc -c) -ne 0 ]]; then 
                git checkout ${BRANCH}
            else 
                git checkout -b ${BRANCH}
            fi
            git merge -s ours master
            # echo $VERSION > ${SCRIPTPATH}/../VERSION
            # echo $DOCKERFILE > ${SCRIPTPATH}/../DOCKERFILE
            # git commit -am "SET VERSION AND FLAVOR"
            git status
            # git push origin ${BRANCH}
        done
    done
done < "${SCRIPTPATH}/../versions.txt"
