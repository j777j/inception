#!/bin/bash

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDB: Starting initial setup..."

    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm

    mysqld_safe --nowatch --skip-networking &
    MYSQLD_PID=$!

    # Wait for MySQL to be ready
    MAX_RETRIES=30
    RETRY_COUNT=0
    while ! mysqladmin ping -h localhost --silent 2>/dev/null; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
            echo "ERROR: MariaDB failed to start within timeout"
            kill $MYSQLD_PID 2>/dev/null || true
            exit 1
        fi
        sleep 1
    done

    echo "MariaDB: Database is ready, running initialization..."

    cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'wordpress.srcs_inception' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'wordpress.srcs_inception';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

    # Execute the SQL script
    if ! mysql -u root -h localhost --skip-password < /tmp/init.sql; then
        echo "ERROR: Failed to execute initialization SQL"
        rm -f /tmp/init.sql
        kill $MYSQLD_PID 2>/dev/null || true
        exit 1
    fi

    rm -f /tmp/init.sql

    echo "MariaDB: Initialization complete, shutting down temporary instance..."
    mysqladmin -u root -p$DB_ROOT_PASS -h localhost shutdown

    # Wait for the temporary instance to shut down
    wait $MYSQLD_PID 2>/dev/null || true

    echo "MariaDB: Temporary instance shut down successfully"
fi

echo "MariaDB: Starting main service..."
exec /usr/sbin/mysqld --bind-address=0.0.0.0 --user=mysql
