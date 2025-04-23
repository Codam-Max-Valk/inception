#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.

WP_PATH="/var/www/html"
# Use environment variables passed by docker-compose
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASSWORD_FILE="${MYSQL_PASSWORD_FILE}"
DB_HOST="${MYSQL_HOST:-mariadb}" # Default to mariadb if not set
DB_PORT="3306" # Default MariaDB/MySQL port

WP_ADMIN_USER="${WP_ADMIN_USER}"
WP_ADMIN_PASSWORD_FILE="${WP_ADMIN_PASSWORD_FILE}"
WP_SITE_TITLE="${WP_SITE_TITLE}"
DOMAIN_NAME="${DOMAIN_NAME:-localhost}" # Get domain name from env

# Function to check if DB is ready
wait_for_db() {
  echo "Waiting for database at $DB_HOST:$DB_PORT..."
  # Loop until mysqladmin ping succeeds
  # Note: Requires mariadb-client installed in the image
  # Note: Reading password from file securely
  while ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" --silent --password=$(cat "$DB_PASSWORD_FILE"); do
    sleep 1
  done
  echo "Database is up!"
}

# Check if WordPress is already installed (e.g., volume persistence)
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "WordPress not found in $WP_PATH. Starting installation..."

  # Wait for the database to be ready before proceeding
  wait_for_db

  echo "Downloading WordPress..."
  wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz
  echo "Extracting WordPress..."
  tar -xzf /tmp/latest.tar.gz -C /tmp
  # Copy only the contents of the wordpress directory
  cp -r /tmp/wordpress/* "$WP_PATH/"
  # Clean up downloaded/extracted files
  rm /tmp/latest.tar.gz
  rm -rf /tmp/wordpress

  echo "Setting up wp-config.php..."
  # Use wp-cli to generate wp-config.php for better security (random salts)
  # Download wp-cli
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp

  # Create wp-config.php
  # Note: --force is used in case a sample file exists
  wp config create --dbname="$DB_NAME" \
                   --dbuser="$DB_USER" \
                   --dbpass="$(cat "$DB_PASSWORD_FILE")" \
                   --dbhost="$DB_HOST:$DB_PORT" \
                   --path="$WP_PATH" \
                   --force \
                   --allow-root # Necessary if running as root, adjust if using a different user

  echo "Installing WordPress core..."
  # Install WordPress
  wp core install --url="https://${DOMAIN_NAME}" \
                  --title="$WP_SITE_TITLE" \
                  --admin_user="$WP_ADMIN_USER" \
                  --admin_password="$(cat "$WP_ADMIN_PASSWORD_FILE")" \
                  --admin_email="admin@${DOMAIN_NAME}" \
                  --path="$WP_PATH" \
                  --skip-email \
                  --allow-root # Necessary if running as root

  echo "Setting ownership for web server..."
  # Set ownership to the user running php-fpm (often 'nobody' or 'www-data' in Alpine/Debian)
  # Check your php-fpm pool configuration (/etc/php81/php-fpm.d/www.conf) for the correct user/group
  chown -R nobody:nobody "$WP_PATH"

  echo "WordPress installation complete."

else
    echo "WordPress already configured in $WP_PATH."
    # Ensure wp-cli is available even if WP is already installed
    if [ ! -f /usr/local/bin/wp ]; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    fi
    # Ensure correct ownership on existing volume
    chown -R nobody:nobody "$WP_PATH"
fi

echo "Starting PHP-FPM..."
# Execute the command passed to the entrypoint (CMD in Dockerfile)
exec "$@"
