# Notes for Contributors:

# For docker-compose.yml
For each purpoce in the folder `./compose` are located all `docker-compose.yml` files. On the folder `latest` are the docker-compose files are the `docker-compose.yml` for the latest moodle version whilst in the `lts` will contain the `docker-compose.yml` for the lts version of it. Either in `lts` folder or in `latest` folder the following `docker-compose.yml` folders will be contained:

Compose File | Puproce
--- | ---
`docker-compose-alpine-fpm.yml` | For building the images based upon alpine php images.
`docker-compose-apache.yml` | For apache based variants
`docker-compose-ssl-reverse-nginx.yml` | For testing the nginx as SSL reverse proxy.

# Port conventions used for launching the containers

In this project the following ports are being used:

Port Range | Usage by | LTS VERSION
--- | --- | ---
7880-7882 | Alpine FPM IMAGES | YES
7870-7872 | Alpine FPM IMAGES | NO
6880-6882 | Apache Based Images | YES

For more info consult the *.yml files located in the subfolders of the `./compose` folder.

# In case that images fail to launch with `docker-compose up`

Run the following command:

```
docker-compose -f ^docker-compose-yml-file^ down -v --remove-orphans
```
Where `^docker-compose-yml-file^` is the directory path of the approrpiate `docker-compose.yml` file located in the `./compose` directory.