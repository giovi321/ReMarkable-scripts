#!/bin/bash

# Define the variables - use the following lines in this section as the settings
## Folder where you intend to save the files to be uploaded to the remarkable cloud
WATCH_FOLDER="/root/sync/sync"
## Path to rmapi (use the command "whereis rmapi" to find it out)
RMAPI_PATH="/root/go/bin/rmapi"
## Path to the configuration file of rmapi
RMAPI_CONFIG_PATH="/root/.config/rmapi/rmapi.conf"
## Link to your rmfakecloud installation or just use rmCloud link
RMAPI_HOST="https://remarkable.mydomain.com"
## Define pathe to rmapi (use the command "whereis rmapi" to find out)
RMAPI_UPLOAD_CMD="/root/go/bin/rmapi -ni put"
SLEEP_TIME=10

uploaded_files=()

while true; do
  new_files=()
  for file in "$WATCH_FOLDER"/*.pdf; do
    if ! [[ "${uploaded_files[*]}" =~ "${file}" ]]; then
      new_files+=("$file")
    fi
  done

  for file in "${new_files[@]}"; do
    sleep $SLEEP_TIME
    if RMAPI_CONFIG=$RMAPI_CONFIG_PATH RMAPI_HOST=$RMAPI_HOST $RMAPI_UPLOAD_CMD "$file"; then
      echo "Successfully uploaded $file"
      uploaded_files+=("$file")
      rm "$file"
    else
      echo "Upload failed for $file"
    fi
  done

  sleep $SLEEP_TIME
done
