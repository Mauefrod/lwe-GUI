#!/bin/bash
# debug-processes.sh - Debug script to diagnose process termination issues
# Shows all running processes related to the wallpaper engine

set -euo pipefail

echo "========== LINUX WALLPAPER ENGINE - PROCESS DEBUG =========="
echo ""

# Check for engine processes
echo "[1] Checking for linux-wallpaperengine processes:"
if pgrep -f "linux-wallpaperengine" >/dev/null 2>&1; then
    pgrep -f "linux-wallpaperengine" | while read -r pid; do
        cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "unknown")
        ppid=$(ps -p "$pid" -o ppid= 2>/dev/null || echo "?")
        echo "  PID=$pid, PPID=$ppid, CMD=$cmd"
    done
else
    echo "  No processes found"
fi
echo ""

# Check for main.sh processes
echo "[2] Checking for main.sh processes:"
if pgrep -f "bash.*main.sh" >/dev/null 2>&1; then
    pgrep -f "bash.*main.sh" | while read -r pid; do
        cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "unknown")
        ppid=$(ps -p "$pid" -o ppid= 2>/dev/null || echo "?")
        echo "  PID=$pid, PPID=$ppid, CMD=$cmd"
    done
else
    echo "  No processes found"
fi
echo ""

# Check for window-monitor processes
echo "[3] Checking for window-monitor processes:"
if pgrep -f "window-monitor.sh" >/dev/null 2>&1; then
    pgrep -f "window-monitor.sh" | while read -r pid; do
        cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "unknown")
        ppid=$(ps -p "$pid" -o ppid= 2>/dev/null || echo "?")
        echo "  PID=$pid, PPID=$ppid, CMD=$cmd"
    done
else
    echo "  No processes found"
fi
echo ""

# Check state files
echo "[4] Checking state files:"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/linux-wallpaper-engine-features"
PID_FILE="$DATA_DIR/loop.pid"
ENGINE_STATE_FILE="$DATA_DIR/engine_state.json"

if [[ -f "$PID_FILE" ]]; then
    loop_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
    echo "  Loop PID file: $PID_FILE"
    echo "    Contents: $loop_pid"
    if [[ -n "$loop_pid" ]] && kill -0 "$loop_pid" 2>/dev/null; then
        echo "    Status: RUNNING"
    else
        echo "    Status: NOT RUNNING"
    fi
else
    echo "  No loop PID file found"
fi
echo ""

if [[ -f "$ENGINE_STATE_FILE" ]]; then
    echo "  Engine state file: $ENGINE_STATE_FILE"
    cat "$ENGINE_STATE_FILE"
else
    echo "  No engine state file found"
fi
echo ""

# Check logs
echo "[5] Latest log entries:"
LOG_FILE="$DATA_DIR/logs.txt"
if [[ -f "$LOG_FILE" ]]; then
    echo "  Last 20 lines from: $LOG_FILE"
    tail -20 "$LOG_FILE" | sed 's/^/    /'
else
    echo "  No log file found"
fi
echo ""

echo "========== END DEBUG REPORT =========="
