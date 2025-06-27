#!/bin/bash

# Check timezone in the container
# This script helps verify the timezone configuration

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER_NAME="lazyvim"

echo -e "${BLUE}Checking timezone configuration...${NC}"
echo ""

if docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${GREEN}Container timezone information:${NC}"
    echo "Current time in container:"
    docker exec "$CONTAINER_NAME" date
    echo ""
    echo "Timezone file:"
    docker exec "$CONTAINER_NAME" cat /etc/timezone 2>/dev/null || echo "Timezone file not found"
    echo ""
    echo "TZ environment variable:"
    docker exec "$CONTAINER_NAME" env | grep TZ || echo "TZ variable not set"
    echo ""
    echo -e "${GREEN}Local system time for comparison:${NC}"
    date
else
    echo "Container '$CONTAINER_NAME' is not running."
    echo "Please start the container first with: make start"
    exit 1
fi
