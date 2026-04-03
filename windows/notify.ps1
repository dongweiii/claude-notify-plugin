# Claude Code Notify Hook - Windows version
# Usage: notify.ps1 <image_name> [title]

param(
    [Parameter(Mandatory=$true)][string]$Image,
    [string]$Title = "Claude Code"
)

$SoundsDir = "$env:USERPROFILE\.claude\scripts\sounds"
$FlagFile = "$env:TEMP\claude_popup_$Image.flag"

# Prevent duplicate popups within 30 seconds
if (Test-Path $FlagFile) {
    $age = (Get-Date) - (Get-Item $FlagFile).LastWriteTime
    if ($age.TotalSeconds -lt 30) {
        exit 0
    }
    Remove-Item $FlagFile -Force
}

New-Item $FlagFile -ItemType File -Force | Out-Null

# Kill any existing notification first
Get-Process -Name "powershell" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*FloatingNotify.ps1*" } |
    Stop-Process -Force -ErrorAction SilentlyContinue

# Show image in floating top-right window
$ImagePath = Join-Path $SoundsDir $Image
$NotifyScript = "$env:USERPROFILE\.claude\scripts\FloatingNotify.ps1"

if ((Test-Path $ImagePath) -and (Test-Path $NotifyScript)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$NotifyScript`" -ImagePath `"$ImagePath`" -Duration 10" -WindowStyle Hidden
}
