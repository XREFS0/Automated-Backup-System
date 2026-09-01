# Configuration Guide

The Automated Backup System uses a centralized configuration file located at `config/backup.conf`.

## Setup

1. Copy the example file:
   ```bash
   cp backup.conf.example backup.conf
   ```
2. Edit `backup.conf` with your preferred text editor.
3. Ensure the directories specified in `BACKUP_SOURCE` and `BACKUP_DESTINATION` exist or can be created by the user running the backup system.

## Parameters

* `BACKUP_SOURCE`: The absolute path to the directory or file you want to back up.
* `BACKUP_DESTINATION`: The absolute path where the backups will be stored.
* `RETENTION_DAYS`: The number of days to keep a backup before it is removed by the `cleanup` command.
* `LOG_DIRECTORY`: Where to store the system logs. (If empty or missing, it will only log to the console).
