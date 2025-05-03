echo "Starting the container"
docker compose up -d

echo "Enter to the lazyvim container"
docker exec -it lazyvim zsh
