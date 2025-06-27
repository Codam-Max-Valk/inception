NAME = inception

all: up

up:
	@echo "Starting Docker Compose..."
	@docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@echo "Stopping and removing containers..."
	@docker compose -f srcs/docker-compose.yml down

clean:
	@echo "Stopping containers and removing volumes..."
	@docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	@echo "Removing all images..."
	@docker system prune -a -f
	@sudo rm -rf /home/mvalk/data/mariadb
	@sudo rm -rf /home/mvalk/data/wordpress

re: fclean all

.PHONY: all up down clean fclean re