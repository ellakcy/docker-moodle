# Dockerfile for moodle instance.
#Original Maintainer Jon Auer <jda@coldshore.com>

ARG PHP_VERSION="7.4"
FROM  php:${PHP_VERSION}-fpm-alpine as base

# Replace for later version

VOLUME ["/var/moodledata"]
VOLUME ["/var/www/html"]
EXPOSE 9000

ENV MOODLE_URL=http://0.0.0.0 \
    MOODLE_ADMIN=admin \
    MOODLE_ADMIN_PASSWORD=Admin~1234 \
    MOODLE_ADMIN_EMAIL=admin@example.com \
    MOODLE_DB_HOST= \
    MOODLE_DB_PASSWORD= \
    MOODLE_DB_USER= \
    MOODLE_DB_NAME= \
    MOODLE_DB_PORT=3306


RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
	/usr/local/bin/install-php-extensions xmlrpc mbstring zip xml intl soap gd opcache &&\
	apk update &&\
	apk add netcat-openbsd rsync &&\
	 rm -rf /var/cache/apk/* /var/tmp/* cache/* /var/lib/log/* &&\
	echo "max_input_vars=5000" > ${PHP_INI_DIR}/conf.d/moodle.ini

ARG VERSION=311
RUN \
 	 echo "Installing moodle" && \
	 php -r "copy(\"https://packaging.moodle.org/stable${VERSION}/moodle-latest-${VERSION}.tgz\",\"/tmp/moodle-latest.tgz\");" &&\
 	 rm -rf /var/www/html/index.html && \
 	 cd /tmp &&\
	 tar -xvf /tmp/moodle-latest.tgz && cd / \
 	 mkdir -p /usr/src/moodle && \
 	 mv /tmp/moodle /usr/src/ && \
 	 chown www-data:www-data -R /usr/src/moodle && \
	 rm -rf /var/cache/apk/* /var/tmp/* cache/* /var/lib/log/*

COPY ./scripts/moodle-config-fpm.php /usr/src/moodle/config.php
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chown root:root /usr/local/bin/entrypoint.sh &&\
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/bin/sh","/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

FROM base as multibase

ENV MOODLE_DB_TYPE 'all'

RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
	/usr/local/bin/install-php-extensions mysqli pdo_mysql pgsql pdo_pgsql &&\
	php -i | grep extension_dir  | cut -d " " -f 5 &&\
	ls -l /usr/local/etc/php/conf.d/ &&\
	rm -rf /var/cache/apk/* /var/tmp/* cache/* /var/lib/log/*

FROM base as mysql_maria

ENV MOODLE_DB_TYPE 'mysqli'
RUN echo 'mysqli' > /etc/db_type;

# Use the argument CACHEBUST to disable caching during build bellow. This contains the build number.
ARG CACHEBUST=0
RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
	/usr/local/bin/install-php-extensions mysqli pdo_mysql &&\
	php -i | grep extension_dir  | cut -d " " -f 5 &&\
	ls -l /usr/local/etc/php/conf.d/ &&\
	rm -rf /var/cache/apk/* /var/tmp/* cache/* /var/lib/log/*

FROM base as postgres

ENV MOODLE_DB_TYPE 'pgsql'
RUN echo 'pgsql' > /etc/db_type;

# Use the argument CACHEBUST to disable caching during build bellow. This contains the build number.
ARG CACHEBUST=0
RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
	/usr/local/bin/install-php-extensions pgsql pdo_pgsql &&\
	php -i | grep extension_dir  | cut -d " " -f 5 &&\
	ls -l /usr/local/etc/php/conf.d/ &&\
	rm -rf /var/cache/apk/* /var/tmp/* cache/* /var/lib/log/*
