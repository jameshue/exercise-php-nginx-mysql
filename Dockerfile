# Base image
FROM php:7.4.23-fpm

# Configuring web
RUN   mkdir -p /var/www/html/website \
	      && mkdir /app \
	      && ln -s /app/public /var/www/html 

# Copy config files into the container
COPY  ./conf/website.conf /etc/nginx/sites-available/website.conf
COPY  ./conf/php.ini /usr/local/etc/php/
COPY  ./conf/docker.cnf /etc/mysql/conf.d/
# COPY  web /var/www/html/website

# Install Nginx and other necessary libraries
RUN apt-get update && apt-get install -y --no-install-recommends nginx supervisor libpng-dev libjpeg-dev libjpeg62-turbo libmcrypt4 libmcrypt-dev libcurl3-dev libxml2-dev libxslt-dev libicu-dev  && rm -rf /var/lib/apt/lists/*

# Configure Nginx
RUN chown -R www-data:www-data /var/www/html/website \
    &&  unlink /etc/nginx/sites-enabled/default \
    &&  ln -s /etc/nginx/sites-available/website.conf /etc/nginx/sites-enabled

# Install PHP and PHP extensions
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y zlib1g-dev libonig-dev libzip-dev \
    && curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer \
#    && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install exif \
    && apt-get purge --auto-remove -y libjpeg-dev libmcrypt-dev libcurl3-dev libxml2-dev libicu-dev \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo_mysql \
    && apt-get autoremove

# Use supervisord instead of direct run for Nginx and PHP
COPY ./conf/supervisord.conf /etc/supervisord.conf

# PHP-FPM basic config file
COPY ./conf/fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Adding startup script for Nginx and PHP
COPY /entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 

WORKDIR /app
COPY webapp/composer.json /app/
COPY webapp/composer.lock /app/
RUN composer install  --no-autoloader --no-scripts
COPY webapp/ /app/
RUN composer install \
    && chown -R www-data:www-data /app \
    && chmod -R 0777 /app/storage

# Exposing ports
EXPOSE 80 443 9000

CMD ["/entrypoint.sh"]
