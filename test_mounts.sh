#!/bin/bash

# Test file for get_current_mounts function
source scripts/configure.sh

# Skip main execution by overriding it
main() {
    echo "Testing get_current_mounts function..."
    get_current_mounts "true"
}

main
