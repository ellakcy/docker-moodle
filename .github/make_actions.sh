#!/bin/bash -e

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "${BASH_SOURCE}")
# Absolute path this script is in, thus /home/user/bin
BASEDIR=$(dirname ${SCRIPT})

source ${BASEDIR}/config.sh

TEMPLATE='name: {{action_name}}

on:
  schedule:
    - cron: {{cron_expression}} 
  push:
    branches: [ master, dev ]

jobs:
  build_images:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        moodle_version: {{MOODLE_VERSIONS}}
        php_version: {{PHP_VERSIONS}}
        exclude:
          {{EXCLUDE_VERSIONS}}
    env:
      VERSION: ${{ matrix.moodle_version }}
      PHP_VERSION: "${{ matrix.php_version }}"
    steps:
      - name: Check Out Repo 
        uses: actions/checkout@v3

      - name: Login to Docker Hub
        if: github.ref != '\''refs/heads/dev'\''
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build Docker Images
        shell: bash
        run: |
          docker --version
          chmod +x ".github/build_docker.sh"
          .github/build_docker.sh {{DOCKERFILE}}
'

generate_excludes() {
  local mv="$1"
  local min_php="${MOODLE_MIN_PHP[$mv]}"
  local result=""

  if [ "$min_php" == "" ]; then
    echo ""
    exit 0
  fi

  for pv in "${PHP_VERSIONS[@]}"; do
    if (( $(echo "$pv < $min_php" | bc -l) )); then
      result+="
          - moodle_version: $mv
            php_version: $pv"
    fi
  done
  echo "$result"
}

mkdir -p .github/workflows

for dockerfile in "${DOCKERFILES[@]}"; do
  echo "Generating for ${dockerfile}"
  cron="${CRON[$dockerfile]}"
  action_name="${ACTION_NAMES[$dockerfile]}"
  outfile=".github/workflows/${action_name}.yml"

  exclude_list=""
  for moodle_version in "${MOODLE_VERSIONS[@]}"; do
    exclude_list+="$(generate_excludes "$moodle_version")"
  done

  content="$TEMPLATE"
  content="${content//\{\{action_name\}\}/$action_name}"
  content="${content//\{\{cron_expression\}\}/$cron}"
  content="${content//\{\{MOODLE_VERSIONS\}\}/[${MOODLE_VERSIONS[*]}]}"
  content="${content//\{\{PHP_VERSIONS\}\}/[${PHP_VERSIONS[*]}]}"
  content="${content//\{\{DOCKERFILE\}\}/$df}"
  content="${content//\{\{EXCLUDE_VERSIONS\}\}/$exclude_list}"

  echo "$content" > "$outfile"
  echo "Generated $outfile"
done

