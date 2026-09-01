#!/usr/bin/env bash
#
# status.sh
# Displays backup status, lists backups, or shows configuration.

set -euo pipefail

cmd_list() {
    local dest_dir="${BACKUP_DESTINATION}"
    
    if [[ ! -d "${dest_dir}" ]]; then
        log_error "Backup destination directory not found: ${dest_dir}"
        return "${EXIT_ERROR}"
    fi
    
    echo "Available Backups in ${dest_dir}"
    echo "──────────────────────────────────────────────────────────────"
    
    local backups
    mapfile -t backups < <(ls -1t "${dest_dir}"/backup_*.tar.gz 2>/dev/null || true)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo "No backups found."
        return "${EXIT_OK}"
    fi
    
    printf "%-30s %-20s %-10s\n" "Filename" "Date" "Size"
    echo "──────────────────────────────────────────────────────────────"
    
    for b in "${backups[@]}"; do
        local b_name
        b_name=$(basename "$b")
        local b_date
        b_date=$(date -r "$b" '+%Y-%m-%d %H:%M')
        local b_size
        b_size=$(du -sh "$b" | awk '{print $1}')
        
        printf "%-30s %-20s %-10s\n" "${b_name}" "${b_date}" "${b_size}"
    done
}

cmd_config() {
    echo "Current Configuration"
    echo "──────────────────────────────────────────────────────────────"
    echo "BACKUP_SOURCE      : ${BACKUP_SOURCE:-Not Set}"
    echo "BACKUP_DESTINATION : ${BACKUP_DESTINATION:-Not Set}"
    echo "RETENTION_DAYS     : ${RETENTION_DAYS:-Not Set}"
    echo "BACKUP_FORMAT      : ${BACKUP_FORMAT:-Not Set}"
    echo "ENCRYPTION_ENABLED : ${ENCRYPTION_ENABLED:-Not Set}"
    echo "LOG_DIRECTORY      : ${LOG_DIRECTORY:-Not Set}"
}

main() {
    local action="${1:-list}"
    
    case "${action}" in
        list) cmd_list ;;
        config) cmd_config ;;
        *) log_error "Unknown status action: ${action}"; return "${EXIT_INVALID_ARGS}" ;;
    esac
}

main "$@"
