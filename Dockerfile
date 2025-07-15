FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    tzdata curl zip unzip libzip-dev libpng-dev libonig-dev libxml2-dev mariadb-client \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Set timezone to JST
ENV TZ=Asia/Tokyo

RUN echo "alias ll='ls -l'" >> /root/.bashrc

# Clean up
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
