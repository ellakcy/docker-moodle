LATEST=500
LATEST_LTS=405
DEFAULT_PHP="8.0"

declare -A MOODLE_MIN_PHP=(
  [500]=8.2
  [405]=8.1
  [404]=8.1
  [403]=8.0
  [402]=7.4
  [401]=7.3
  [400]=7.2
  [311]=7.2
  [310]=7.1
)


MOODLE_VERSIONS=(401 404 405 500)
PHP_VERSIONS=('7.4','8.0' '8.1' '8.2' '8.3' '8.4')
DOCKERFILES=('dockerfiles/fpm_alpine/Dockerfile' 'dockerfiles/apache/Dockerfile' 'dockerfiles/fpm/Dockerfile')

declare -A CRON=(
    ['dockerfiles/fpm_alpine/Dockerfile']='23 0 * * 6'
    ['dockerfiles/apache/Dockerfile']='23 0 * * 6'
    ['dockerfiles/fpm/Dockerfile']='23 20 * * 6' 
)

declare -A ACTION_NAMES=(
    ['dockerfiles/fpm_alpine/Dockerfile']='deploy-alpine-fpm'
    ['dockerfiles/apache/Dockerfile']='deploy-apache'
    ['dockerfiles/fpm/Dockerfile']='deploy-fpm' 
)

declare -A MIN_MYSQL_VERSION=(
  [500]=8.0
  [405]=8.0
  [404]=8.0
  [403]=8.0
  [402]=8.0
  [401]=5.7.31
  [400]=5.7
)

declare -A MIN_MARIADB_VERSION=(
  [500]=10.11.0
  [405]=10.6.7
  [404]=10.6.7
  [403]=10.6.7
  [402]=10.6.7
  [401]=10.4
)

declare -A MIN_POSTGRES_VERSION=(
  [500]=14
  [405]=13
  [404]=13
  [403]=13
  [402]=13
  [401]=12
)