#!/bin/bash
set -e

# NRO Offline Server - Docker Entrypoint Script
# This script initializes the container environment

echo "========================================"
echo "  NRO Offline Server - Docker Container"
echo "========================================"
echo ""

# Display environment information
echo "[INFO] Container started at: $(date)"
echo "[INFO] User: $(whoami) (UID: $(id -u), GID: $(id -g))"
echo "[INFO] Java version:"
java -version 2>&1 | head -n 1
echo "[INFO] Python version: $(python3 --version)"
echo ""

# Check if data directories exist
echo "[INFO] Checking data directories..."
if [ ! -d "/app/NRO-Server" ]; then
    echo "[WARN] /app/NRO-Server not found - will be created during setup"
fi

if [ ! -d "/app/data" ]; then
    echo "[INFO] Creating /app/data directory"
    mkdir -p /app/data
fi

# Display database connection info
echo ""
echo "[INFO] Database connection:"
echo "  Host: ${DB_HOST:-nro-mysql}"
echo "  Port: ${DB_PORT:-3306}"
echo "  Database: ${DB_NAME:-nro}"
echo "  User: ${DB_USER:-nro_user}"
echo ""

# Wait for MySQL to be ready
if [ -n "$DB_HOST" ]; then
    echo "[INFO] Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."
    max_attempts=30
    attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if nc -z "$DB_HOST" "${DB_PORT:-3306}" 2>/dev/null; then
            echo "[OK] MySQL is ready!"
            break
        fi

        attempt=$((attempt + 1))
        echo "[WAIT] Waiting for MySQL... (attempt $attempt/$max_attempts)"
        sleep 2
    done

    if [ $attempt -eq $max_attempts ]; then
        echo "[ERROR] MySQL did not become ready in time"
    fi
fi

echo ""
echo "========================================"
echo "  Container Ready!"
echo "========================================"
echo ""
echo "To set up the NRO server, run:"
echo "  python3 nro_deobfuscated.py"
echo ""
echo "Available commands:"
echo "  - python3 nro_deobfuscated.py  # Setup menu"
echo "  - bash NRO-Server/start.sh     # Start game server (after setup)"
echo "  - ls -la NRO-Server/           # View server files"
echo ""

# Execute the command passed to docker run
exec "$@"
