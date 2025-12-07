#!/bin/bash

# 1. Start MariaDB daemon for initialization (in background)
mysqld_safe --nowatch --skip-networking &

# 2. Wait for MariaDB to be ready
echo "Waiting for MariaDB to start for initialization..."
while ! mysqladmin ping -h 127.0.0.1 -u root --silent; do
    sleep 5
done
echo "MariaDB is ready for initialization."

# 3. Check and execute database initialization
if [ -d "/var/lib/mysql/$DB_NAME" ]
then
    echo "Database already exists. Skipping initialization."
else
    echo "Database does not exist. Starting setup..."

    # Use --skip-password for initial root connection
    # Create database and users
    mysql -u root --skip-password -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
    mysql -u root --skip-password -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root --skip-password -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';"
    # Set root password
    mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -u root --skip-password -e "FLUSH PRIVILEGES;"
fi

# 4. Shutdown the initialization instance (use the new password)
mysqladmin -u root -p$DB_ROOT_PASS shutdown

# 5. Start MariaDB as the container's main process (PID 1)
exec mysqld_safe --no-watch
