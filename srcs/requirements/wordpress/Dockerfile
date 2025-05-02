FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	php7.4-fpm \
	php7.4-mysql \
	php7.4-curl \
	php7.4-gd \
	php7.4-mbstring \
	php7.4-xml \
	php7.4-zip \
	php7.4-intl \
	php7.4-soap \
	mariadb-client \
	curl \
	netcat-openbsd \
	msmtp \
	msmtp-mta \
	procps \
	iputils-ping \
	net-tools \
	dnsutils \
	lsof \
	vim \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php /var/www/html \
	&& chown -R www-data:www-data /run/php /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN php-fpm7.4 -t && \
	grep -E 'listen|allowed_clients' /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR /var/www/html

COPY tools/wp-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-config.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-config.sh"]
CMD ["php-fpm7.4", "-F", "-R"]