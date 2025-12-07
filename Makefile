.PHONY: all up down clean re

all:
	docker compose -f srcs/docker-compose.yml up --build -d

up:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all

re: clean all
