#!/bin/sh
set -e

# Data directory
DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

# Check if initialization is needed (basic check)
# The initialization logic only runs if the 'mysql' subdirectory doesn't exist
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    # Ensure directories exist and have correct permissions
    mkdir -p /run/mysqld "$DATADIR"
    chown -R mysql:mysql /run/mysqld "$DATADIR"

    # Initialize database directory
    echo "Running mysql_install_db..."
    mysql_install_db --user=mysql --basedir=/usr --datadir="$DATADIR" --rpm > /dev/null
    echo "mysql_install_db completed."

    echo "Starting temporary server for setup..."
    # Start mysqld in background temporarily for initialization
    mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
    pid="$!"

    # Wait for server to be ready via socket
    max_tries=30
    current_try=0
    echo "Waiting for temporary server socket $SOCKET..."
    while ! mysqladmin ping --socket="$SOCKET" --silent --wait=1 && [ "$current_try" -lt "$max_tries" ]; do
        # Removed sleep, --wait=1 handles waiting
        current_try=$((current_try + 1))
        # Optional: Add a small sleep if --wait=1 isn't sufficient on its own
        # sleep 1
    done

    if [ "$current_try" -eq "$max_tries" ]; then
        echo >&2 "MariaDB temporary server failed to start."
        # Attempt to capture logs if possible
        # Check standard error/log locations if mysqld logged anything
        exit 1
    fi
    echo "Temporary server started."

    # --- Run Initialization SQL ---
    # Read secrets from files specified in docker-compose environment
    DB_NAME="${MYSQL_DATABASE}"
    DB_USER="${MYSQL_USER}"
    # Ensure the secret files exist before trying to read them
    if [ ! -f "${MYSQL_PASSWORD_FILE}" ]; then echo >&2 "Error: MYSQL_PASSWORD_FILE not found at ${MYSQL_PASSWORD_FILE}"; exit 1; fi
    if [ ! -f "${MYSQL_ROOT_PASSWORD_FILE}" ]; then echo >&2 "Error: MYSQL_ROOT_PASSWORD_FILE not found at ${MYSQL_ROOT_PASSWORD_FILE}"; exit 1; fi

    DB_PASSWORD=$(cat "${MYSQL_PASSWORD_FILE}")
    ROOT_PASSWORD=$(cat "${MYSQL_ROOT_PASSWORD_FILE}")

    echo "Running initialization SQL via socket $SOCKET..."
    # --- FIX: Added --socket="$SOCKET" to connect locally ---
    mysql --socket="$SOCKET" <<-EOSQL
        -- Set root password FIRST for security
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
        -- Create database if it doesn't exist
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        -- Create user if it doesn't exist and set password
        -- Use '%' for host to allow connections from other containers
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        -- Grant privileges to the user on the database
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        -- Apply changes
        FLUSH PRIVILEGES;
EOSQL
    echo "Initialization SQL executed."

    # Stop the temporary server
    echo "Stopping temporary server..."
    if ! kill -s TERM "$pid"; then
        echo >&2 "Failed to stop temporary MariaDB server."
        # exit 1 # Decide if this should be fatal
    fi
    # Wait for it to stop
    wait "$pid"
    echo "Temporary server stopped."

else
    echo "MariaDB data directory already initialized. Skipping initialization."
    # Ensure permissions are still correct on restart
    chown -R mysql:mysql /run/mysqld "$DATADIR"
fi

echo "Starting MariaDB server..."
# --- FIX: Added this line to start the actual server ---
# Start the main MariaDB server process, listening on network (default config)
exec mysqld --user=mysql --console --datadir="$DATADIR" --socket="$SOCKET"
