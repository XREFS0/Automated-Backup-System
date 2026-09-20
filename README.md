# Automated Backup System

A complete, production-grade automated backup solution using Bash scripting. Designed by and for Linux engineers.

## Features

- **Automated Backups**: Easily configure source and destination paths.
- **Data Integrity**: Automatically generates and verifies SHA256 checksums for all backups.
- **Safe Restores**: Interactive restore menu with checksum validation before extraction.
- **Retention Policies**: Automatically clean up old backups based on a configurable number of days.
- **Defensive Design**: Built with `set -euo pipefail` and extensive input validation. Prevents accidental disk space exhaustion and path traversal.
- **Professional CLI**: Supports both interactive mode (TUI) and command-line execution for crontabs.

## Requirements

- `bash` (v4.0+)
- `tar` and `gzip`
- `sha256sum` (coreutils)
- standard tools: `awk`, `date`, `find`, `du`, `df`

## Installation

```bash
git clone https://github.com/your-username/automated-backup-system.git
cd automated-backup-system
chmod +x backup-manager.sh bin/*
```

## Configuration

Copy the example configuration:
```bash
cp config/backup.conf.example config/backup.conf
```
Edit `config/backup.conf` and set:
- `BACKUP_SOURCE`: The directory or file to back up.
- `BACKUP_DESTINATION`: Where the archives will be saved.
- `RETENTION_DAYS`: How many days to keep old backups.

## Usage

### Interactive Menu

Run without arguments to enter the interactive menu:
```bash
./backup-manager.sh
```

### CLI Mode

Create a backup:
```bash
./backup-manager.sh backup
```

Dry-run mode (see what would happen):
```bash
./backup-manager.sh backup --dry-run
```

Run cleanup manually:
```bash
./backup-manager.sh cleanup
```

Check system diagnostics:
```bash
./backup-manager.sh diagnostics
```

## Scheduling

### Cron

To run every day at 3 AM:
```cron
0 3 * * * /path/to/automated-backup-system/backup-manager.sh backup --quiet
```

### Systemd (Recommended)

See the `systemd/` directory for an example `.service` and `.timer` unit. Systemd provides better logging and isolation than standard cron.

## License

MIT License

---

### 🌐 Connect with Me

<p align="left">
  <a href="http://xrefs0.com/" target="_blank">
    <img src="https://img.icons8.com/bubbles/60/000000/domain.png" title="Website" width="45" height="45"/>
  </a>
  <a href="https://www.facebook.com/XREFS0" target="_blank">
    <img src="https://img.icons8.com/bubbles/60/000000/facebook-new.png" title="Facebook Page" width="45" height="45"/>
  </a>
  <a href="https://t.me/MrMasaOfficial" target="_blank">
    <img src="https://img.icons8.com/bubbles/60/000000/telegram-app.png" title="Telegram Contact" width="45" height="45"/>
  </a>
  <a href="https://t.me/XREFS0_CHANNEL" target="_blank">
    <img src="https://img.icons8.com/bubbles/60/000000/telegram.png" title="Telegram Channel" width="45" height="45"/>
  </a>
  <a href="https://www.youtube.com/@XREFS0" target="_blank">
    <img src="https://img.icons8.com/bubbles/60/000000/youtube-play.png" title="YouTube" width="45" height="45"/>
  </a>
</p>

