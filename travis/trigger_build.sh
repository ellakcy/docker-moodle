#!/bin/bash


if [ ${TRAVIS_BRANCH} == 'dev' ] || [ ${TRAVIS_BRANCH} == 'master' ]; then
 echo "Ι will generate branches"
else
 echo "Ι will build docker"
fi