#!/bin/bash
# Claude Code 浮窗通知插件 - 安装脚本
# 直接运行: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$HOME/.claude/scripts"
SOUNDS_DIR="$SCRIPTS_DIR/sounds"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "正在安装 Claude Code 浮窗通知插件..."

# 创建目录
mkdir -p "$SOUNDS_DIR"

# 复制脚本
cp "$SCRIPT_DIR/notify.sh" "$SCRIPTS_DIR/"
cp "$SCRIPT_DIR/dismiss-notify.sh" "$SCRIPTS_DIR/"
cp "$SCRIPT_DIR/FloatingNotify.swift" "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/notify.sh" "$SCRIPTS_DIR/dismiss-notify.sh"

# 复制素材
cp "$SCRIPT_DIR/sounds/need_help.gif" "$SOUNDS_DIR/"
cp "$SCRIPT_DIR/sounds/job_done.jpg" "$SOUNDS_DIR/"

# 编译 Swift 浮窗程序
echo "编译浮窗程序..."
if command -v swiftc &>/dev/null; then
    swiftc -o "$SCRIPTS_DIR/floating-notify" "$SCRIPTS_DIR/FloatingNotify.swift" -framework Cocoa -framework ImageIO
    chmod +x "$SCRIPTS_DIR/floating-notify"
    echo "编译成功"
else
    echo "错误: 未找到 swiftc，请先安装 Xcode Command Line Tools: xcode-select --install"
    exit 1
fi

# 合并 hooks 配置到 settings.json
echo "配置 hooks..."
python3 << 'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")
hooks_config = {
    "PreToolUse": [{
        "matcher": ".*",
        "hooks": [{"type": "command", "command": "bash ~/.claude/scripts/dismiss-notify.sh"}]
    }],
    "PermissionRequest": [{
        "matcher": ".*",
        "hooks": [{"type": "command", "command": "bash ~/.claude/scripts/notify.sh need_help.gif 'Permission Required'"}]
    }],
    "Stop": [{
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash ~/.claude/scripts/notify.sh job_done.jpg 'Task Complete'"}]
    }]
}

settings = {}
if os.path.exists(settings_path):
    with open(settings_path, 'r') as f:
        settings = json.load(f)

if "hooks" not in settings:
    settings["hooks"] = {}
for k, v in hooks_config.items():
    settings["hooks"][k] = v

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
PYEOF

echo "安装完成！重启 Claude Code 即可生效。"
