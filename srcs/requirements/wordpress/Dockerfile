# srcs/requirements/wordpress/Dockerfile
FROM debian:bullseye

# ...existing code...
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y php7.4 php-fpm php-mysql curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html
COPY wordpress_src/ /var/www/html/
RUN chown -R www-data:www-data /var/www/html

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/setup.sh"]
