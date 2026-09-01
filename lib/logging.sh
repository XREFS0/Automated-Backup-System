#!/usr/bin/env bash
#
# logging.sh
# Structured logging with color support.

# Colors
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    readonly C_RESET='\033[0m'
    readonly C_INFO='\033[36m'
    readonly C_SUCCESS='\033[32m'
    readonly C_WARNING='\033[33m'
    readonly C_ERROR='\033[31m'
    readonly C_DEBUG='\033[35m'
else
    readonly C_RESET=''
    readonly C_INFO=''
    readonly C_SUCCESS=''
    readonly C_WARNING=''
    readonly C_ERROR=''
    readonly C_DEBUG=''
fi

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_SUCCESS=4

# Default min level
MIN_LOG_LEVEL=${LOG_LEVEL_INFO}

set_log_level() {
    local level=$1
    if [[ "$level" == "DEBUG" ]]; then
        MIN_LOG_LEVEL=${LOG_LEVEL_DEBUG}
    elif [[ "$level" == "QUIET" ]]; then
        MIN_LOG_LEVEL=${LOG_LEVEL_ERROR}
    fi
}

_log() {
    local level_name=$1
    local color=$2
    local message=$3
    local msg_level=$4
    local log_file="${LOG_DIRECTORY:-}/backup.log"

    if [[ ${msg_level} -ge ${MIN_LOG_LEVEL} ]]; then
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local formatted_message="${timestamp} [${level_name}] ${message}"
        
        # Print to console with color
        echo -e "${color}${timestamp} [${level_name}] ${message}${C_RESET}" >&2
        
        # Append to log file if directory is set and exists
        if [[ -n "${LOG_DIRECTORY:-}" ]] && [[ -d "${LOG_DIRECTORY}" ]]; then
            echo "${formatted_message}" >> "${log_file}"
        fi
    fi
}

log_debug()   { _log "DEBUG"   "${C_DEBUG}"   "$1" "${LOG_LEVEL_DEBUG}"; }
log_info()    { _log "INFO"    "${C_INFO}"    "$1" "${LOG_LEVEL_INFO}"; }
log_success() { _log "SUCCESS" "${C_SUCCESS}" "$1" "${LOG_LEVEL_SUCCESS}"; }
log_warning() { _log "WARNING" "${C_WARNING}" "$1" "${LOG_LEVEL_WARNING}"; }
log_error()   { _log "ERROR"   "${C_ERROR}"   "$1" "${LOG_LEVEL_ERROR}"; }
