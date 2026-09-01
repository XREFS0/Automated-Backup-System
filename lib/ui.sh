#!/usr/bin/env bash
#
# ui.sh
# Professional terminal user interface functions.

show_main_menu() {
    clear
    print_header
    
    # Calculate some dynamic values for the UI
    local os_info
    if command -v lsb_release >/dev/null 2>&1; then
        os_info=$(lsb_release -ds)
    elif [[ -f /etc/os-release ]]; then
        os_info=$(source /etc/os-release && echo "${PRETTY_NAME}")
    else
        os_info=$(uname -s)
    fi
    
    local avail_space
    if [[ -d "${BACKUP_DESTINATION:-}" ]]; then
        avail_space=$(df -h "${BACKUP_DESTINATION}" | tail -1 | awk '{print $4}')
    else
        avail_space="N/A"
    fi
    
    local last_backup="None"
    if [[ -d "${BACKUP_DESTINATION:-}" ]]; then
        local latest
        latest=$(ls -1t "${BACKUP_DESTINATION}"/backup_*.tar.gz 2>/dev/null | head -n 1)
        if [[ -n "${latest}" ]]; then
            last_backup=$(date -r "${latest}" '+%Y-%m-%d %H:%M:%S')
        fi
    fi
    
    cat << EOF

System Status
──────────────────────────────────────────────────────────────
Hostname        : $(hostname)
OS              : ${os_info}
Backup Storage  : ${BACKUP_DESTINATION:-Unconfigured}
Available Space : ${avail_space}
Last Backup     : ${last_backup}

Main Menu
──────────────────────────────────────────────────────────────

1) Create Backup
2) Restore Backup
3) List Backups
4) Verify Backup
5) Delete Expired Backups
6) Configuration Info
7) Run Diagnostics
0) Exit

EOF
    
    read -r -p "Select an option: " choice
    
    case "$choice" in
        1) "${BIN_DIR}/backup.sh" ;;
        2) "${BIN_DIR}/restore.sh" ;;
        3) "${BIN_DIR}/status.sh" list ;;
        4) "${BIN_DIR}/verify.sh" ;;
        5) "${BIN_DIR}/cleanup.sh" ;;
        6) "${BIN_DIR}/status.sh" config ;;
        7) "${BIN_DIR}/diagnostics.sh" ;;
        0) log_info "Exiting..."; exit 0 ;;
        *) log_warning "Invalid option."; sleep 1 ;;
    esac
}

interactive_mode() {
    while true; do
        show_main_menu
        read -r -p "Press Enter to continue..."
    done
}
