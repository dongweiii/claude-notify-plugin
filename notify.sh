#!/bin/bash
# Claude Code Notify Hook - macOS version
# Usage: notify.sh <image_name> [title]
# 整个逻辑后台跑,hook 立即返回,不阻塞 Claude

IMAGE="$1"
TITLE="${2:-Claude Code}"

(
    SOUNDS_DIR="$HOME/.claude/scripts/sounds"
    FLAG_FILE="/tmp/claude_popup_${IMAGE}.flag"

    # Prevent duplicate popups within 30 seconds
    if [ -f "$FLAG_FILE" ]; then
        AGE=$(( $(date +%s) - $(stat -f %m "$FLAG_FILE") ))
        if [ "$AGE" -lt 30 ]; then
            exit 0
        fi
        rm -f "$FLAG_FILE"
    fi

    touch "$FLAG_FILE"

    # Kill any existing notification first
    pkill -f floating-notify 2>/dev/null

    IMAGE_PATH="$SOUNDS_DIR/$IMAGE"
    NOTIFY_BIN="$HOME/.claude/scripts/floating-notify"

    if [ -f "$IMAGE_PATH" ] && [ -x "$NOTIFY_BIN" ]; then
        "$NOTIFY_BIN" "$IMAGE_PATH" 10
        rm -f "$FLAG_FILE"
    else
        rm -f "$FLAG_FILE"
    fi
) </dev/null >/dev/null 2>&1 &
disown

exit 0
