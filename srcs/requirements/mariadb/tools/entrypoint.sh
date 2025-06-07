#!/bin/bash
set -e

# CRITICAL FIX: Unset MySQL environment variables that affect client connections
# These are causing the client to try connecting to 'mariadb' instead of socket
unset MYSQL_TCP_PORT

# Set database directory
DATADIR="/var/lib/mysql"

echo "=== MariaDB initialization starting ==="

# Create needed directories
mkdir -p "$DATADIR" /run/mysqld /var/log/mysql
chown -R mysql:mysql "$DATADIR" /run/mysqld /var/log/mysql
chmod 777 /var/log/mysql

# Initialize database if needed
if [ ! -d "$DATADIR/mysql" ]; then
    echo "=== Initializing fresh MariaDB data directory ==="
    mysql_install_db --user=mysql --datadir="$DATADIR"
    
    # Start temporary server for initialization
    echo "=== Starting temporary MariaDB server ==="
    mysqld --user=mysql --datadir="$DATADIR" --socket=/run/mysqld/mysqld.sock --skip-networking &
    pid="$!"
    
    # Wait for server to start
    echo "=== Waiting for temporary server to start ==="
    for i in {30..0}; do
        if mysqladmin --socket=/run/mysqld/mysqld.sock ping &>/dev/null; then
            echo "=== Temporary server is up ==="
            break
        fi
        echo "=== Still waiting for server... ($i) ==="
        sleep 1
    done
    
    # Initial setup - FORCE localhost connection with -h127.0.0.1
    echo "=== Creating database and user ==="
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -hlocalhost --protocol=socket --socket=/run/mysqld/mysqld.sock << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Verify the user was created
    echo "=== Verifying database and user ==="
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -hlocalhost --protocol=socket --socket=/run/mysqld/mysqld.sock -e "SELECT User, Host FROM mysql.user WHERE User='${MYSQL_USER}';"
    
    # Shutdown temporary server
    echo "=== Shutting down temporary server ==="
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} -hlocalhost --protocol=socket --socket=/run/mysqld/mysqld.sock shutdown
    wait "$pid"
    echo "=== Initialization complete ==="
else
    echo "=== Using existing database files ==="
    
    # Start temporary server for verification
    echo "=== Starting temporary MariaDB server ==="
    mysqld --user=mysql --datadir="$DATADIR" --socket=/run/mysqld/mysqld.sock --skip-networking &
    pid="$!"
    
    # Wait for server to start
    echo "=== Waiting for temporary server to start ==="
    for i in {30..0}; do
        if mysqladmin --socket=/run/mysqld/mysqld.sock ping &>/dev/null; then
            echo "=== Temporary server is up ==="
            break
        fi
        echo "=== Still waiting for server... ($i) ==="
        sleep 1
    done
    
    # Create database and user - FORCE localhost connection
    echo "=== Setting up database and user ==="
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -hlocalhost --protocol=socket --socket=/run/mysqld/mysqld.sock << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Shutdown temporary server
    echo "=== Shutting down temporary server ==="
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} -hlocalhost --protocol=socket --socket=/run/mysqld/mysqld.sock shutdown
    wait "$pid"
fi

# Create simple healthcheck file
echo "#!/bin/bash
mysqladmin ping" > /usr/local/bin/healthcheck.sh
chmod +x /usr/local/bin/healthcheck.sh

echo "=== Starting MariaDB server in foreground ==="

exec "$@"

# #!/bin/bash

# set -e

# DATADIR="/var/lib/mysql"
# INIT_MARKER_FILE="${DATADIR}/.db_initialized"

# log() {
#   echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1"
# }

# for var in DB_ROOT_PASSWORD DB_NAME DB_USER DB_PASSWORD; do
#   if [ -z "${!var}" ]; then
#     log "ERROR: Missing required environment variable: $var"
#     exit 1
#   fi
# done

# if [ ! -f "${INIT_MARKER_FILE}" ]; then
#   log "Database directory appears uninitialized. Running initial setup..."

#   mariadb-install-db --user=mysql --datadir=${DATADIR}
  
#   mysqld --user=mysql --datadir=${DATADIR} --bind-address=127.0.0.1 &
#   pid="$!"
  
#   for i in {1..30}; do
#     if mysqladmin ping --silent; then
#       break
#     fi
#     log "Waiting for temporary server... ($i/30)"
#     sleep 1
#   done
  
#   mysql --user=root <<-EOSQL
#     ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
#     DELETE FROM mysql.user WHERE User='';
#     DROP DATABASE IF EXISTS test;
#     CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
#     CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
#     GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
#     FLUSH PRIVILEGES;
# EOSQL
  
#   mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown || kill "$pid"
#   wait "$pid"
  
#   touch "${INIT_MARKER_FILE}"
#   chown mysql:mysql "${INIT_MARKER_FILE}"
#   log "Initialization complete."
# else
#   log "Database directory already initialized."
# fi

# log "Starting MariaDB server..."
# exec "$@"