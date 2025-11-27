$ZipUrl = "https://drive.google.com/uc?export=download&id=1cDYsfAGVXmymg4d94QsWKVhDze5BEZ7w"
$ZipPath = "$env:TEMP\package.zip"
$ExtractPath = [Environment]::GetFolderPath("Desktop")

Write-Host "Downloading ZIP package..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath

Write-Host "Extracting to Desktop..." -ForegroundColor Green
Expand-Archive -LiteralPath $ZipPath -DestinationPath $ExtractPath -Force

Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item $ZipPath -Force

Write-Host "Done! Files extracted to your Desktop." -ForegroundColor Magenta
