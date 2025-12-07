# srcs/requirements/mariadb/Dockerfile
FROM debian:bookworm

# 安装 MariaDB
RUN apt-get update && apt-get install -y mariadb-client mariadb-common mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# 设置权限和复制脚本
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY ./conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

# 设置 ENTRYPOINT 为您的 setup.sh
ENTRYPOINT ["/usr/local/bin/setup.sh"]
