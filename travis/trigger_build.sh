#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`


if [ ${TRAVIS_BRANCH} == 'dev' ] || [ ${TRAVIS_BRANCH} == 'master' ]; then
    bash ${SCRIPTPATH}/../travis/gen_braches.sh
else
    bash ${SCRIPTPATH}/../travis/buils_docker.sh
fi
