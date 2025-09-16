#!/bin/bash

# PostgreSQL Backup Script
# Backs up n8n and postgres databases
# Keeps only the last 3 backups
# Run every 2 hours via cron

# Check if script is being run for setup
if [ "$1" == "setup" ]; then
    echo "Setting up PostgreSQL backup system..."
    
    # Install cron if not already installed
    if ! command -v crontab &> /dev/null; then
        echo "Installing cron..."
        sudo apt-get update
        sudo apt-get install -y cron
        sudo systemctl enable cron
        sudo systemctl start cron
    else
        echo "Cron is already installed."
    fi
    
    # Set up cron job to run this script every 2 hours
    SCRIPT_PATH=$(realpath "$0")
    SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
    
    # Create temporary file with current crontab
    crontab -l > /tmp/current_crontab 2>/dev/null || touch /tmp/current_crontab
    
    # Check if the job already exists
    if grep -q "$SCRIPT_PATH" /tmp/current_crontab; then
        echo "Cron job already exists."
    else
        # Add new job to crontab
        echo "0 */2 * * * cd $SCRIPT_DIR && $SCRIPT_PATH" >> /tmp/current_crontab
        crontab /tmp/current_crontab
        echo "Cron job added. Backup will run every 2 hours."
    fi
    
    # Clean up
    rm /tmp/current_crontab
    
    # Create first backup
    echo "Creating initial backup..."
    $SCRIPT_PATH
    
    echo "Setup completed successfully!"
    exit 0
fi

# Configuration
BACKUP_DIR="/home/debian/postgres_backups"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD=$(grep POSTGRES_PASSWORD .env | cut -d= -f2)
POSTGRES_CONTAINER="funnel-postgres"
DATABASES=("n8n" "postgres")
MAX_BACKUPS=3

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Set secure permissions
chmod 700 "$BACKUP_DIR"

# Get current timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Log start of backup
echo "Starting PostgreSQL backup at $(date)" >> "$BACKUP_DIR/backup.log"

# Backup each database
for DB in "${DATABASES[@]}"; do
    BACKUP_FILE="$BACKUP_DIR/${DB}_${TIMESTAMP}.sql.gz"
    
    echo "Backing up $DB database to $BACKUP_FILE" >> "$BACKUP_DIR/backup.log"
    
    # Execute pg_dump inside the Docker container and compress the output
    docker exec "$POSTGRES_CONTAINER" pg_dump -U "$POSTGRES_USER" "$DB" | gzip > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Backup of $DB completed successfully" >> "$BACKUP_DIR/backup.log"
    else
        echo "Backup of $DB failed" >> "$BACKUP_DIR/backup.log"
    fi
    
    # Rotate backups (keep only the last MAX_BACKUPS for each database)
    echo "Rotating backups for $DB" >> "$BACKUP_DIR/backup.log"
    ls -t "$BACKUP_DIR/${DB}_"*.sql.gz | tail -n +$((MAX_BACKUPS+1)) | xargs -r rm
done

echo "PostgreSQL backup completed at $(date)" >> "$BACKUP_DIR/backup.log"

# Usage instructions (displayed when script is run with -h or --help)
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage:"
    echo "  $0           - Run backup"
    echo "  $0 setup     - Install cron and set up scheduled backups"
    echo "  $0 -h/--help - Show this help message"
    echo ""
    echo "The backup script will:"
    echo "- Back up the n8n and postgres databases"
    echo "- Store backups in $BACKUP_DIR"
    echo "- Keep only the last $MAX_BACKUPS backups for each database"
    echo "- Log all operations to $BACKUP_DIR/backup.log"
    echo ""
    echo "When run with 'setup', it will:"
    echo "- Install cron if not already installed"
    echo "- Set up a cron job to run the backup every 2 hours"
    echo "- Create an initial backup"
fi