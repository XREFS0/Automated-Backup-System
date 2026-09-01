#!/usr/bin/env bash
#
# common.sh
# Shared variables, exit codes, and core utility functions.

# Exit Codes
readonly EXIT_OK=0
readonly EXIT_ERROR=1
readonly EXIT_INVALID_CONFIG=2
readonly EXIT_INVALID_ARGS=3
readonly EXIT_INSUFFICIENT_SPACE=4
readonly EXIT_VERIFICATION_FAILED=5
readonly EXIT_MISSING_DEPENDENCY=6

# Global constants
readonly APP_NAME="Automated Backup System"
readonly APP_VERSION="1.0.0"

# Set strict mode (defensive programming)
# Note: we don't 'set -Eeuo pipefail' globally here because it might break sourcing in unexpected ways,
# but we will enforce it in the main scripts.

# Prints the application header
print_header() {
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                  AUTOMATED BACKUP SYSTEM                     ║
║                     Backup Manager                           ║
╚══════════════════════════════════════════════════════════════╝
EOF
}

# Cleanup temporary files (trap handler)
cleanup_temp_files() {
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "${TEMP_DIR}" ]]; then
        # Ensure we are deleting a temp dir created by us
        if [[ "${TEMP_DIR}" == *"/abs-temp-"* ]]; then
            rm -rf "${TEMP_DIR}"
        fi
    fi
}
