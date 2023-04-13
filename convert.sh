#!/bin/bash

####### VARIABLES BEGIN #######
# Set the following variables to configure the script
## Set the first watched directory (I have configured the directory to which I extract files from emails downloaded using the script mail.sh)
WATCH_DIR1="/tmp/munpack-extracted-files"
## Set the second watched directory (not compulsory to set)
WATCH_DIR2="/root/sync/sync"
## Set the output directory (I have configured the directory that is automatically synced with rmcloud/rmfakecloud through the script upload.sh)
OUTPUT_DIR="/root/sync/sync"
####### VARIABLES END #######


####### SCRIPT BEGIN #######
while true; do
    inotifywait -q -m --format '%f' "$WATCH_DIR1" "$WATCH_DIR2" | while read -r FILE; do
        if [[ "$FILE" =~ \.(pptx|docx)$ ]]; then
            echo "Converting $FILE to PDF..."
            unoconv -f pdf -o "$OUTPUT_DIR" "$WATCH_DIR1/$FILE" "$WATCH_DIR2/$FILE"
            rm "$WATCH_DIR1/$FILE" "$WATCH_DIR2/$FILE"
            echo "Deleting $FILE"
        fi
    done
done
####### SCRIPT END #######
