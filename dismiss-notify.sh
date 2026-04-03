#!/bin/bash
# Dismiss floating notification
pkill -f floating-notify 2>/dev/null
rm -f /tmp/claude_popup_*.flag
rm -f /tmp/claude_notify_permission.pid
