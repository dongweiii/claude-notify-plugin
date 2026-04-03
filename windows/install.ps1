# Claude Code 浮窗通知插件 - Windows 安装脚本
# 以管理员或普通用户身份运行: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = "$env:USERPROFILE\.claude\scripts"
$SoundsDir = "$TargetDir\sounds"
$SettingsFile = "$env:USERPROFILE\.claude\settings.json"

Write-Host "正在安装 Claude Code 浮窗通知插件..."

# Create directories
New-Item -ItemType Directory -Force -Path $SoundsDir | Out-Null

# Copy scripts
Copy-Item "$ScriptDir\FloatingNotify.ps1" $TargetDir -Force
Copy-Item "$ScriptDir\notify.ps1" $TargetDir -Force
Copy-Item "$ScriptDir\dismiss-notify.ps1" $TargetDir -Force

# Copy assets
Copy-Item "$ScriptDir\sounds\*" $SoundsDir -Force

# Merge hooks into settings.json
Write-Host "配置 hooks..."

$hooksConfig = @{
    PreToolUse = @(@{
        matcher = ".*"
        hooks = @(@{
            type = "command"
            command = "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:USERPROFILE\.claude\scripts\dismiss-notify.ps1`""
        })
    })
    PermissionRequest = @(@{
        matcher = ".*"
        hooks = @(@{
            type = "command"
            command = "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:USERPROFILE\.claude\scripts\notify.ps1`" need_help.gif `"Permission Required`""
        })
    })
    Stop = @(@{
        matcher = ""
        hooks = @(@{
            type = "command"
            command = "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:USERPROFILE\.claude\scripts\notify.ps1`" job_done.jpg `"Task Complete`""
        })
    })
}

$settings = @{}
if (Test-Path $SettingsFile) {
    $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json -AsHashtable
}

if (-not $settings.ContainsKey("hooks")) {
    $settings["hooks"] = @{}
}

foreach ($key in $hooksConfig.Keys) {
    $settings["hooks"][$key] = $hooksConfig[$key]
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8

Write-Host "安装完成！重启 Claude Code 即可生效。"
