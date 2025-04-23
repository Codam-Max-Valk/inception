#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the database directory is empty (first run)
if [ ! "$(ls -A /var/lib/mysql)" ]; then
    # Initialize the MariaDB data directory
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    # Start MariaDB for initialization
    echo "Starting MariaDB for initial setup..."
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

# Create database
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

# Create user and grant privileges
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

# Update root password and allow remote connections
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    echo "MariaDB initialization completed"
else
    echo "MariaDB data directory already initialized"
fi

# Start MariaDB server
echo "Starting MariaDB server..."
exec mysqld --user=mysql
