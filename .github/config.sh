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
PHP_VERSIONS=('8.0' '8.1' '8.2' '8.3' '8.4')
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