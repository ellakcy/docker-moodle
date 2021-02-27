#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

DB_FLAVORS=("all" "mysqli" "pgsql")
DOCKERFILES=("dockerfiles/fpm_alpine/Dockerfile" "dockerfiles/apache/Dockerfile")

cd ${SCRIPTPATH}/..
git fetch

CURR_BRANCH=${TRAVIS_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
echo "BRANCH "${CURR_BRANCH}

while read VERSION; do
    for DB_FLAVOR in ${DB_FLAVORS[@]}; do
        for DOCKERFILE in ${DOCKERFILES[@]}; do
            echo $VERSION
            case $DOCKERFILE in
                "dockerfiles/fpm_alpine/Dockerfile") SERVER_FLAVOR='fpm';;
                "dockerfiles/apache/Dockerfile") SERVER_FLAVOR='apache';;
            esac

            case $CURR_BRANCH in
                'dev') PREFIX='test';;
                'master') PREFIX='release';;
            esac

            BRANCH="${PREFIX}/${VERSION}_${DB_FLAVOR}_${SERVER_FLAVOR}"
            echo ${BRANCH}
         
            if [[ $(git ls-remote origin ${BRANCH} | wc -c) -ne 0 ]]; then 
                git checkout ${BRANCH}
            else 
                git checkout -b ${BRANCH}
            fi
            git merge -s ours ${CURR_BRANCH}
            echo $VERSION > ${SCRIPTPATH}/../VERSION
            git add ${SCRIPTPATH}/../VERSION
            echo $DOCKERFILE > ${SCRIPTPATH}/../DOCKERFILE
            git add ${SCRIPTPATH}/../DOCKERFILE
            git commit -m "SET VERSION AND FLAVOR"
            git status
            push -fq https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git ${BRANCH}
            git checkout $CURR_BRANCH
        done
    done
done < "${SCRIPTPATH}/../versions.txt"
