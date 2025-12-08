#!/bin/bash

set -e

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDB: Starting initial setup..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm
fi

if ! mysql -h localhost -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT 1" &> /dev/null; then

    echo "MariaDB: Configuring users and databases..."

    mysqld_safe --nowatch --skip-networking &
    MYSQLD_PID=$!

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

    cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%' WITH GRANT OPTION;

CREATE USER IF NOT EXISTS \`${WP_USER}\`@'%' IDENTIFIED BY '${WP_USER_PASS}';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${DB_NAME}\`.* TO \`${WP_USER}\`@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

FLUSH PRIVILEGES;
EOF

    mysql -u root -h localhost --skip-password < /tmp/init.sql || exit 1

    rm -f /tmp/init.sql

    mysqladmin -u root -p$DB_ROOT_PASS -h localhost shutdown
    wait $MYSQLD_PID 2>/dev/null || true

fi

echo "MariaDB: Starting main service..."
exec /usr/sbin/mysqld --bind-address=0.0.0.0 --user=mysql
