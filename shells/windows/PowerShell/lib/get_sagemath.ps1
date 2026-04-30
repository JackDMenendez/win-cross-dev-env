# install-sagemath.ps1
$repo = "sagemath/sage-windows"

Write-Host "Fetching latest SageMath release info..."
$release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$repo/releases/latest" `
    -Headers @{ "User-Agent" = "PowerShell" }

$asset = $release.assets | Where-Object { $_.name -match "Windows" -and $_.name -match "\.exe$" }

if (-not $asset) {
    Write-Error "No Windows installer found in latest release"
    exit 1
}

$destination = "$PSScriptRoot\downloads\$($asset.name)"
New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null

Write-Host "Downloading SageMath: $($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $destination

Write-Host "Download complete: $destination"

# Optional: run installer
# Start-Process -FilePath $destination -ArgumentList "/S" -Wait

Write-Host "SageMath installer ready."

