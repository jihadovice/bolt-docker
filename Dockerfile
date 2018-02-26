FROM php:7.1.2-apache 

ENV DEBIAN_FRONTEND noninteractive

# Configure Apache and installs other services
RUN a2enmod rewrite \
    && apt-get update \
    && echo 'ServerName localhost' >> /etc/apache2/apache2.conf \
    && apt-get install -y curl git libpng-dev libxml2-dev g++ libicu-dev \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install extra php libraries
RUN docker-php-ext-install exif fileinfo zip xml intl gd pdo pdo_mysql

# Add custom Apache config file
ADD ./docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative \
	&& composer clear-cache

COPY run.sh /run.sh
RUN chmod 0755 /run.sh

WORKDIR /var/www/html/boltsite

# Add project files
RUN mkdir -p app/cache
COPY app/database app/database
COPY app/config app/config
COPY app/nut app
COPY public public
COPY extensions extensions
COPY src src
COPY index.php ./
COPY composer.json ./
COPY composer.lock ./

RUN composer install --no-interaction --prefer-source
EXPOSE 80
CMD ["/run.sh"]
