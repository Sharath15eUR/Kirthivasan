#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "For proper working we need 3 arguments"
    exit 1
fi

# Check whether the directory is exist or not
if [ ! -d "$1" ]; then
    echo "Sorce Directory is not available"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$2" ]; then
    mkdir -p "$2" || { echo "Error in creating the backup directory"; exit 1; }
fi

# Searching for the files  matching the same extension and storing it in array
SF=("$1"/*"$3")

# Check if there are files to back up
if [ "${#SF[@]}" -eq 0 ]; then
    echo "No files found with extension "
    exit 0
fi

# Initialize backup counter and total size
BACKUP_COUNT=0
TOTAL_SIZE=0
export BACKUP_COUNT

# Backup process
for FILE in "${SF[@]}"; do
    FILE_NAME=$(basename "$FILE")
    DEST_FILE="$2/$FILE_NAME"
    FILE_SIZE=$(stat --format=%s "$FILE")
    
    # Print file details
    echo "Backing up: $FILE_NAME ($FILE_SIZE bytes)"
    
    # Check if file exists in backup directory and compare timestamps
    if [ -f "$2" ]; then
        if [ "$FILE" -nt "$2" ]; then
            cp "$FILE" "$2"
            echo "Updated: $FILE_NAME"
        else
            echo "File is already updated"
            continue
        fi
    else
        cp "$FILE" "$DEST_FILE"
        echo "Copied: $FILE_NAME"
    fi
    
    ((BACKUP_COUNT++))
    ((TOTAL_SIZE+=FILE_SIZE))
done

# Generate backup report
REPORT_FILE="$2/backup_report.log"
echo "Backup Summary" > "$REPORT_FILE"
echo "Total files processed: $BACKUP_COUNT" >> "$REPORT_FILE"
echo "Total size: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup location: $2" >> "$REPORT_FILE"
