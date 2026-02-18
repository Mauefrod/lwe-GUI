#!/bin/bash
# async-window-fixer.sh - Asynchronous window flag manipulation utility
# Launches completely non-blocking window manipulation attempts in background

set -euo pipefail

# Source utilities
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bash_utils.sh"

ENGINE_PID="${1:-}"

if [[ -z "$ENGINE_PID" ]]; then
    log_error "Missing ENGINE_PID argument"
    exit 1
fi

log_debug "Async window fixer launched for PID $ENGINE_PID"

# Apply background processing flags to all engine windows
{
    local -a windows=()
    if mapfile -t windows < <(find_engine_windows 2>/dev/null || true); then
        if [[ ${#windows[@]} -gt 0 ]]; then
            log_debug "Found ${#windows[@]} engine windows"
            apply_flags_to_windows "${windows[@]}"
        else
            log_debug "No engine windows found to apply flags"
        fi
    else
        log_debug "Failed to detect engine windows"
    fi
} &

# Return immediately without waiting
exit 0
