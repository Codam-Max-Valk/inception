# Base image: Use Debian Bullseye (penultimate stable at time of subject likely)
FROM debian:bullseye

# Arguments (can be overridden during build, but primarily for documentation here)
# Runtime configuration will use environment variables passed by docker-compose
ARG WP_DB_NAME
ARG WP_DB_USER
ARG WP_DB_PASSWORD
ARG WP_DB_HOST

ARG WP_URL
ARG WP_TITLE
ARG WP_ADMIN_USER
ARG WP_ADMIN_PASSWORD
ARG WP_ADMIN_EMAIL

ARG WP_USER
ARG WP_PASSWORD
ARG WP_EMAIL

# Install prerequisites: PHP-FPM, extensions, DB client, download tools
# Using PHP 7.4 which is the default in Debian Bullseye
RUN apt-get update && apt-get install -y \
	php7.4-fpm \
	php7.4-gd \
	php7.4-mysqli \
	php7.4-zip \
	mariadb-client \
	wget \
	curl \
	sendmail \
	# Clean up apt cache
	&& rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on port 9000 for network connections
# The default www.conf listens on a Unix socket (/run/php/php7.4-fpm.sock)
# We change it to listen on all interfaces, port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf

# Download wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Create WordPress directory and set working directory
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Download WordPress core files (without extracting yet, entrypoint will handle it)
# This allows the entrypoint to check if volume is empty or already populated
RUN curl -O https://wordpress.org/latest.tar.gz

# Copy the configuration script into the container
COPY ./tools/wp-config.sh /usr/local/bin/wp-config.sh
RUN chmod +x /usr/local/bin/wp-config.sh

# Ensure the PHP-FPM log directory exists and is writable by www-data
RUN mkdir -p /var/log/php-fpm \
	&& chown www-data:www-data /var/log/php-fpm

# Ensure the PHP run directory exists (though we aren't using the socket)
RUN mkdir -p /run/php \
	&& chown www-data:www-data /run/php

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Set the entrypoint script
ENTRYPOINT ["/usr/local/bin/wp-config.sh"]

# Default command to run (PHP-FPM in the foreground)
# The -F flag ensures it doesn't daemonize and stays as the main container process
CMD ["php-fpm7.4", "-F"]
