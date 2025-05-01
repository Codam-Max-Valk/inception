#!/bin/bash
set -e

echo "=== WordPress container starting ==="

# Wait for database to be ready
echo "=== Waiting for database connection ==="
MAX_ATTEMPTS=20
RETRY_INTERVAL=3

# Wait for MySQL server to be reachable
until nc -z mariadb 3306 || [ $MAX_ATTEMPTS -eq 0 ]; do
    echo "Waiting for MariaDB server... ($MAX_ATTEMPTS attempts left)"
    MAX_ATTEMPTS=$((MAX_ATTEMPTS-1))
    sleep $RETRY_INTERVAL
done

if [ $MAX_ATTEMPTS -eq 0 ]; then
    echo "Failed to connect to MariaDB server"
    exit 1
fi

# Wait for MySQL authentication to succeed
echo "Testing database credentials..."
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" &>/dev/null; do
    echo "Waiting for database authentication..."
    sleep $RETRY_INTERVAL
    MAX_ATTEMPTS=$((MAX_ATTEMPTS-1))
    
    if [ $MAX_ATTEMPTS -eq 0 ]; then
        echo "Database authentication failed"
        exit 1
    fi
done

echo "=== Database connected successfully ==="

# Install WordPress if not already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "=== Installing WordPress ==="
    wp core download --allow-root

    # Create wp-config.php
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST"
    
    # Install WordPress
    wp core install --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"
    
    # Create additional user
    wp user create --allow-root \
        "$WP_USER" "$WP_EMAIL" \
        --user_pass="$WP_PASSWORD" \
        --role=author
    
    # Set correct permissions
    chown -R www-data:www-data /var/www/html
    
    echo "=== WordPress installed successfully ==="
else
    echo "=== Using existing WordPress installation ==="
fi

# Create both healthcheck endpoints to match what's in docker-compose
mkdir -p /var/www/html/healthz
echo "<?php echo 'OK'; ?>" > /var/www/html/healthz/index.php
mkdir -p /var/www/html/status
echo "<?php echo 'OK'; ?>" > /var/www/html/status/index.php

# Fix permissions
chown -R www-data:www-data /var/www/html

echo "=== Starting PHP-FPM ==="
# Start PHP-FPM in foreground mode with extra verbosity 
exec "$@"