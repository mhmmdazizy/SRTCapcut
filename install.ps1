# ================================
# SRTCapcut Installer (Universal Version)
# ================================

$AppName = "SRTCapcut"
$FolderName = "SRTCapcut"
$DriveUrl = "https://drive.google.com/uc?export=download&id=1cDYsfAGVXmymg4d94QsWKVhDze5BEZ7w"
$TempRAR = "$env:TEMP\SRTCapcut.rar"
$Desktop = [Environment]::GetFolderPath("Desktop")
$InstallPath = Join-Path $Desktop $FolderName
$ExeName = "SRTCapcutV1.0.exe"

# === Cek apakah sudah pernah di-install ===
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

# === Pastikan folder Desktop ada ===
if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath | Out-Null
}

# === Download with progress (all PowerShell versions) ===
Write-Host "`nDownloading package..." -ForegroundColor Cyan

$Response = Invoke-WebRequest -Uri $DriveUrl -Method Get -UseBasicParsing -OutFile $TempRAR -PassThru

$Total = $Response.RawContentLength
$Downloaded = 0

# Manual progress bar
$fs = [System.IO.File]::OpenRead($TempRAR)
try {
    while ($Downloaded -lt $Total) {
        Start-Sleep -Milliseconds 100
        $Downloaded = $fs.Length
        $Percent = [math]::Round(($Downloaded / $Total) * 100, 0)

        Write-Progress -Activity "Downloading..." -Status "$Percent% completed" -PercentComplete $Percent
    }
} finally {
    $fs.Close()
}

Write-Host "Download complete!" -ForegroundColor Green

# === Extract RAR ===
Write-Host "Extracting package..." -ForegroundColor Green

try {
    tar -xf $TempRAR -C $InstallPath
} catch {
    Write-Host "Windows tidak bisa extract RAR. Tolong install WinRAR atau 7-Zip." -ForegroundColor Red
    exit
}

# === Hapus file sementara ===
Remove-Item $TempRAR -Force

# === Jalankan aplikasi ===
$FinalExe = Join-Path $InstallPath $ExeName

if (Test-Path $FinalExe) {
    Write-Host "Menjalankan $ExeName ..." -ForegroundColor Green
    Start-Process $FinalExe
} else {
    Write-Host "EXE tidak ditemukan setelah extract." -ForegroundColor Red
}

Write-Host "Selesai!" -ForegroundColor Magenta
