# !/bin/sh

# DB_NAME="${MYSQL_DATABASE}"
# DB_USER="${MYSQL_USER}"
# DB_PASSWORD="$(cat "${MYSQL_PASSWORD_FILE}")"
# ROOT_PASSWORD="$(cat "${MYSQL_ROOT_PASSWORD_FILE}")"

# service mysql start 2>/dev/null || true

# mysql_install_db --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock


# mysql_safe --datadir="/var/lib/mysql" &
# sleep 5

# echo "CREATE DATABASE IF NOT EXISTS $DB_NAME;`" | mysql -u root
# echo "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';" | mysql -u root
# echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';" | mysql -u root
# echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';" | mysql -u root
# echo "FLUSH PRIVILEGES;" | mysql -u root

# killall mysqld
# sleep 2
