#!/usr/bin/env bash

SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
BASEDIR=$(dirname "${SCRIPT}")

source "${BASEDIR}/config.sh"

# Basic variables
echo "LATEST: ${LATEST}"
echo "LATEST_LTS: ${LATEST_LTS}"
echo "DEFAULT_PHP: \"${DEFAULT_PHP}\""

# Associative array: MOODLE_MIN_PHP
echo "MOODLE_MIN_PHP:"
for key in "${!MOODLE_MIN_PHP[@]}"; do
    echo "  $key: ${MOODLE_MIN_PHP[$key]}"
done | sort

# Array: MOODLE_VERSIONS
echo "MOODLE_VERSIONS:"
for v in "${MOODLE_VERSIONS[@]}"; do
    echo "  - $v"
done

# Array: PHP_VERSIONS
echo "PHP_VERSIONS:"
for v in "${PHP_VERSIONS[@]}"; do
    echo "  - \"$v\""
done

# Array: DOCKERFILES
echo "DOCKERFILES:"
for df in "${DOCKERFILES[@]}"; do
    echo "  - \"$df\""
done

# Associative arrays with string keys
echo "CRON:"
for key in "${!CRON[@]}"; do
    echo "  \"$key\": \"${CRON[$key]}\""
done

echo "ACTION_NAMES:"
for key in "${!ACTION_NAMES[@]}"; do
    echo "  \"$key\": \"${ACTION_NAMES[$key]}\""
done

# Min versions
echo "MIN_MYSQL_VERSION:"
for key in "${!MIN_MYSQL_VERSION[@]}"; do
    echo "  $key: ${MIN_MYSQL_VERSION[$key]}"
done | sort

echo "MIN_MARIADB_VERSION:"
for key in "${!MIN_MARIADB_VERSION[@]}"; do
    echo "  $key: ${MIN_MARIADB_VERSION[$key]}"
done | sort

echo "MIN_POSTGRES_VERSION:"
for key in "${!MIN_POSTGRES_VERSION[@]}"; do
    echo "  $key: ${MIN_POSTGRES_VERSION[$key]}"
done | sort
