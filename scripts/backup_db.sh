#!/bin/bash
set -o pipefail # 🚨 Crucial: Catches errors inside pipes!

# Define the backup directory and filename with a timestamp
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/meridian_db_$TIMESTAMP.sql.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting database backup for Meridian Retail..."

# Use "postgres" user (matches your docker-compose config)
docker exec postgres pg_dump -U postgres --clean meridian_db | gzip > "$BACKUP_FILE"

# Check if the backup file was created and is not empty (> 0 bytes)
if [ -s "$BACKUP_FILE" ]; then
    echo "Backup successful! Saved to: $BACKUP_FILE"
else
    echo "Omo, backup failed!"
    rm -f "$BACKUP_FILE"
    exit 1
fi