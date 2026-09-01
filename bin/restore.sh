#!/usr/bin/env bash
#
# restore.sh
# Safely restores a backup archive.

set -euo pipefail

main() {
    log_info "Starting restore process..."
    
    local dest_dir="${BACKUP_DESTINATION}"
    
    if [[ ! -d "${dest_dir}" ]]; then
        log_error "Backup destination directory not found: ${dest_dir}"
        return "${EXIT_ERROR}"
    fi
    
    echo "Available Backups"
    echo "──────────────────────────────────────────────────────────────"
    
    # shellcheck disable=SC2012
    local backups
    mapfile -t backups < <(ls -1t "${dest_dir}"/backup_*.tar.gz 2>/dev/null)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        log_warning "No backups found in ${dest_dir}"
        return "${EXIT_OK}"
    fi
    
    local i=1
    for b in "${backups[@]}"; do
        local b_name
        b_name=$(basename "$b")
        local b_date
        b_date=$(date -r "$b" '+%Y-%m-%d %H:%M')
        local b_size
        b_size=$(du -sh "$b" | awk '{print $1}')
        
        # Quick validation check (does sha256 file exist?)
        local status="Unknown"
        if [[ -f "${b}.sha256" ]]; then
            status="Valid Metadata"
        else
            status="Missing Checksum"
        fi
        
        printf "%-4s %-20s %-10s %s\n" "${i}" "${b_date}" "${b_size}" "${status}"
        ((i++))
    done
    
    echo ""
    read -r -p "Select backup to restore (1-$((i-1))) or 0 to cancel: " choice
    
    if [[ "$choice" -eq 0 ]]; then
        log_info "Restore cancelled."
        return "${EXIT_OK}"
    fi
    
    if [[ "$choice" -lt 1 ]] || [[ "$choice" -ge $i ]]; then
        log_error "Invalid selection."
        return "${EXIT_INVALID_ARGS}"
    fi
    
    local selected_backup="${backups[$((choice-1))]}"
    log_info "Selected: $(basename "${selected_backup}")"
    
    # Verify checksum before restore
    verify_checksum "${selected_backup}" || {
        log_error "Backup verification failed! Aborting restore for safety."
        return "${EXIT_VERIFICATION_FAILED}"
    }
    
    # Prevent accidental overwrite - prompt for target path
    local default_restore="/tmp/restore_$(date '+%s')"
    read -r -p "Enter restore destination path [${default_restore}]: " restore_path
    restore_path=${restore_path:-$default_restore}
    
    if [[ -e "${restore_path}" ]]; then
        log_error "Destination path already exists. Refusing to overwrite."
        return "${EXIT_ERROR}"
    fi
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "DRY RUN MODE"
        echo "[WOULD RESTORE] ${selected_backup} -> ${restore_path}"
        return "${EXIT_OK}"
    fi
    
    mkdir -p "${restore_path}"
    log_info "Extracting archive to ${restore_path}..."
    if tar -xzf "${selected_backup}" -C "${restore_path}"; then
        log_success "Restore completed successfully."
    else
        log_error "Failed to extract archive."
        return "${EXIT_ERROR}"
    fi
}

main "$@"
