#!/bin/bash


####### VARIABLES BEGIN #######
# Define the variables in this section
# Each one can also be set from the environment, which is how the Docker image is configured
## Define the directory where attachments will be saved
SAVE_DIR="${SAVE_DIR:-/root/sync/sync}"
## The Maildir selected as localfolders in the .offlineimaprc configuration file. Make sure it matches
MAIL_DIR="${MAIL_DIR:-/root/Maildir}"
## Where attachments are extracted to. convert.sh watches this directory too
EXTRACT_DIR="${EXTRACT_DIR:-/tmp/munpack-extracted-files}"
####### VARIABLES END #######


####### SCRIPT BEGIN #######
shopt -s nullglob

# Write date and time to log
echo $(date +'%Y-%m-%d %H:%M:%S'): Script starting.

# Sync emails using offlineimap
offlineimap -o

# Extract all attachments, keeping their names (extract.py sits next to this script)
mkdir -p "$EXTRACT_DIR"
new_mail=("$MAIL_DIR"/INBOX/new/*)
if [ ${#new_mail[@]} -gt 0 ]; then
  python3 "$(dirname "$(readlink -f "$0")")/extract.py" "$EXTRACT_DIR" "${new_mail[@]}"
fi

# Hand every PDF to upload.sh under its own name. A name already waiting in the
# upload folder gets " (2)", " (3)" and so on rather than overwriting it
for fname in "$EXTRACT_DIR"/*.pdf
do
  base="$(basename "$fname" .pdf)"
  dest="$SAVE_DIR/$base.pdf"
  n=2
  while [ -e "$dest" ]; do
    dest="$SAVE_DIR/$base ($n).pdf"
    n=$((n+1))
  done
  mv "$fname" "$dest"
done

# Clean-up files
if [ ${#new_mail[@]} -gt 0 ]; then
  rm -f "${new_mail[@]}"
fi
# Every other attachment is of no use here: signature images, inline logos,
# calendar invites. Only .docx and .pptx stay, for convert.sh
for fname in "$EXTRACT_DIR"/*
do
  case "$fname" in
    *.docx|*.pptx) ;;
    *) rm -f "$fname" ;;
  esac
done

####### SCRIPT END #######
