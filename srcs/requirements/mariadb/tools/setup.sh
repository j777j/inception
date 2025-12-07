#!/bin/bash

# 检查数据库是否已初始化 (通过检查 mysql 系统数据库文件是否存在)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDB: Starting initial setup..."

    # 1. 初始化 MariaDB 数据目录
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm

    # 2. 启动一个临时实例进行 SQL 配置（必须在后台）
    mysqld_safe --nowatch --skip-networking &

    # 3. 等待临时实例启动
    while ! mysqladmin ping -h 127.0.0.1 --silent; do
        sleep 3
    done

    # 4. 执行 SQL 配置（创建数据库、用户、设置 root 密码）
    echo "MariaDB: Configuring database and users..."

    # 注意：使用 root 用户和 --skip-password 进行初始连接
    mysql -u root --skip-password -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
    mysql -u root --skip-password -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root --skip-password -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';"
    mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -u root --skip-password -e "FLUSH PRIVILEGES;"

    # 5. 关闭临时实例
    echo "MariaDB: Shutting down temporary instance..."
    mysqladmin -u root -p$DB_ROOT_PASS shutdown

    echo "MariaDB: Initialization complete."
fi

# 6. 使用 exec 启动 MariaDB 主进程（成为 PID 1）
echo "MariaDB: Starting main service..."
exec /usr/sbin/mysqld --bind-address=0.0.0.0 --user=mysql
