# ReMarkable-scripts
Server-side bash scripts to use the ReMarkable tablet at its full potential.

The scripts work best if used all together.

See the bottom of this file for instructions on how to demonize/run with cron.

The scripts do the following:
- Upload.sh - Watch a folder on your server for new files, when a new file appears upload it to rmcloud/rmfakecloud
- Mail.sh - Download attachments from a selected email account and move them to a folder synced with rmcloud/rmfakecloud through the upload.sh script
- Convert.sh - Watch a directory and automatically convert .docx, .pptx files to pdf

# License
The content of this repository is licensed under the [WTFPL](http://www.wtfpl.net/).

```
Copyright © 2023 giovi321
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the LICENSE file for more details.
```

## Upload.sh
Watch a folder on your server for new files, when a new file appears upload it to rmcloud/rmfakecloud.

Configuration:
- Change the variables in the variables section of the script
- Run `chmod +x upload.sh`

Dependencies:
- rmapi (https://github.com/juruen/rmapi)
- inotify-tools (`sudo apt install inotify-tools`)

## Mail.sh
Download attachments from a selected email account and move them to a folder synced with rmcloud/rmfakecloud through the upload.sh script.

Configuration:
- Look at the file .offlineimaprc to configure offlineimap
- In .offlineimaprc, in the last line you can configure the trusted senders (can be more than one, separated by `|` like in the example file provided), don't forget to escape characters (such as `.` and `_`) preceding them with a backslash `\`
- Run `chmod +x mail.sh`
- Change the settings in .offlineimaprc and place it in the user root folder

Features:
- Senders can be filtered
- Compatible with gmail, but need to configure less secure apps on gmail (here is an how-to: https://support.google.com/accounts/answer/6010255)

Dependencies:
- cron (usually installed by default on linux)
- offlineimap (`sudo apt install offlineimap`)
- munpack (`sudo apt install mpack`)

## Convert.sh
Watch a directory and automatically convert .docx, .pptx files to .pdf.

Configuration:
- Change the variables in the variables section of the script
- Run `chmod +x convert.sh`

Dependencies
- Unoconv (`sudo apt install unoconv`)

## How to automatically run the scripts
In order to automatically run the scripts we will use cron and systemd.

### Automatically run upload.sh
Procedure:
- Run `nano /etc/systemd/system/upload.service`
- Copy the content of the file upload.service in this repository
- ctrl+x and "y" + enter to save
- Run `systemctl enable upload.service` to enable the service

### Automatically run mail.sh
Procedure:
- Run `crontab -e`
- Run `touch /var/log/mail.log`
- paste the following line at the end of the file in a new line:
`* * * * *	/root/mail.sh >>/var/log/mail.log`
- Press ctrl+x and "y" + enter to save

### Automatically run convert.sh
Procedure:
- Run `nano /etc/systemd/system/convert.service`
- Copy the content of the file convert.service in this repository
- Press ctrl+x and "y" + enter to save
- Run `systemctl enable convert.service` to enable the service
