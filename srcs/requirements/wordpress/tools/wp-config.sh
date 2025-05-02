#!/bin/bash
set -e

env

echo "=== WordPress container starting ==="

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "=== Installing WordPress ==="
    wp core download --allow-root

    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST"
    
    wp core install --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"
    
    wp user create --allow-root \
        "$WP_USER" "$WP_EMAIL" \
        --user_pass="$WP_PASSWORD" \
        --role=author
    
    chown -R www-data:www-data /var/www/html
    
    echo "=== WordPress installed successfully ==="
else
    echo "=== Using existing WordPress installation ==="
fi

mkdir -p /var/www/html/healthz
echo "<?php echo 'OK'; ?>" > /var/www/html/healthz/index.php
mkdir -p /var/www/html/status
echo "<?php echo 'OK'; ?>" > /var/www/html/status/index.php

chown -R www-data:www-data /var/www/html

echo "=== Starting PHP-FPM ==="
exec "$@"