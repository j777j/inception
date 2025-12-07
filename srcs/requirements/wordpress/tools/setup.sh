#!/bin/bash

# Wait for the database to be ready
while ! mysqladmin ping -h mariadb -u $DB_USER -p$DB_PASS --silent; do
    sleep 1
done

# Configure and install WordPress if it's not already installed
if ! $(wp core is-installed); then
    wp config create --dbname=$DB_NAME \
                     --dbuser=$DB_USER \
                     --dbpass=$DB_PASS \
                     --dbhost=mariadb \
                     --allow-root

    wp core install --url=$DOMAIN_NAME \
                    --title="Inception" \
                    --admin_user=$WP_ADMIN_USER \
                    --admin_password=$WP_ADMIN_PASS \
                    --admin_email=$WP_ADMIN_EMAIL \
                    --allow-root

    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASS --allow-root
fi

# Start PHP-FPM
exec /usr/sbin/php-fpm7.4 -F
