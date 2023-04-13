# ReMarkable-scripts
Bash scripts to use the ReMarkable tablet at its full potential


## Upload.sh
Watch a folder on your server for new files, when a new file appear upload it to rmcloud/rmfakecloud

Dependencies:
- rmapi (https://github.com/juruen/rmapi)

## Mail.sh
Download attachments from a selected email account and move them to a folder synced with rmcloud/rmfakecloud through the upload.sh script.

Look at the file .offlineimaprc to configure offlineimap.

Features:
- Senders can be filtered
- Compatible with gmail, but need to configure less secure apps on gmail (here is an how-to: https://support.google.com/accounts/answer/6010255)

Dependencies:
- cron (usually installed by default on linux)
- offlineimap (sudo apt install offlineimap)
- munpack (sudo apt install mpack)
