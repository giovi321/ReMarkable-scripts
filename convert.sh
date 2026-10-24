#!/bin/bash

####### VARIABLES BEGIN #######
# Set the following variables to configure the script
# Each one can also be set from the environment, which is how the Docker image is configured
## Set the first watched directory (I have configured the directory to which I extract files from emails downloaded using the script mail.sh)
WATCH_DIR1="${WATCH_DIR1:-/tmp/munpack-extracted-files}"
## Set the second watched directory (not compulsory to set)
WATCH_DIR2="${WATCH_DIR2:-/root/sync/sync}"
## Set the output directory (I have configured the directory that is automatically synced with rmcloud/rmfakecloud through the script upload.sh)
OUTPUT_DIR="${OUTPUT_DIR:-/root/sync/sync}"
## Optional: convert through a Stirling-PDF server instead of a local unoconv.
## Leave STIRLING_URL empty to use unoconv. STIRLING_API_KEY is needed when that
## server has login enabled
STIRLING_URL="${STIRLING_URL:-}"
STIRLING_API_KEY="${STIRLING_API_KEY:-}"
####### VARIABLES END #######


####### SCRIPT BEGIN #######
convert() {
    local path="$1" name
    name="$(basename "$path")"
    if [ -n "$STIRLING_URL" ]; then
        curl -sSf -m 300 ${STIRLING_API_KEY:+-H "X-API-KEY: $STIRLING_API_KEY"} \
            -F "fileInput=@$path" \
            -o "$OUTPUT_DIR/${name%.*}.pdf" \
            "$STIRLING_URL/api/v1/convert/file/pdf"
    else
        unoconv -f pdf -o "$OUTPUT_DIR" "$path"
    fi
}

mkdir -p "$WATCH_DIR1" "$WATCH_DIR2"
while true; do
    # close_write and moved_to fire once per finished file; watching every event
    # converted the same file several times while it was still being written
    inotifywait -q -m -e close_write -e moved_to --format '%w%f' "$WATCH_DIR1" "$WATCH_DIR2" | while read -r FILE; do
        if [[ "$FILE" =~ \.(pptx|docx)$ ]]; then
            echo "Converting $FILE to PDF..."
            if convert "$FILE"; then
                rm "$FILE"
                echo "Deleting $FILE"
            else
                rm -f "$OUTPUT_DIR/$(basename "${FILE%.*}").pdf"
                echo "Conversion failed for $FILE, left in place"
            fi
        fi
    done
done
####### SCRIPT END #######
