FROM alpine:3.17

RUN apk update && apk add --no-cache mariadb mariadb-client

# Create directories and set permissions for MariaDB to operate
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld && \
	mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# Copy the MariaDB configuration file
COPY conf/my.conf /etc/my.cnf

# Copy an entrypoint script that initializes the database if needed
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["/entrypoint.sh"]