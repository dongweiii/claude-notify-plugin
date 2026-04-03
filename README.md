# Claude Code 浮窗通知插件

为 Claude Code 添加右上角置顶浮窗通知，支持 GIF 动画和静态图片。

支持 **macOS** 和 **Windows**。

## 功能

- **权限请求通知** — 需要你做判断时，右上角弹出 `need_help.gif`，做完判断后自动消失
- **任务完成通知** — Claude 干完活后，右上角弹出 `job_done.jpg`，10 秒后自动消失
- 浮窗始终置顶，不会被其他窗口遮挡
- 浮窗可拖动
- 30 秒内防重复弹出

## macOS 安装

> 依赖 Swift 和 Cocoa 框架，需要 Xcode Command Line Tools（`xcode-select --install`）

```bash
bash install.sh
```

## Windows 安装

> 依赖 PowerShell 和 .NET WinForms，Windows 10+ 自带，无需额外安装。

```powershell
powershell -ExecutionPolicy Bypass -File windows\install.ps1
```

## 自定义素材

替换 `sounds/` 目录下的文件即可：

- `sounds/need_help.gif` — 权限请求时显示
- `sounds/job_done.jpg` — 任务完成时显示

支持 GIF（动画）和 JPG/PNG（静态）格式。

## 文件说明

### macOS

| 文件 | 说明 |
|------|------|
| `notify.sh` | 主通知脚本，被 hooks 调用 |
| `dismiss-notify.sh` | 关闭通知脚本，判断完成后自动调用 |
| `FloatingNotify.swift` | 浮窗程序源码，安装时编译 |
| `install.sh` | 一键安装脚本 |

### Windows

| 文件 | 说明 |
|------|------|
| `windows/notify.ps1` | 主通知脚本，被 hooks 调用 |
| `windows/dismiss-notify.ps1` | 关闭通知脚本，判断完成后自动调用 |
| `windows/FloatingNotify.ps1` | 浮窗程序，PowerShell + WinForms 实现 |
| `windows/install.ps1` | 一键安装脚本 |

## 卸载

### macOS

```bash
rm -f ~/.claude/scripts/notify.sh ~/.claude/scripts/dismiss-notify.sh
rm -f ~/.claude/scripts/FloatingNotify.swift ~/.claude/scripts/floating-notify
rm -rf ~/.claude/scripts/sounds
```

### Windows

```powershell
Remove-Item "$env:USERPROFILE\.claude\scripts\notify.ps1" -Force
Remove-Item "$env:USERPROFILE\.claude\scripts\dismiss-notify.ps1" -Force
Remove-Item "$env:USERPROFILE\.claude\scripts\FloatingNotify.ps1" -Force
Remove-Item "$env:USERPROFILE\.claude\scripts\sounds" -Recurse -Force
```

卸载后手动删除 `~/.claude/settings.json` 中的 `PreToolUse`、`PermissionRequest`、`Stop` hooks。
