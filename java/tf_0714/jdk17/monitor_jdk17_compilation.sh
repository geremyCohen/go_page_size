#!/bin/bash

# JDK17 TensorFlow Compilation Monitor
# Monitors the progress of JDK17 TensorFlow compilation

LOG_FILE="jdk17_compilation.log"
PID_FILE="jdk17_compilation.pid"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            JDK17 TensorFlow Compilation Monitor             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

# Function to check if compilation is running
check_compilation_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "✅ Compilation is RUNNING (PID: $pid)"
            return 0
        else
            echo "❌ Compilation process not found (PID: $pid)"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo "❌ No compilation process found"
        return 1
    fi
}

# Function to start compilation
start_compilation() {
    echo "Starting JDK17 TensorFlow compilation..."
    echo "This will take 4-5 hours on ARM64 system"
    echo "Started at: $(date)"
    echo
    
    # Start compilation in background
    nohup ./compile_tensorflow_jni_jdk17.sh > "$LOG_FILE" 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_FILE"
    
    echo "✅ Compilation started with PID: $pid"
    echo "📝 Log file: $LOG_FILE"
    echo "🔍 Monitor with: tail -f $LOG_FILE"
    echo
}

# Function to show progress
show_progress() {
    if [ -f "$LOG_FILE" ]; then
        echo "=== Compilation Progress ==="
        echo "Log file size: $(wc -l < "$LOG_FILE") lines"
        echo "Last updated: $(stat -c %y "$LOG_FILE")"
        echo
        echo "=== Recent Activity (last 10 lines) ==="
        tail -10 "$LOG_FILE"
        echo
        echo "=== Key Milestones ==="
        grep -E "(SUCCESS|FAILED|Building|Compiling|✅|❌)" "$LOG_FILE" | tail -5
    else
        echo "❌ No log file found"
    fi
}

# Function to show estimated completion
show_estimates() {
    if [ -f "$LOG_FILE" ]; then
        local start_time=$(stat -c %Y "$LOG_FILE")
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local elapsed_hours=$((elapsed / 3600))
        local elapsed_minutes=$(((elapsed % 3600) / 60))
        
        echo "=== Time Estimates ==="
        echo "Elapsed time: ${elapsed_hours}h ${elapsed_minutes}m"
        echo "Estimated total: 4-5 hours"
        
        if [ $elapsed_hours -lt 4 ]; then
            local remaining=$((4 * 3600 - elapsed))
            local remaining_hours=$((remaining / 3600))
            local remaining_minutes=$(((remaining % 3600) / 60))
            echo "Estimated remaining: ${remaining_hours}h ${remaining_minutes}m"
        else
            echo "Should be completing soon!"
        fi
    fi
}

# Main menu
case "${1:-status}" in
    "start")
        if check_compilation_status; then
            echo "Compilation is already running!"
        else
            start_compilation
        fi
        ;;
    "status")
        check_compilation_status
        echo
        show_progress
        echo
        show_estimates
        ;;
    "progress")
        show_progress
        ;;
    "stop")
        if [ -f "$PID_FILE" ]; then
            local pid=$(cat "$PID_FILE")
            echo "Stopping compilation (PID: $pid)..."
            kill "$pid" 2>/dev/null
            rm -f "$PID_FILE"
            echo "✅ Compilation stopped"
        else
            echo "❌ No compilation process to stop"
        fi
        ;;
    "log")
        if [ -f "$LOG_FILE" ]; then
            tail -f "$LOG_FILE"
        else
            echo "❌ No log file found"
        fi
        ;;
    *)
        echo "Usage: $0 {start|status|progress|stop|log}"
        echo
        echo "Commands:"
        echo "  start    - Start JDK17 TensorFlow compilation"
        echo "  status   - Show compilation status and progress"
        echo "  progress - Show recent compilation activity"
        echo "  stop     - Stop the compilation process"
        echo "  log      - Follow the compilation log in real-time"
        ;;
esac
