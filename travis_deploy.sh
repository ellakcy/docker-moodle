#!/bin/bash

echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
docker-compose -f $DOCKER_COMPOSE_FILE push