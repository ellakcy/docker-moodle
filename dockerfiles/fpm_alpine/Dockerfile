# Dockerfile for moodle instance.
#Original Maintainer Jon Auer <jda@coldshore.com>

FROM  php:7.2-fpm-alpine

# Replace for later version

VOLUME ["/var/moodledata"]
VOLUME ["/var/www/html"]
EXPOSE 9000

ENV MOODLE_DB_TYPE ${DB_TYPE}

ENV \
	MOODLE_URL http://0.0.0.0 \
    MOODLE_ADMIN admin \
    MOODLE_ADMIN_PASSWORD Admin~1234 \
    MOODLE_ADMIN_EMAIL admin@example.com \
    MOODLE_DB_HOST '' \
    MOODLE_DB_PASSWORD '' \
    MOODLE_DB_USER '' \
    MOODLE_DB_NAME '' \
    MOODLE_DB_PORT '3306'

# Installing php and external tools
RUN \
	apk add --update curl bash rsync unzip netcat-openbsd libxml2-dev icu-dev libmcrypt-dev libpng-dev libjpeg-turbo-dev libzip-dev &&\
 	docker-php-ext-install xmlrpc && \
	docker-php-ext-install mbstring && \
	docker-php-ext-configure zip --with-libzip && \
	docker-php-ext-install zip &&\
	docker-php-ext-install intl && \
 	docker-php-ext-install soap && \
	docker-php-ext-install gd && \
	docker-php-ext-install opcache && \
	apk del unzip curl gcc g++ &&\
    rm -rf /var/cache/apk/*

ARG	DB_TYPE="all"

RUN \
	if [[ $DB_TYPE = "mysqli" ]] || [[ $DB_TYPE = "all" ]]; then echo "Setup mysql and mariadb support" &&\
		docker-php-ext-install pdo mysqli pdo_mysql;\
	fi &&\
	if [[ $DB_TYPE = "pgsql" ]] || [[ $DB_TYPE = "all" ]]; then echo "Setup postgresql support" &&\
		apk add --update postgresql-dev &&\
		docker-php-ext-install pdo pgsql pdo_pgsql;\
	fi &&\
	if [ $DB_TYPE = "mysqli" ] || [ $DB_TYPE = "pgsql" ]; then \
		echo "SET DB_TYPE file" ;\
		echo $DB_TYPE > /etc/db_type;\
	fi &&\
	rm -rf /var/cache/apk/*

ARG VERSION=35

RUN \
 	 echo "Installing moodle" && \
	 php -r "copy(\"http://download.moodle.org/download.php/direct/stable${VERSION}/moodle-latest-${VERSION}.tgz\",\"/tmp/moodle-latest.tgz\");" &&\
 	 rm -rf /var/www/html/index.html && \
 	 cd /tmp &&\
	 tar -xvf /tmp/moodle-latest.tgz && cd / \
 	 mkdir -p /usr/src/moodle && \
 	 mv /tmp/moodle /usr/src/ && \
 	 chown www-data:www-data -R /usr/src/moodle && \
     rm -rf /var/cache/apk/*

COPY ./scripts/moodle-config-fpm.php /usr/src/moodle/config.php
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chown root:root /usr/local/bin/entrypoint.sh &&\
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]