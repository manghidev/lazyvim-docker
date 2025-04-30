# Volume name and backup directory
VOLUME_NAME="lazyvim-docker_develop-data"
BACKUP_DIR="./develop-user-data"

echo "=== Starting restoration process ==="

# Step 1: Execute the init.sh script to initialize the environment
echo "=== Executing init.sh to initialize the environment ==="
bash ./init.sh

# Step 2: Check if the backup directory exists
if [ ! -d $BACKUP_DIR ]; then
    echo "Error: The backup directory $BACKUP_DIR does not exist. Cannot restore."
    exit 1
fi

# Step 3: Check if the backup directory is empty
if [ -z "$(ls -A $BACKUP_DIR)" ]; then
    echo "Error: The backup directory $BACKUP_DIR is empty. Cannot restore."
    exit 1
fi

# Step 4: Restore only the specified files and folders to the volume
echo "=== Restoring data to volume $VOLUME_NAME ==="
docker run --rm \
    -v $VOLUME_NAME:/data \
    -v $(pwd)/$BACKUP_DIR:/backup \
    alpine sh -c "
        cd /backup && \
        cp -r .zshrc .p10k.zsh .config /data/"

# Step 6: Fix permissions specifically for .config/nvim
echo "=== Fixing permissions for .config/nvim ==="
docker run --rm \
    -v $VOLUME_NAME:/data \
    alpine sh -c "
        chown -R 1000:1000 /data/.config/nvim && \
        chmod -R u+rwX /data/.config/nvim"

echo "=== Restoration completed. Data has been copied to volume $VOLUME_NAME ==="