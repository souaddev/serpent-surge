#!/bin/bash

# Current date and time
date=$(date '+%Y-%m-%d_%H-%M')

# Directories
BACKUP_DIR="/opt/dbbackup/backups"
ARCHIVE_DIR="/opt/dbbackup/backups/archives"
LOG_FILE="/var/log/dbbackup/dbbackup.log"

# Create directories if they don't exist
mkdir -p "$BACKUP_DIR" "$ARCHIVE_DIR" "$(dirname "$LOG_FILE")"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Backup database
backup_db() {
    local db_name=$1
    local output="$BACKUP_DIR/${date}_${db_name}.sql"
    
    if mysqldump -u dbbackup "$db_name" > "$output" 2>/dev/null; then
        log "Database $db_name backed up to $output"
    else
        log "ERROR: Failed to backup database $db_name"
        exit 1
    fi
}

# Backup table
backup_table() {
    local db_name=$1
    local table_name=$2
    local output="$BACKUP_DIR/${date}_${db_name}_${table_name}.sql"
    
    if mysqldump -u dbbackup "$db_name" "$table_name" > "$output" 2>/dev/null; then
        log "Table $db_name.$table_name backed up to $output"
    else
        log "ERROR: Failed to backup table $db_name.$table_name"
        exit 1
    fi
}

# Archive backups
archive_backups() {
    local archive_name="${date}_backup.tar.gz"
    
    # Check if there are SQL files to archive
    if ! ls "$BACKUP_DIR"/*.sql >/dev/null 2>&1; then
        log "No SQL files to archive"
        return
    fi
    
    # Create archive
    if tar -czf "$ARCHIVE_DIR/$archive_name" -C "$BACKUP_DIR" *.sql 2>/dev/null; then
        log "Archive $archive_name created"
        
        # Remove original SQL files
        rm -f "$BACKUP_DIR"/*.sql
        log "Original .sql files removed after archive"
        
        # Keep only the latest 3 archives
        local archive_count
        archive_count=$(ls -1 "$ARCHIVE_DIR"/*.tar.gz 2>/dev/null | wc -l)
        if [ "$archive_count" -gt 3 ]; then
            oldest_archive=$(ls -t "$ARCHIVE_DIR"/*.tar.gz | tail -n 1)
            rm -f "$oldest_archive"
            log "Oldest archive $(basename "$oldest_archive") deleted. Only 3 archives kept"
        fi
    else
        log "ERROR: Failed to create archive"
        exit 1
    fi
}

# List available archives
list_archives() {
    printf "Date\t\tSize\n"
    for file in "$ARCHIVE_DIR"/*.tar.gz; do
        if [ -f "$file" ]; then
            size=$(du -h "$file" | cut -f1)
            file_date=$(basename "$file" | cut -d'_' -f1 | sed 's/-/./g')
            printf "%s\t%s\n" "$file_date" "$size"
        fi
    done
}

# Argument parser
case "$1" in
    db)
        backup_db "$2"
        ;;
    table)
        backup_table "$2" "$3"
        ;;
    archive)
        archive_backups
        ;;
    list)
        list_archives
        ;;
    *)
        echo "Usage: $0 db <db_name> | table <db_name> <table_name> | archive | list"
        ;;
esac

