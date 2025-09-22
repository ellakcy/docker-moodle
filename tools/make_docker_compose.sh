#!/bin/bash -e

SCRIPT=$(readlink -f "${BASH_SOURCE}")
BASEDIR=$(dirname ${SCRIPT})

source ${BASEDIR}/config.sh