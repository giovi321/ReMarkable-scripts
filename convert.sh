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
## How often, in seconds, files left behind by a failed conversion are tried again
RETRY_INTERVAL="${RETRY_INTERVAL:-600}"
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

handle() {
    local FILE="$1"
    # Already handled, when both watched directories are the same one
    [ -f "$FILE" ] || return 0
    echo "Converting $FILE to PDF..."
    if convert "$FILE"; then
        rm "$FILE"
        echo "Deleting $FILE"
    else
        rm -f "$OUTPUT_DIR/$(basename "${FILE%.*}").pdf"
        echo "Conversion failed for $FILE, left in place, retrying within ${RETRY_INTERVAL}s"
    fi
}

# Everything waiting in both directories: files that arrived while the script was
# not running, and files a failed conversion left behind
sweep() {
    local f
    for f in "$WATCH_DIR1"/*.docx "$WATCH_DIR1"/*.pptx "$WATCH_DIR2"/*.docx "$WATCH_DIR2"/*.pptx; do
        handle "$f"
    done
}

shopt -s nullglob
mkdir -p "$WATCH_DIR1" "$WATCH_DIR2"
while true; do
    sweep
    # Wait for one finished file (close_write, moved_to) or for the retry interval,
    # then sweep again. A file that lands between the sweep and the wait is picked up
    # at the next timeout at the latest
    inotifywait -q -t "$RETRY_INTERVAL" -e close_write -e moved_to "$WATCH_DIR1" "$WATCH_DIR2" >/dev/null
done
####### SCRIPT END #######
