.PHONY: all up down clean re extract-wordpress

extract-wordpress:
        mkdir -p /home/juwang/data/wordpress /home/juwang/data/mariadb
        sudo tar -xzf srcs/requirements/wordpress/files/latest.tar.gz -C /home/juwang/data/wordpress --strip-components=1
        sudo chown -R www-data:www-data /home/juwang/data/wordpress

        sudo chown -R mysql:mysql /home/juwang/data/mariadb
        sudo chmod -R 777 /home/juwang/data/mariadb

all: extract-wordpress
        docker compose -f srcs/docker-compose.yml up --build -d

up:
        docker compose -f srcs/docker-compose.yml up -d

down:
        docker compose -f srcs/docker-compose.yml down

clean:
        docker compose -f srcs/docker-compose.yml down -v --rmi all

re: clean all
