#!/usr/bin/env bash
#
# verify.sh
# Verifies all backups in the destination directory.

set -euo pipefail

main() {
    log_info "Starting verification of all backups..."
    
    local dest_dir="${BACKUP_DESTINATION}"
    
    if [[ ! -d "${dest_dir}" ]]; then
        log_error "Backup destination directory not found: ${dest_dir}"
        return "${EXIT_ERROR}"
    fi
    
    local backups
    mapfile -t backups < <(ls -1t "${dest_dir}"/backup_*.tar.gz 2>/dev/null || true)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        log_info "No backups found to verify."
        return "${EXIT_OK}"
    fi
    
    local failed=0
    local success=0
    
    for b in "${backups[@]}"; do
        log_info "Verifying $(basename "$b")..."
        if verify_checksum "$b"; then
            ((success++))
        else
            ((failed++))
        fi
    done
    
    log_info "Verification complete. Success: ${success}, Failed: ${failed}"
    if [[ ${failed} -gt 0 ]]; then
        return "${EXIT_VERIFICATION_FAILED}"
    fi
    
    return "${EXIT_OK}"
}

main "$@"
