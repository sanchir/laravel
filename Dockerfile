FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    zip unzip libzip-dev libpng-dev libonig-dev libxml2-dev mariadb-client \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

RUN echo "alias ll='ls -l'" >> /root/.bashrc

WORKDIR /var/www
