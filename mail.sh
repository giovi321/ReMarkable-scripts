#!/bin/bash


####### VARIABLES BEGIN #######
# Define the variables in this section
## Define the directory where attachments will be saved
SAVE_DIR="/root/sync/sync"
## Define the command to upload PDFs to reMarkable
RMAPI_CMD="RMAPI_CONFIG=/root/.config/rmapi/rmapi.conf RMAPI_HOST=https://remarkable.mydomain.com /root/go/bin/rmapi -ni pu>
####### VARIABLES END #######


####### SCRIPT BEGIN #######
# Write date and time to log
echo $(date +'%Y-%m-%d %H:%M:%S'): Script starting.

# Sync emails using offlineimap
offlineimap -o

# Extract all attachments
if [ ! -d "/tmp/munpack-extracted-files" ]
then
  echo "Directory doesn't exist, creating it."
  mkdir "/tmp/munpack-extracted-files"
else
  echo "Directory already exists."
fi
munpack -f -t -C /tmp/munpack-extracted-files /root/Maildir/INBOX/new/*

# Loop through all files in the directory
for fname in /tmp/munpack-extracted-files/*.pdf
do
  mv "$fname" "$fname"-$RANDOM.pdf
done

# Clean-up files
mv /tmp/munpack-extracted-files/*.pdf /root/sync/sync/
rm Maildir/INBOX/new/*
rm /tmp/munpack-extracted-files/part*

####### SCRIPT END #######
