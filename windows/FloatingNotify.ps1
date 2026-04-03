Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

param(
    [Parameter(Mandatory=$true)][string]$ImagePath,
    [int]$Duration = 10
)

if (-not (Test-Path $ImagePath)) {
    Write-Error "File not found: $ImagePath"
    exit 1
}

# Create form
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.Size = New-Object System.Drawing.Size(200, 200)
$form.BackColor = [System.Drawing.Color]::White

# Round corners
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 24
$rect = New-Object System.Drawing.Rectangle(0, 0, 200, 200)
$path.AddArc($rect.X, $rect.Y, $radius, $radius, 180, 90)
$path.AddArc($rect.X + $rect.Width - $radius, $rect.Y, $radius, $radius, 270, 90)
$path.AddArc($rect.X + $rect.Width - $radius, $rect.Y + $rect.Height - $radius, $radius, $radius, 0, 90)
$path.AddArc($rect.X, $rect.Y + $rect.Height - $radius, $radius, $radius, 90, 90)
$path.CloseFigure()
$form.Region = New-Object System.Drawing.Region($path)

# Position top-right
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$form.Location = New-Object System.Drawing.Point(($screen.Right - 216), ($screen.Top + 16))

# PictureBox for image/GIF
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$pictureBox.Image = [System.Drawing.Image]::FromFile($ImagePath)
$form.Controls.Add($pictureBox)

# Draggable
$dragging = $false
$dragStart = New-Object System.Drawing.Point(0, 0)

$pictureBox.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:dragging = $true
        $script:dragStart = $e.Location
    }
})

$pictureBox.Add_MouseMove({
    param($sender, $e)
    if ($script:dragging) {
        $form.Location = New-Object System.Drawing.Point(
            ($form.Location.X + $e.X - $script:dragStart.X),
            ($form.Location.Y + $e.Y - $script:dragStart.Y)
        )
    }
})

$pictureBox.Add_MouseUp({
    param($sender, $e)
    $script:dragging = $false
})

# Auto-close timer
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $Duration * 1000
$timer.Add_Tick({
    $form.Close()
})
$timer.Start()

# Show
[System.Windows.Forms.Application]::Run($form)

# Cleanup
$pictureBox.Image.Dispose()
$timer.Dispose()
