# ================================
# SRTCapcut Installer
# ================================

$AppName = "SRTCapcut"
$FolderName = "SRTCapcut"
$DriveUrl = "https://drive.google.com/uc?export=download&id=1cDYsfAGVXmymg4d94QsWKVhDze5BEZ7w"
$TempRAR = "$env:TEMP\SRTCapcut.rar"
$Desktop = [Environment]::GetFolderPath("Desktop")
$InstallPath = Join-Path $Desktop $FolderName
$ExeName = "SRTCapcutV1.0.exe"

if (Test-Path $InstallPath) {
    Write-Host "Folder $FolderName sudah ada di Desktop. Lewatkan download & extract." -ForegroundColor Yellow
    $TargetExe = Join-Path $InstallPath $ExeName

    if (Test-Path $TargetExe) {
        Write-Host "Menjalankan aplikasi..." -ForegroundColor Green
        Start-Process $TargetExe
        exit
    } else {
        Write-Host "File EXE tidak ditemukan. Installer akan download ulang." -ForegroundColor Red
    }
}

if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath | Out-Null
}

Write-Host "`nDownloading package..." -ForegroundColor Cyan

$Progress = @{
    Activity         = "Downloading"
    Status           = "Please wait..."
    PercentComplete  = 0
}

$webClient = New-Object System.Net.WebClient
$webClient.DownloadProgressChanged += {
    $Progress.PercentComplete = $_.ProgressPercentage
    Write-Progress @Progress
}
$webClient.DownloadFileCompleted += {
    Write-Host "Download complete!" -ForegroundColor Green
}

$webClient.DownloadFileAsync($DriveUrl, $TempRAR)

while ($webClient.IsBusy) {
    Start-Sleep -Milliseconds 200
}

Write-Host "Extracting package..." -ForegroundColor Green

try {
    tar -xf $TempRAR -C $InstallPath
} catch {
    Write-Host "Windows tidak bisa extract RAR dengan tar. Tolong install WinRAR atau 7-Zip." -ForegroundColor Red
    exit
}

Remove-Item $TempRAR -Force

$FinalExe = Join-Path $InstallPath $ExeName

if (Test-Path $FinalExe) {
    Write-Host "Menjalankan $ExeName ..." -ForegroundColor Green
    Start-Process $FinalExe
} else {
    Write-Host "EXE tidak ditemukan setelah extract." -ForegroundColor Red
}

Write-Host "Selesai!" -ForegroundColor Magenta
