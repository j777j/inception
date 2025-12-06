#!/bin/bash

service mysql start

# Check if the database already exists
if [ -d "/var/lib/mysql/$DB_NAME" ]
then
    echo "Database already exists"
else
    # Wait for mysql to start
    while ! mysqladmin ping -hlocalhost --silent; do
        sleep 1
    done

    # Create database and users
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \"${DB_NAME}\";"
    mysql -u root -e "CREATE USER IF NOT EXISTS \"${DB_USER}\"@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON \"${DB_NAME}\".* TO \"${DB_USER}\"@'%';"
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -u root -e "FLUSH PRIVILEGES;"
fi

# Shutdown mysql
mysqladmin -u root -p$DB_ROOT_PASS shutdown

# Start mysql in safe mode
exec mysqld_safe
