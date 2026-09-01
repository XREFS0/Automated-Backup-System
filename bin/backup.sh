#!/usr/bin/env bash
#
# backup.sh
# Performs the backup operation.

set -euo pipefail

# Sourced from main script, but just in case:
if [[ -z "${APP_NAME:-}" ]]; then
    echo "This script must be run via backup-manager.sh" >&2
    exit 1
fi

main() {
    log_info "Starting backup process..."
    
    validate_config || exit $?
    check_dependencies || exit $?
    
    local source_path="${BACKUP_SOURCE}"
    local dest_dir="${BACKUP_DESTINATION}"
    
    check_disk_space "${source_path}" "${dest_dir}" || exit $?
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
    local archive_name="backup_${timestamp}.tar.gz"
    local archive_path="${dest_dir}/${archive_name}"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "DRY RUN MODE"
        echo "────────────────────────────────────────"
        echo "Source       : ${source_path}"
        echo "Destination  : ${dest_dir}"
        echo "Compression  : gzip"
        echo "Encryption   : ${ENCRYPTION_ENABLED:-disabled}"
        echo "Retention    : ${RETENTION_DAYS} days"
        echo ""
        echo "Actions:"
        echo "[WOULD CREATE] ${archive_path}"
        echo "[WOULD VERIFY] checksum"
        echo "────────────────────────────────────────"
        log_success "Dry run completed."
        return "${EXIT_OK}"
    fi
    
    create_secure_temp_dir || exit $?
    
    create_archive "${source_path}" "${archive_path}" || exit $?
    
    generate_checksum "${archive_path}" || exit $?
    
    verify_checksum "${archive_path}" || exit $?
    
    log_success "Backup completed successfully: ${archive_name}"
}

main "$@"
