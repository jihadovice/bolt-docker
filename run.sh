#!/usr/bin/env bash

vendor/bin/nut extensions:setup
vendor/bin/nut database:update
chown -R www-data:www-data app/cache
chown -R www-data:www-data app/database
chown -R www-data:www-data public/
rm -rf app/cache/*

chmod 777 -R app/cache app/database

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
