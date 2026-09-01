#!/usr/bin/env bash
#
# backup-manager.sh
# Main entry point for the Automated Backup System.

set -euo pipefail

# Determine script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR
export LIB_DIR="${SCRIPT_DIR}/lib"
export BIN_DIR="${SCRIPT_DIR}/bin"
export CONFIG_DIR="${SCRIPT_DIR}/config"

# Load core libraries
# shellcheck source=lib/common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=lib/logging.sh
source "${LIB_DIR}/logging.sh"
# shellcheck source=lib/validation.sh
source "${LIB_DIR}/validation.sh"
# shellcheck source=lib/storage.sh
source "${LIB_DIR}/storage.sh"
# shellcheck source=lib/security.sh
source "${LIB_DIR}/security.sh"
# shellcheck source=lib/ui.sh
source "${LIB_DIR}/ui.sh"

# Trap for global cleanup
trap cleanup_temp_files EXIT

# Print help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Commands:
  backup      Create a new backup
  restore     Restore from an existing backup
  list        List available backups
  verify      Verify checksums of all backups
  cleanup     Apply retention policies (delete old backups)
  status      Show system configuration and status
  diagnostics Run system checks
  (none)      Launch interactive menu

Options:
  --config PATH      Path to custom configuration file
  --dry-run          Show what would happen without making changes
  --verbose          Enable debug logging
  --quiet            Suppress non-error output
  --force            Skip interactive prompts (useful for scripts)
  --help             Show this help message
  --version          Show application version
EOF
}

show_version() {
    echo "${APP_NAME} version ${APP_VERSION}"
}

# Parse global arguments
export DRY_RUN="false"
export FORCE="false"
CONFIG_FILE="${CONFIG_DIR}/backup.conf"
COMMAND=""

# Basic argument parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        backup|restore|list|verify|cleanup|status|diagnostics)
            if [[ -z "$COMMAND" ]]; then
                COMMAND="$1"
            else
                log_error "Multiple commands specified."
                exit "${EXIT_INVALID_ARGS}"
            fi
            shift
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --dry-run)
            export DRY_RUN="true"
            shift
            ;;
        --verbose)
            set_log_level "DEBUG"
            shift
            ;;
        --quiet)
            set_log_level "QUIET"
            shift
            ;;
        --force)
            export FORCE="true"
            shift
            ;;
        --help)
            show_help
            exit "${EXIT_OK}"
            ;;
        --version)
            show_version
            exit "${EXIT_OK}"
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit "${EXIT_INVALID_ARGS}"
            ;;
    esac
done

# Load configuration
if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${CONFIG_FILE}"
else
    # We don't abort immediately because `diagnostics` or interactive menu might still want to run
    # and explain that config is missing. But we do log a warning.
    log_warning "Configuration file not found: ${CONFIG_FILE}"
    log_info "Please copy ${CONFIG_DIR}/backup.conf.example to ${CONFIG_FILE} and edit it."
fi

# Dispatch command
if [[ -n "$COMMAND" ]]; then
    case "$COMMAND" in
        backup)      "${BIN_DIR}/backup.sh" ;;
        restore)     "${BIN_DIR}/restore.sh" ;;
        list)        "${BIN_DIR}/status.sh" list ;;
        verify)      "${BIN_DIR}/verify.sh" ;;
        cleanup)     "${BIN_DIR}/cleanup.sh" ;;
        status)      "${BIN_DIR}/status.sh" config ;;
        diagnostics) "${BIN_DIR}/diagnostics.sh" ;;
    esac
else
    # Interactive mode
    interactive_mode
fi
