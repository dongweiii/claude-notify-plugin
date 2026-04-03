# Dismiss floating notification
Get-Process -Name "powershell" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*FloatingNotify.ps1*" } |
    Stop-Process -Force -ErrorAction SilentlyContinue

Remove-Item "$env:TEMP\claude_popup_*.flag" -Force -ErrorAction SilentlyContinue
