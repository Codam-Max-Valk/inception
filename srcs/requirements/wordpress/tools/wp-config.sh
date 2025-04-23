#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define path for WordPress installation
WP_PATH=/var/www/html

# Wait a bit for MariaDB container to be ready (simple sleep, a better check is recommended)
# A more robust check would involve trying to connect to the DB port.
# echo "Waiting for MariaDB..."
# sleep 10

# Check if WordPress is already installed by looking for wp-config.php
if [ -f "$WP_PATH/wp-config.php" ]; then
    echo "WordPress already configured."
else
    echo "Configuring WordPress..."

    # Extract WordPress files if latest.tar.gz exists and directory is empty/not fully set up
    if [ -f "$WP_PATH/latest.tar.gz" ]; then
        echo "Extracting WordPress..."
        tar -xzf $WP_PATH/latest.tar.gz --strip-components=1 -C $WP_PATH
        rm $WP_PATH/latest.tar.gz
        # Ensure www-data owns the files for PHP-FPM process
        chown -R www-data:www-data $WP_PATH
    else
        # If tarball isn't there, maybe volume was mounted with existing files?
        # We still need to ensure wp-config isn't there before proceeding.
        echo "WordPress archive not found, assuming files exist or checking config..."
        if [ -f "$WP_PATH/wp-config.php" ]; then
             echo "WordPress already configured (found wp-config.php)."
             exec "$@" # Skip setup and run the CMD (php-fpm)
        fi
        # If wp-config.php is not found even without the tarball, something is wrong or needs setup.
        # Attempt setup anyway, wp-cli will download if needed.
    fi

    # Ensure environment variables are set (Docker Compose should provide these)
    # Check for essential DB variables
    : "${WP_DB_NAME?Need to set WP_DB_NAME}"
    : "${WP_DB_USER?Need to set WP_DB_USER}"
    : "${WP_DB_PASSWORD?Need to set WP_DB_PASSWORD}"
    : "${WP_DB_HOST?Need to set WP_DB_HOST}"
    # Check for essential WP Admin variables
    : "${WP_URL?Need to set WP_URL}"
    : "${WP_TITLE?Need to set WP_TITLE}"
    : "${WP_ADMIN_USER?Need to set WP_ADMIN_USER}"
    : "${WP_ADMIN_PASSWORD?Need to set WP_ADMIN_PASSWORD}"
    : "${WP_ADMIN_EMAIL?Need to set WP_ADMIN_EMAIL}"
    # Check for essential WP User variables
    : "${WP_USER?Need to set WP_USER}"
    : "${WP_PASSWORD?Need to set WP_PASSWORD}"
    : "${WP_EMAIL?Need to set WP_EMAIL}"


    # Use wp-cli to create wp-config.php
    # --allow-root is necessary because we are running this script as root
    # It's generally safer to run wp-cli commands as the web server user (www-data),
    # but requires more complex user switching (su -s /bin/bash www-data -c "wp ...")
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbname="$WP_DB_NAME" \
        --dbuser="$WP_DB_USER" \
        --dbpass="$WP_DB_PASSWORD" \
        --dbhost="$WP_DB_HOST" \
        --path="$WP_PATH" \
        --force # Use --force to overwrite if somehow a stub exists

    # Install WordPress core
    # This command sets up the database tables and site options
    echo "Installing WordPress core..."
    wp core install --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path="$WP_PATH" \
        --skip-email # Avoid sending email on install

    # Create the additional user as specified in the subject
    echo "Creating WordPress user..."
    wp user create --allow-root \
        "$WP_USER" \
        "$WP_EMAIL" \
        --user_pass="$WP_PASSWORD" \
        --role=author \
        --path="$WP_PATH"

    # Set ownership again after wp-cli operations, just in case
    chown -R www-data:www-data $WP_PATH

    echo "WordPress configuration complete."

fi

# Execute the default command (CMD) passed to the entrypoint (e.g., php-fpm)
echo "Starting PHP-FPM..."
exec "$@"
