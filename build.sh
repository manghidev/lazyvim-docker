echo "Cleaning up the environment"
docker compose down --rmi all

echo "Pulling the latest images"
docker compose pull

echo "Rebuilding the container"
docker compose build --no-cache

echo "Starting the container"
docker compose up --force-recreate -d

echo "Opening a shell in the container"
docker exec -it lazyvim zsh

echo "Process completed. Container is running"
