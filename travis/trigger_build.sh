#!/bin/bash


if [[ ${TRAVIS_BRANCH} == 'dev' ] or [ ${TRAVIS_BRANCH} == 'master' ]]; then
 echo "Ι will generate branches"
else
 echo "Ι will build docker"
fi