#!/bin/bash

####### VARIABLES BEGIN #######
# Define the variables - use the following lines in this section as the settings
# Each one can also be set from the environment, which is how the Docker image is configured
## Folder where you intend to save the files to be uploaded to the remarkable cloud
WATCH_FOLDER="${WATCH_FOLDER:-/root/sync/sync}"
## Path to rmapi (use the command "whereis rmapi" to find it out)
RMAPI_PATH="${RMAPI_PATH:-/root/go/bin/rmapi}"
## Path to the configuration file of rmapi
RMAPI_CONFIG_PATH="${RMAPI_CONFIG_PATH:-/root/.config/rmapi/rmapi.conf}"
## Link to your rmfakecloud installation or just use rmCloud link
RMAPI_HOST="${RMAPI_HOST:-https://remarkable.mydomain.com}"
SLEEP_TIME="${SLEEP_TIME:-10}"
####### VARIABLES END #######

####### SCRIPT BEGIN #######
# Without nullglob an empty folder hands rmapi the literal "*.pdf" every cycle
shopt -s nullglob

# rmapi refuses a name the tablet already has ("entry already exists"). Rename the
# local file to the next " (n)" and let the next cycle upload it under that name
next_name() {
  local base n=2
  base="$(basename "$1" .pdf)"
  if [[ "$base" =~ ^(.*)\ \(([0-9]+)\)$ ]]; then
    base="${BASH_REMATCH[1]}"
    n=$((BASH_REMATCH[2] + 1))
  fi
  while [ -e "$WATCH_FOLDER/$base ($n).pdf" ]; do
    n=$((n+1))
  done
  echo "$WATCH_FOLDER/$base ($n).pdf"
}

while true; do
  for file in "$WATCH_FOLDER"/*.pdf; do
    sleep "$SLEEP_TIME"
    [ -f "$file" ] || continue
    out="$(RMAPI_CONFIG=$RMAPI_CONFIG_PATH RMAPI_HOST=$RMAPI_HOST "$RMAPI_PATH" -ni put "$file" 2>&1)"
    rc=$?
    echo "$out"
    if [ $rc -eq 0 ] && ! grep -q "ERROR" <<<"$out"; then
      echo "Successfully uploaded $file"
      rm "$file"
    elif grep -q "entry already exists" <<<"$out"; then
      renamed="$(next_name "$file")"
      mv "$file" "$renamed"
      echo "$(basename "$file") already exists on the tablet, retrying as $(basename "$renamed")"
    else
      echo "Upload failed for $file"
    fi
  done

  sleep "$SLEEP_TIME"
done
####### SCRIPT END #######
