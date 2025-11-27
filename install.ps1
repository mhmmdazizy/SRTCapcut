$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================================================
# VARIABLES
# ============================================================
$AppName = "SRTCapcut"
$FolderName = "SRTCapcut"
$Desktop = [Environment]::GetFolderPath("Desktop")
$InstallPath = Join-Path $Desktop $FolderName

$DownloadURL = "https://drive.google.com/uc?export=download&id=1cDYsfAGVXmymg4d94QsWKVhDze5BEZ7w"
$TempRAR = "$env:TEMP\SRTCapcut.rar"
$ExeName = "SRTCapcutV1.0.exe"


# ============================================================
# UI HELPERS
# ============================================================
function Write-Success {
    Write-Host " > OK" -ForegroundColor Green
}

function Write-Fail {
    Write-Host " > ERROR" -ForegroundColor Red
}

function Write-Step {
    param([string]$msg)
    Write-Host "`n$msg" -NoNewline
}


# ============================================================
# CHECKS
# ============================================================
function Test-PowerShellVersion {
    Write-Step "Checking PowerShell version..."
    if ($PSVersionTable.PSVersion -lt [version]'5.1') {
        Write-Fail
        Write-Warning "PowerShell 5.1 or newer required."
        exit
    }
    Write-Success
}

function Test-NotAdmin {
    Write-Step "Ensuring script is NOT running as Administrator..."
    $current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($current.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Fail
        Write-Warning "Please run without Administrator privileges."
        exit
    }
    Write-Success
}


# ============================================================
# DOWNLOAD (with progress)
# ============================================================
function Download-Package {
    Write-Step "Downloading package ($AppName)..."

    $response = Invoke-WebRequest -Uri $DownloadURL -OutFile $TempRAR -PassThru -UseBasicParsing

    $total = $response.RawContentLength
    $downloaded = 0

    # manual progress bar
    $fs = [System.IO.File]::OpenRead($TempRAR)
    try {
        while ($downloaded -lt $total) {
            Start-Sleep -Milliseconds 120
            $downloaded = $fs.Length
            $percent = [math]::Round(($downloaded/$total)*100,0)
            Write-Progress -Activity "Downloading..." -Status "$percent% complete" -PercentComplete $percent
        }
    } finally {
        $fs.Close()
    }

    Write-Success
}


# ============================================================
# INSTALLATION
# ============================================================
function Prepare-Folder {
    Write-Step "Preparing installation folder..."

    if (!(Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath | Out-Null
    }

    Write-Success
}

function Extract-Package {
    Write-Step "Extracting package to Desktop..."

    try {
        tar -xf $TempRAR -C $InstallPath
        Write-Success
    }
    catch {
        Write-Fail
        Write-Warning "Windows cannot extract .RAR by default. Install WinRAR / 7zip, or convert file to ZIP."
        exit
    }
}

function Cleanup-Temp {
    Write-Step "Cleaning temporary files..."
    if (Test-Path $TempRAR) { Remove-Item $TempRAR -Force }
    Write-Success
}

function Run-App {
    $exe = Join-Path $InstallPath $ExeName

    Write-Step "Launching $ExeName..."

    if (Test-Path $exe) {
        Start-Process $exe
        Write-Success
    } else {
        Write-Fail
        Write-Warning "$ExeName not found after extraction!"
    }
}

function Check-Existing {
    if (Test-Path $InstallPath) {
        Write-Host "`n$AppName already installed on Desktop." -ForegroundColor Yellow
        
        $exe = Join-Path $InstallPath $ExeName
        if (Test-Path $exe) {
            Write-Host "Launching existing install..." -ForegroundColor Cyan
            Start-Process $exe
            exit
        } else {
            Write-Host "EXE missing. Re-installing..." -ForegroundColor Red
        }
    }
}


# ============================================================
# MAIN PROCESS
# ============================================================
Test-PowerShellVersion
Test-NotAdmin
Check-Existing
Prepare-Folder
Download-Package
Extract-Package
Cleanup-Temp
Run-App

Write-Host "`n$AppName installation complete!" -ForegroundColor Green
