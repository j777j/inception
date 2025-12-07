# srcs/requirements/mariadb/Dockerfile
FROM debian:bookworm

# Install MariaDB
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-client mariadb-common mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Create necessary MariaDB directories and fix permissions
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy config
COPY ./conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy and allow script
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
