# Dockerfile for moodle instance.
# Forked from Jonathan Hardison's <jmh@jonathanhardison.com> docker version. https://github.com/jmhardison/docker-moodle
#Original Maintainer Jon Auer <jda@coldshore.com>

FROM  php:7.2-apache

# Replace for later version

VOLUME ["/var/moodledata"]
EXPOSE 80

ENV MOODLE_DB_TYPE $DB_TYPE
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

RUN echo "Build moodle version ${VERSION}" &&\
	apt-get update &&\
	apt-get -f -y install --no-install-recommends rsync netcat libxmlrpc-c++8-dev libxml2-dev libpng-dev libicu-dev libmcrypt-dev libzip-dev &&\
 	docker-php-ext-install xmlrpc && \
	docker-php-ext-install mbstring && \
	whereis libzip &&\
	docker-php-ext-configure zip --with-libzip=/usr/lib/x86_64-linux-gnu/libzip.so &&\
	docker-php-ext-install zip &&\
	docker-php-ext-install xml &&\
	docker-php-ext-install intl &&\
 	docker-php-ext-install soap &&\
	docker-php-ext-install gd &&\
	docker-php-ext-install opcache &&\ 
	apt-get autopurge -y &&\
	apt-get autoremove -y &&\
	apt-get autoclean &&\
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* cache/* /var/lib/log/*

ARG	DB_TYPE="all"

RUN apt-get update && \
	echo ${DB_TYPE} &&\
	if [ $DB_TYPE = "mysqli" ] || [ $DB_TYPE = "all" ]; then echo "Setup mysql and mariadb support" &&\
		 docker-php-ext-install pdo mysqli pdo_mysql;\
	fi &&\
	if [ $DB_TYPE = "pgsql" ] || [ $DB_TYPE = "all" ]; then echo "Setup postgresql support" &&\
		apt-get install -y --no-install-recommends libghc-postgresql-simple-dev &&\
     	docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql &&\
        docker-php-ext-install pdo pgsql pdo_pgsql; \ 
	fi &&\
	if [ $DB_TYPE = "mysqli" ] || [ $DB_TYPE = "pgsql" ]; then \
		echo "SET DB_TYPE file" ;\
		echo $DB_TYPE > /etc/db_type;\
	fi &&\
	apt-get autopurge -y &&\
	apt-get autoremove -y &&\
	apt-get autoclean &&\
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* cache/* /var/lib/log/*

ARG VERSION=37

RUN	echo "Installing moodle ${VERSION}" && \
	cd /usr/src &&\ 
	curl -s -N  http://download.moodle.org/download.php/direct/stable${VERSION}/moodle-latest-${VERSION}.tgz | tar -xvz && \
	ls -l /usr/src/moodle &&\
	rm -rf /var/www/html/index.html && \
	chown www-data:www-data -R /usr/src/moodle && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* cache/* /var/lib/log/* &&\
	cd /var/www/html

COPY ./scripts/moodle-config.php /usr/src/moodle/config.php
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chown root:root /usr/local/bin/entrypoint.sh &&\
	chmod +x /usr/local/bin/entrypoint.sh

CMD [ "/usr/local/bin/entrypoint.sh", "/usr/sbin/apache2ctl", "-D", "FOREGROUND"]