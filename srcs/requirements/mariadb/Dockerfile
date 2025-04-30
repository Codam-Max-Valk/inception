FROM debian:bullseye

# Install MariaDB server and client with minimal output
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	mariadb-server \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /var/run/mysqld /var/log/mysql && \
	chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /var/log/mysql && \
	chmod 777 /var/run/mysqld /var/log/mysql

# Copy custom MariaDB configuration
COPY conf/my.conf /etc/mysql/mariadb.conf.d/99-custom.cnf

# Copy entrypoint script and make it executable
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

# Use simple entrypoint (no CMD needed as it's included in entrypoint)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]