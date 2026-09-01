#!/usr/bin/env bash
#
# storage.sh
# Functions for backup creation, checksums, and space management.

check_disk_space() {
    local source_dir="$1"
    local dest_dir="$2"
    
    # Estimate size in KB (du -sk)
    local estimated_size_kb
    if [[ -d "${source_dir}" ]]; then
        estimated_size_kb=$(du -sk "${source_dir}" | awk '{print $1}')
    else
        # If it's a file
        estimated_size_kb=$(du -sk "${source_dir}" | awk '{print $1}')
    fi
    
    # Check available space in KB (df -k)
    local available_space_kb
    available_space_kb=$(df -k "${dest_dir}" | tail -1 | awk '{print $4}')
    
    # We require estimated size + 10% safety margin (for tar overhead and variations)
    local required_space_kb=$(( estimated_size_kb + (estimated_size_kb / 10) ))
    
    log_debug "Estimated source size: ${estimated_size_kb} KB"
    log_debug "Available space: ${available_space_kb} KB"
    log_debug "Required space: ${required_space_kb} KB"
    
    if [[ ${available_space_kb} -lt ${required_space_kb} ]]; then
        log_error "Insufficient disk space. Required: $((required_space_kb / 1024)) MB, Available: $((available_space_kb / 1024)) MB"
        return "${EXIT_INSUFFICIENT_SPACE}"
    fi
    
    return "${EXIT_OK}"
}

create_archive() {
    local source_path="$1"
    local dest_archive="$2"
    
    log_info "Creating archive: ${dest_archive}"
    
    # Use tar with gzip
    if tar -czf "${dest_archive}" -C "$(dirname "${source_path}")" "$(basename "${source_path}")"; then
        log_debug "Archive created successfully."
        return "${EXIT_OK}"
    else
        log_error "Failed to create archive."
        return "${EXIT_ERROR}"
    fi
}

generate_checksum() {
    local archive_path="$1"
    local checksum_file="${archive_path}.sha256"
    
    log_info "Calculating checksum..."
    if cd "$(dirname "${archive_path}")" && sha256sum "$(basename "${archive_path}")" > "$(basename "${checksum_file}")"; then
        log_debug "Checksum generated: ${checksum_file}"
        return "${EXIT_OK}"
    else
        log_error "Failed to generate checksum."
        return "${EXIT_ERROR}"
    fi
}

verify_checksum() {
    local archive_path="$1"
    local checksum_file="${archive_path}.sha256"
    
    if [[ ! -f "${checksum_file}" ]]; then
        log_warning "Checksum file not found for ${archive_path}"
        return "${EXIT_VERIFICATION_FAILED}"
    fi
    
    log_info "Verifying checksum for $(basename "${archive_path}")..."
    if cd "$(dirname "${archive_path}")" && sha256sum -c "$(basename "${checksum_file}")" >/dev/null 2>&1; then
        log_success "Checksum verified."
        return "${EXIT_OK}"
    else
        log_error "Checksum verification failed! Archive may be corrupted."
        return "${EXIT_VERIFICATION_FAILED}"
    fi
}
