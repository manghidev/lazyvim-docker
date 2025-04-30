# Volume name and backup directory
VOLUME_NAME="lazyvim-docker_develop-data"
BACKUP_DIR="./develop-user-data"

echo "=== Starting selective backup of volume $VOLUME_NAME ==="

# Create the backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Copy only the specified files and folders from the volume to the backup directory
docker run --rm \
    -v $VOLUME_NAME:/data \
    -v $(pwd)/$BACKUP_DIR:/backup \
    alpine sh -c "
        cd /data && \
        tar -cf - \
            .zshrc \
            .p10k.zsh \
            .config | tar -xf - -C /backup/"

echo "=== Backup completed. Selected data has been saved to $BACKUP_DIR ==="

# Clean up the environment
echo "=== Cleaning up the environment ==="
docker compose down --rmi all

# Rebuild the container
echo "=== Rebuilding the container ==="
docker compose build --no-cache

# Start the container
echo "=== Starting the container ==="
docker compose up --force-recreate -d

echo "=== Process completed. Container is running ==="