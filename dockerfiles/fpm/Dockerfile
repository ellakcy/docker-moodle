# Dockerfile for moodle instance.
# Forked from Jonathan Hardison's <jmh@jonathanhardison.com> docker version. https://github.com/jmhardison/docker-moodle
# Original Maintainer Jon Auer <jda@coldshore.com>

ARG PHP_VERSION="7.4"
FROM  php:${PHP_VERSION}-fpm as base

# Replace for later version

VOLUME ["/var/moodledata"]
EXPOSE 80

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive \
	MOODLE_URL http://0.0.0.0 \
    MOODLE_ADMIN admin \
    MOODLE_ADMIN_PASSWORD Admin~1234 \
    MOODLE_ADMIN_EMAIL admin@example.com \
    MOODLE_DB_HOST '' \
    MOODLE_DB_PASSWORD '' \
    MOODLE_DB_USER '' \
    MOODLE_DB_NAME '' \
    MOODLE_DB_PORT '3306'

RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
	/usr/local/bin/install-php-extensions xmlrpc mbstring zip xml intl soap gd opcache &&\
 	apt-get autopurge -y &&\
 	apt-get autoremove -y &&\
 	apt-get autoclean &&\
 	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* cache/* /var/lib/log/*

ARG VERSION=311
RUN	echo "Installing moodle ${VERSION}" && \
	cd /usr/src &&\ 
	curl -s -N  https://packaging.moodle.org/stable${VERSION}/moodle-latest-${VERSION}.tgz | tar -xvz && \
	ls -l /usr/src/moodle &&\
	rm -rf /var/www/html/index.html && \
	chown www-data:www-data -R /usr/src/moodle && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* cache/* /var/lib/log/* &&\
	cd /var/www/html

COPY ./scripts/moodle-config.php /usr/src/moodle/config.php
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chown root:root /usr/local/bin/entrypoint.sh &&\
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

FROM base as multibase

ENV MOODLE_DB_TYPE 'all'

RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
	/usr/local/bin/install-php-extensions mysqli pdo_mysqli pgsql pdo_pgsql &&\
	apt-get autopurge -y &&\
	apt-get autoremove -y &&\
	apt-get autoclean &&\
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* cache/* /var/lib/log/*

FROM base as mysql_maria

ENV MOODLE_DB_TYPE 'mysqli'

COPY --from=multibase /usr/lib/php/extensions/no-debug-non-zts-20190902/pdo_mysql.so /usr/lib/php/extensions/no-debug-non-zts-20190902/pdo_mysql.so
COPY --from=multibase /usr/lib/php/extensions/no-debug-non-zts-20190902/mysqli.so /usr/lib/php/extensions/no-debug-non-zts-20190902/mysqli.so
COPY --from=multibase /usr/local/etc/php/conf.d/mysql.ini /usr/local/etc/php/conf.d/mysql.ini

RUN echo 'mysqli' > /etc/db_type;

FROM base as postgres

ENV MOODLE_DB_TYPE 'pgsql'

COPY --from=intermediate /usr/lib/php/extensions/no-debug-non-zts-20190902/pdo_pgsql.so /usr/lib/php/extensions/no-debug-non-zts-20190902/pdo_pgsql.so
COPY --from=intermediate /usr/lib/php/extensions/no-debug-non-zts-20190902/pgsql.so /usr/lib/php/extensions/no-debug-non-zts-20190902/pgsql.so
COPY --from=intermediate /usr/local/etc/php/conf.d/postgresql.ini /usr/local/etc/php/conf.d/postgresql.ini

RUN echo 'pgsql' > /etc/db_type;
