#!/usr/bin/env bash
#
# validation.sh
# Input validation, path sanitization, and dependency checks.

validate_config() {
    # Check if required variables are set
    local required_vars=("BACKUP_SOURCE" "BACKUP_DESTINATION" "RETENTION_DAYS" "BACKUP_FORMAT")
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log_error "Configuration missing required variable: ${var}"
            return "${EXIT_INVALID_CONFIG}"
        fi
    done

    # Validate source exists
    if [[ ! -e "${BACKUP_SOURCE}" ]]; then
        log_error "Backup source does not exist: ${BACKUP_SOURCE}"
        return "${EXIT_INVALID_CONFIG}"
    fi

    # Validate destination exists and is writable
    if [[ ! -d "${BACKUP_DESTINATION}" ]]; then
        log_info "Creating backup destination: ${BACKUP_DESTINATION}"
        if ! mkdir -p "${BACKUP_DESTINATION}"; then
            log_error "Failed to create backup destination: ${BACKUP_DESTINATION}"
            return "${EXIT_INVALID_CONFIG}"
        fi
    fi

    if [[ ! -w "${BACKUP_DESTINATION}" ]]; then
        log_error "Backup destination is not writable: ${BACKUP_DESTINATION}"
        return "${EXIT_INVALID_CONFIG}"
    fi
    
    return "${EXIT_OK}"
}

check_dependencies() {
    local deps=("tar" "gzip" "sha256sum" "awk" "date" "find" "rm" "du" "df")
    
    for cmd in "${deps[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            log_error "Missing required dependency: ${cmd}"
            return "${EXIT_MISSING_DEPENDENCY}"
        fi
    done
    return "${EXIT_OK}"
}

sanitize_path() {
    local path="$1"
    # Basic protection against traversal (e.g. replacing ../)
    # realpath is preferred if available to resolve paths
    if command -v realpath >/dev/null 2>&1; then
        realpath -m "$path"
    else
        echo "$path" | sed -e 's/\.\.\///g'
    fi
}
