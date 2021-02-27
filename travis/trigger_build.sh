#!/bin/bash


if [ ${TRAVIS_BRANCH} == 'dev' ] || [ ${TRAVIS_BRANCH} == 'master' ]; then
    bash ./travis/gen_branches.sh 
else
    bash ./travis/buils_docker.sh
fi