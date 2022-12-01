FROM php:5.6-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_SQL_PASS=root

RUN debconf-set-selections << "mysql-server mysql-server/root_password password ${ROOT_SQL_PASS}" && \
    debconf-set-selections << "mysql-server mysql-server/root_password_again password ${ROOT_SQL_PASS}"

RUN apt-get update && apt-get install -y \
    bzip2 \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpng-dev \
    libpq-dev \
    libxml2-dev \
    libldap2-dev \
    mysql-server \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install gd exif intl mbstring mcrypt mysql opcache pdo_mysql pdo_pgsql pgsql zip ldap

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# PECL extensions
RUN set -ex \
    && pecl install APCu-4.0.10 \
    && pecl install memcached-2.2.0 \
    && pecl install redis-2.2.8 \
    && docker-php-ext-enable apcu redis memcached

RUN git clone -b v8.2.10 https://github.com/owncloud/core.git /var/www/html/ && \
    git submodule update --init

COPY ["./entrypoint.sh", "/entrypoint"]
COPY ["./init.sql", "/init.sql"]

RUN a2enmod rewrite && \
    chmod +x /entrypoint

ENV MYSQL_DATABASE=owncloud \
    MYSQL_USER=owncloud \
    MYSQL_PASSWORD=owncloud

WORKDIR /var/www/html

CMD ["/entrypoint"]