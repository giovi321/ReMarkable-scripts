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
uploaded_files=()

while true; do
  new_files=()
  for file in "$WATCH_FOLDER"/*.pdf; do
    if ! [[ "${uploaded_files[*]}" =~ "${file}" ]]; then
      new_files+=("$file")
    fi
  done

  for file in "${new_files[@]}"; do
    sleep "$SLEEP_TIME"
    if RMAPI_CONFIG=$RMAPI_CONFIG_PATH RMAPI_HOST=$RMAPI_HOST "$RMAPI_PATH" -ni put "$file"; then
      echo "Successfully uploaded $file"
      uploaded_files+=("$file")
      rm "$file"
    else
      echo "Upload failed for $file"
    fi
  done

  sleep "$SLEEP_TIME"
done
####### SCRIPT END #######
