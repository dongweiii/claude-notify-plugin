# Claude Code 浮窗通知插件

> **仅适用于 macOS**，依赖 Swift 和 Cocoa 框架实现原生浮窗。

macOS 上为 Claude Code 添加右上角置顶浮窗通知，支持 GIF 动画和静态图片。

## 功能

- **权限请求通知** — 需要你做判断时，右上角弹出 `need_help.gif`，做完判断后自动消失
- **任务完成通知** — Claude 干完活后，右上角弹出 `job_done.jpg`，10 秒后自动消失
- 浮窗始终置顶，不会被其他窗口遮挡
- 30 秒内防重复弹出

## 要求

- macOS
- Xcode Command Line Tools（`xcode-select --install`）
- Claude Code CLI

## 安装

```bash
bash install.sh
```

重启 Claude Code 即可生效。

## 自定义素材

替换 `sounds/` 目录下的文件即可：

- `sounds/need_help.gif` — 权限请求时显示
- `sounds/job_done.jpg` — 任务完成时显示

支持 GIF（动画）和 JPG/PNG（静态）格式。

## 文件说明

| 文件 | 说明 |
|------|------|
| `notify.sh` | 主通知脚本，被 hooks 调用 |
| `dismiss-notify.sh` | 关闭通知脚本，判断完成后自动调用 |
| `FloatingNotify.swift` | 浮窗程序源码，安装时编译 |
| `install.sh` | 一键安装脚本 |

## 卸载

```bash
rm -f ~/.claude/scripts/notify.sh ~/.claude/scripts/dismiss-notify.sh
rm -f ~/.claude/scripts/FloatingNotify.swift ~/.claude/scripts/floating-notify
rm -rf ~/.claude/scripts/sounds
```

然后手动删除 `~/.claude/settings.json` 中的 `PreToolUse`、`PermissionRequest`、`Stop` hooks。
