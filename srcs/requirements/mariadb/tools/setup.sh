  GNU nano 8.4                                                                 setup.sh
#!/bin/bash

# 设置：如果任何命令失败，脚本立即退出
set -e

# 检查数据库是否已初始化
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDB: Starting initial setup..."

    # 1. 初始化 MariaDB 数据目录
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm

    # 2. 启动一个临时实例进行 SQL 配置（在后台启动）
    mysqld_safe --nowatch --skip-networking &

    # 3. 等待临时实例启动
    # echo "等待临时数据库启动..."
    while ! mysqladmin ping -h localhost --silent; do
        sleep 3
    done

    # 4. 执行 SQL 配置（创建数据库、用户、设置 root 密码）
    # echo "MariaDB: 配置数据库和用户..."

    # 修正点：创建 init.sql 文件，然后导入，这是最可靠的执行 SQL 方式;关键修正：添加用户从 localhost 连接的权限
    cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

    # 导入 SQL 文件（使用 root 和 localhost 连接）
    mysql -u root -h localhost --skip-password < /tmp/init.sql

    # 删除临时文件
    rm -f /tmp/init.sql

    # 5. 关闭临时实例
    # echo "关闭临时数据库..."
    mysqladmin -u root -p$DB_ROOT_PASS -h localhost shutdown

    # echo "MariaDB: 初始化完成。"
fi

# 6. 使用 exec 启动 MariaDB 主进程（成为 PID 1）
echo "MariaDB: Starting main service..."
exec /usr/sbin/mysqld --bind-address=0.0.0.0 --user=mysql
