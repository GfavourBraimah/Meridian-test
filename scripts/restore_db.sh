#!/bin/bash

# Check if the user provided a backup file argument
if [ -z "$1" ]; then
    echo "Usage: ./restore_db.sh <path_to_backup_file.sql.gz>"
    exit 1
fi

BACKUP_FILE="$1"

# Verify the file actually exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found at $BACKUP_FILE"
    exit 1
fi

echo "Restoring Meridian database from $BACKUP_FILE..."

# Unzip the backup file on the fly and pipe it into the postgres container
gunzip -c "$BACKUP_FILE" | docker exec -i postgres psql -U meridian -d meridian_db

echo "Restore completed successfully"