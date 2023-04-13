# ReMarkable-scripts
Bash scripts to use the ReMarkable tablet at its full potential


## Upload.sh
Watch a folder on your server for new files, when a new file appear upload it to rmcloud/rmfakecloud

Dependencies:
- rmapi (https://github.com/juruen/rmapi)

## Mail.sh
Download attachments from a selected email account and move them to a folder synced with rmcloud/rmfakecloud through the upload.sh script.

Configuration:
- Look at the file .offlineimaprc to configure offlineimap
- In .offlineimaprc, in the last line you can configure the trusted senders (can be more than one), don't forget to escape characters (such as "." and "_") preceding them with a "\"

Features:
- Senders can be filtered
- Compatible with gmail, but need to configure less secure apps on gmail (here is an how-to: https://support.google.com/accounts/answer/6010255)

Dependencies:
- cron (usually installed by default on linux)
- offlineimap (sudo apt install offlineimap)
- munpack (sudo apt install mpack)
