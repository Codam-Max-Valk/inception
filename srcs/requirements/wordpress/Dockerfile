FROM debian:latest

# Install necessary packages including curl and wget for the setup script
# mariadb-client is needed for the wait_for_db function using mysqladmin
RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y \
	php-fpm

CMD ["php-fpm8.2", "-F"]
