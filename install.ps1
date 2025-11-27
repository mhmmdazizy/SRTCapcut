# ================================
# SRTCapcut Installer (Stable Version)
# ================================
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -----------------------------------
# Variables
# -----------------------------------
$DesktopFolder = [Environment]::GetFolderPath("Desktop")
$TargetFolder = Join-Path $DesktopFolder "SRTCapcut"
$ZipUrl = "https://drive.google.com/uc?export=download&id=1cDYsfAGVXmymg4d94QsWKVhDze5BEZ7w"
$ZipPath = Join-Path $env:TEMP "srtcapcut_download.zip"

# -----------------------------------
# Helper Functions
# -----------------------------------
function Write-Success { Write-Host " > OK" -ForegroundColor Green }
function Write-Unsuccess { Write-Host " > ERROR" -ForegroundColor Red }

# -----------------------------------
# Create Folder on Desktop
# -----------------------------------
function Ensure-TargetFolder {
    Write-Host "Checking installation folder..." -NoNewline
    if (-not (Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder | Out-Null
    }
    Write-Success
}

# -----------------------------------
# Check if Already Installed
# -----------------------------------
function Check-PreviousInstall {
    Write-Host "Checking previous installation..." -NoNewline
    $exe = Join-Path $TargetFolder "SRTCapcutV1.0.exe"

    if (Test-Path $exe) {
        Write-Host "`nSRTCapcut sudah terinstal di:"
        Write-Host $TargetFolder -ForegroundColor Cyan

        $choices = @(
            (New-Object System.Management.Automation.Host.ChoiceDescription "&Reinstall", "Install ulang (overwrite)."),
            (New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Batalkan.")
        )
        $choice = $Host.UI.PromptForChoice("", "Apa yang ingin kamu lakukan?", $choices, 1)

        if ($choice -eq 1) {
            Write-Host "Installation aborted." -ForegroundColor Yellow
            exit
        }
    }
    Write-Success
}

# -----------------------------------
# Download ZIP with manual progress bar
# -----------------------------------
function Download-ZipFile {
    Write-Host "Downloading SRTCapcut package..."

    $response = Invoke-WebRequest -Uri $ZipUrl -Method GET -OutFile $ZipPath -PassThru

    $total = $response.RawContentLength
    $got = 0

    Write-Progress -Activity "Preparing..." -Status "Starting" -PercentComplete 0

    $stream = [System.IO.File]::OpenRead($ZipPath)
    $buffer = New-Object byte[] (1MB)

    while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $got += $read
        $percent = [math]::Round(($got / $total) * 100)
        Write-Progress -Activity "Downloading..." -Status "$percent% completed" -PercentComplete $percent
    }

    $stream.Close()
    Write-Host "`nDownload completed." -ForegroundColor Green
}

# -----------------------------------
# Extract ZIP
# -----------------------------------
function Extract-Zip {
    Write-Host "Extracting files..." -NoNewline
    Expand-Archive -Path $ZipPath -DestinationPath $TargetFolder -Force
    Write-Success
}

# -----------------------------------
# Run EXE with Correct Working Directory
# -----------------------------------
function Run-App {
    $exePath = Join-Path $TargetFolder "SRTCapcutV1.0.exe"

    if (Test-Path $exePath) {
        Write-Host "Launching SRTCapcut..." -ForegroundColor Cyan
        Start-Process -FilePath $exePath -WorkingDirectory $TargetFolder
    } else {
        Write-Host "Executable not found!" -ForegroundColor Red
    }
}

# -----------------------------------
# MAIN
# -----------------------------------
Write-Host "`n=== SRTCapcut Installer ===" -ForegroundColor Cyan

Ensure-TargetFolder
Check-PreviousInstall
Download-ZipFile
Extract-Zip
Run-App

Write-Host "`nInstallation finished!" -ForegroundColor Green
Write-Host "Folder: $TargetFolder" -ForegroundColor Yellow
