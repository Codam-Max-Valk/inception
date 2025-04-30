FROM debian:bullseye

# Install essential packages only
RUN apt-get update && apt-get install -y \
	php7.4-fpm \
	php7.4-mysql \
	php7.4-curl \
	php7.4-gd \
	php7.4-mbstring \
	php7.4-xml \
	mariadb-client \
	curl \
	netcat-openbsd \
	&& rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM for container usage
RUN mkdir -p /run/php && \
	chown www-data:www-data /run/php && \
	sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's|;listen.allowed_clients = 127.0.0.1|listen.allowed_clients = 0.0.0.0|g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's|;access.log = log/$pool.access.log|access.log = /proc/self/fd/2|g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's|;clear_env = no|clear_env = no|g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's|;catch_workers_output = yes|catch_workers_output = yes|g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's|error_log = /var/log/php7.4-fpm.log|error_log = /proc/self/fd/2|g' /etc/php/7.4/fpm/php-fpm.conf

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Setup WordPress directory
RUN mkdir -p /var/www/html && \
	chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

# Setup entrypoint
COPY tools/wp-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-config.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-config.sh"]