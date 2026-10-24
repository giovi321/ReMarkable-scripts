#!/bin/bash


####### VARIABLES BEGIN #######
# Define the variables in this section
# Each one can also be set from the environment, which is how the Docker image is configured
## Define the directory where attachments will be saved
SAVE_DIR="${SAVE_DIR:-/root/sync/sync}"
## The Maildir selected as localfolders in the .offlineimaprc configuration file. Make sure it matches
MAIL_DIR="${MAIL_DIR:-/root/Maildir}"
## Where munpack extracts attachments. convert.sh watches this directory too
EXTRACT_DIR="${EXTRACT_DIR:-/tmp/munpack-extracted-files}"
####### VARIABLES END #######


####### SCRIPT BEGIN #######
shopt -s nullglob

# Write date and time to log
echo $(date +'%Y-%m-%d %H:%M:%S'): Script starting.

# Sync emails using offlineimap
offlineimap -o

# Extract all attachments
mkdir -p "$EXTRACT_DIR"
new_mail=("$MAIL_DIR"/INBOX/new/*)
# munpack reads stdin when given no files, so only call it when there is mail
if [ ${#new_mail[@]} -gt 0 ]; then
  munpack -f -t -C "$EXTRACT_DIR" "${new_mail[@]}"
fi

# Rename every PDF so attachments with the same name do not overwrite each other,
# then hand them to upload.sh
for fname in "$EXTRACT_DIR"/*.pdf
do
  mv "$fname" "$SAVE_DIR/$(basename "$fname")-$RANDOM.pdf"
done

# Clean-up files
if [ ${#new_mail[@]} -gt 0 ]; then
  rm -f "${new_mail[@]}"
fi
# Everything else munpack extracted is of no use: message bodies (part1, part2),
# signature images, inline logos. Only .docx and .pptx stay, for convert.sh
for fname in "$EXTRACT_DIR"/*
do
  case "$fname" in
    *.docx|*.pptx) ;;
    *) rm -f "$fname" ;;
  esac
done

####### SCRIPT END #######
