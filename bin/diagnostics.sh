#!/usr/bin/env bash
#
# diagnostics.sh
# Checks environmental dependencies and tools required for the backup system.

set -euo pipefail

main() {
    log_info "Running system diagnostics..."
    
    echo "Dependency Check"
    echo "──────────────────────────────────────────────────────────────"
    
    local deps=("bash" "tar" "gzip" "sha256sum" "awk" "date" "find" "rm" "du" "df")
    local missing=0
    
    for cmd in "${deps[@]}"; do
        if command -v "${cmd}" >/dev/null 2>&1; then
            local path
            path=$(command -v "${cmd}")
            printf "%-15s [OK]  %s\n" "${cmd}" "${path}"
        else
            printf "%-15s [ERR] Not found in PATH\n" "${cmd}"
            ((missing++))
        fi
    done
    
    echo ""
    echo "Configuration Check"
    echo "──────────────────────────────────────────────────────────────"
    
    if validate_config; then
        echo "Configuration state : VALID"
    else
        echo "Configuration state : INVALID"
    fi
    
    echo ""
    echo "System Info"
    echo "──────────────────────────────────────────────────────────────"
    echo "Bash Version  : ${BASH_VERSION}"
    echo "OS Kernel     : $(uname -r)"
    echo "User          : $(whoami)"
    
    if [[ ${missing} -gt 0 ]]; then
        log_warning "Diagnostics finished with warnings. Some dependencies are missing."
        return "${EXIT_MISSING_DEPENDENCY}"
    else
        log_success "Diagnostics passed. System is ready."
        return "${EXIT_OK}"
    fi
}

main "$@"
