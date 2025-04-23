NAME = inception

all: up

up:
	@echo "Starting Docker Compose..."
	@docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@echo "Stopping and removing containers..."
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@echo "Removing volumes..."
	@docker volume rm -f $(shell docker volume ls -q | grep mariadb_data) || true
	@docker volume rm -f $(shell docker volume ls -q | grep wordpress_data) || true

fclean: clean
	@echo "Removing all images..."
	@docker image prune -a -f

re: fclean all

.PHONY: all up down clean fclean re
