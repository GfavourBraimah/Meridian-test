#!/bin/bash

# Define the backup directory and filename with a timestamp
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/meridian_db_$TIMESTAMP.sql.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting database backup for Meridian Retail..."

# Execute pg_dump inside the postgres container, include --clean to make restores easier
docker exec postgres pg_dump -U meridian --clean meridian_db | gzip > "$BACKUP_FILE"

# Check if the backup file was created and is not empty
if [ -s "$BACKUP_FILE" ]; then
    echo "Backup successful! Saved to: $BACKUP_FILE"
else
    echo "Omo, backup failed!"
    rm -f "$BACKUP_FILE"
    exit 1
fi