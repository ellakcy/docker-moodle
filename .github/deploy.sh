#!/bin/bash

echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
docker push ellakcy/moodle