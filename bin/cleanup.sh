#!/usr/bin/env bash
#
# cleanup.sh
# Applies retention policies by safely deleting old backups.

set -euo pipefail

main() {
    log_info "Starting cleanup process..."
    
    local dest_dir="${BACKUP_DESTINATION}"
    local retention_days="${RETENTION_DAYS:-30}"
    
    if [[ ! -d "${dest_dir}" ]]; then
        log_error "Backup destination directory not found: ${dest_dir}"
        return "${EXIT_ERROR}"
    fi
    
    log_info "Retention policy: Delete backups older than ${retention_days} days"
    
    # Safely find old files.
    # We restrict the find command to only match files named backup_*.tar.gz* to prevent accidental deletion of non-backup files.
    local old_backups
    mapfile -t old_backups < <(find "${dest_dir}" -maxdepth 1 -name "backup_*.tar.gz" -type f -mtime "+${retention_days}" 2>/dev/null || true)
    
    if [[ ${#old_backups[@]} -eq 0 ]]; then
        log_info "No expired backups found."
        return "${EXIT_OK}"
    fi
    
    echo "The following backups will be DELETED:"
    for b in "${old_backups[@]}"; do
        echo " - $(basename "$b")"
        if [[ -f "${b}.sha256" ]]; then
             echo " - $(basename "${b}.sha256")"
        fi
    done
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "DRY RUN MODE: No files deleted."
        return "${EXIT_OK}"
    fi
    
    # Interactive confirmation unless FORCE is set
    if [[ "${FORCE:-false}" != "true" ]]; then
        read -r -p "Are you sure you want to delete these files? (y/N) " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Cleanup cancelled."
            return "${EXIT_OK}"
        fi
    fi
    
    for b in "${old_backups[@]}"; do
        log_debug "Deleting ${b}"
        rm -f "${b}"
        if [[ -f "${b}.sha256" ]]; then
            rm -f "${b}.sha256"
        fi
    done
    
    log_success "Cleanup complete. Deleted ${#old_backups[@]} old backup(s)."
}

main "$@"
