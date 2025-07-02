#!/bin/bash

# Check timezone in the container
# This script helps verify the timezone configuration

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER_NAME="lazyvim"

printf "${BLUE}Checking timezone configuration...${NC}\n"
printf "\n"

if docker ps | grep -q "$CONTAINER_NAME"; then
    printf "${GREEN}Container timezone information:${NC}\n"
    printf "Current time in container:\n"
    docker exec "$CONTAINER_NAME" date
    printf "\n"
    printf "Timezone file:\n"
    docker exec "$CONTAINER_NAME" cat /etc/timezone 2>/dev/null || printf "Timezone file not found\n"
    printf "\n"
    printf "TZ environment variable:\n"
    docker exec "$CONTAINER_NAME" env | grep TZ || printf "TZ variable not set\n"
    printf "\n"
    printf "${GREEN}Local system time for comparison:${NC}\n"
    date
else
    printf "Container '%s' is not running.\n" "$CONTAINER_NAME"
    printf "Please start the container first with: make start\n"
    exit 1
fi
