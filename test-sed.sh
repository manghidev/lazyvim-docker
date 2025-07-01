#!/bin/bash

# Test script to verify sed commands work with timezone values

echo "Testing sed commands with timezone values..."

# Create a test docker-compose.yml
cat > test-compose.yml << 'EOF'
services:
  test:
    environment:
      - TIMEZONE: America/New_York
      - TZ=America/New_York
EOF

echo "Original file:"
cat test-compose.yml

echo ""
echo "Testing with America/Chihuahua..."

# Test with problematic timezone
timezone="America/Chihuahua"

# Using pipe delimiters (safe)
sed -i.bak "s|TIMEZONE: .*|TIMEZONE: $timezone|" test-compose.yml
sed -i.bak2 "s|TZ=.*|TZ=$timezone|" test-compose.yml

echo "After sed commands:"
cat test-compose.yml

echo ""
echo "✅ sed commands work correctly with pipe delimiters"

# Cleanup
rm -f test-compose.yml test-compose.yml.bak test-compose.yml.bak2
