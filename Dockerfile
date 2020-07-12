FROM php:7.4-fpm

MAINTAINER Frank Giger <mail@frank-giger.ch>

ENV LANG en_US.utf8

RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && \
    rm -rf /tmp/composer-setup.php

RUN php -r "copy('https://phar.phpunit.de/phpunit.phar','/tmp/phpunit.phar');"
RUN chmod +x /tmp/phpunit.phar
RUN mv /tmp/phpunit.phar /usr/local/bin/phpunit

RUN apt-get update && \
    apt-get install -y git unzip 

RUN apt-get update && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libsqlite3-dev \
        libcurl4-gnutls-dev \
        libzip-dev \
		libonig-dev \
        libmagickwand-dev --no-install-recommends \
    && docker-php-ext-install -j$(nproc) iconv gd pdo_mysql pcntl pdo_sqlite zip curl bcmath opcache mbstring soap mysqli xml\
    && pecl install imagick \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable iconv gd pdo_mysql pcntl pdo_sqlite zip curl bcmath opcache mbstring imagick soap mysqli xml \
    && apt-get autoremove -y

RUN apt-get update && \
    apt-get install -y \
    gcc make autoconf libc-dev pkg-config libmcrypt-dev \
    && pecl install mcrypt-1.0.3

RUN bash -c "echo extension=mcrypt.so > /usr/local/etc/php/conf.d/mcrypt.ini"

RUN php -i | grep "mcrypt" 

RUN docker-php-ext-install exif \
    && docker-php-ext-enable exif

EXPOSE 9000

CMD ["php-fpm"]