<#
    bootstrap.ps1
    Joaquin’s reproducible Windows dev environment bootstrapper
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "=== Joaquin Dev Environment Bootstrap ==="

# ------------------------------------------------------------
# 1. Install Chocolatey (if missing)
# ------------------------------------------------------------
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[bootstrap] Installing Chocolatey..."

    Set-ExecutionPolicy Bypass -Scope Process -Force

    $chocoInstallScript = "$env:TEMP\choco-install.ps1"
    Invoke-WebRequest `
        -Uri "https://community.chocolatey.org/install.ps1" `
        -OutFile $chocoInstallScript

    # Run in a NEW PowerShell process so it cannot kill this one
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$chocoInstallScript`"" -Wait

    Write-Host "[bootstrap] Chocolatey installed."
} else {
    Write-Host "[bootstrap] Chocolatey already installed."
}

# ------------------------------------------------------------
# 2. Install core tools via Chocolatey
# ------------------------------------------------------------
$packages = @(
    "git",
    "neovim",
    "vscode",
    "cmake",
    "ninja",
    "python",
    "msys2",
    "7zip",
    "ripgrep",
    "fzf",
    "fd",
    "llvm",
    "texlive"
)

Write-Host "[bootstrap] Installing core packages..."
foreach ($pkg in $packages) {
    choco install $pkg -y --no-progress
}

# ------------------------------------------------------------
# 3. Ensure directory structure exists
# ------------------------------------------------------------
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = (Resolve-Path (Join-Path $scriptRoot "..\..\..\..")).Path
$dirs = @(
    "$root",
    "$root\env",
    "$root\shells",
    "$root\setup",
    "$root\tools"
)

foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        Write-Host "[bootstrap] Creating $d"
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
}

# ------------------------------------------------------------
# 4. Clone or update the dev-shell repo
# ------------------------------------------------------------
$repoUrl = "https://github.com/YOURNAME/dev-shell.git"

if (-not (Test-Path "$root\.git")) {
    Write-Host "[bootstrap] Cloning dev-shell repo..."
    git clone $repoUrl $root
} else {
    Write-Host "[bootstrap] Updating dev-shell repo..."
    Push-Location $root
    git pull
    Pop-Location
}

# ------------------------------------------------------------
# 5. Download SageMath using your existing script
# ------------------------------------------------------------
$script = "$root\setup\get_sagemath.ps1"
if (Test-Path $script) {
    Write-Host "[bootstrap] Running SageMath downloader..."
    & $script
} else {
    Write-Host "[bootstrap] WARNING: get_sagemath.ps1 not found."
}

$extFile = "$root\vscode\extensions.txt"
if (Test-Path $extFile) {
    Write-Host "[bootstrap] Installing VS Code extensions..."
    $extensions = Get-Content $extFile
    foreach ($ext in $extensions) {
        code --install-extension $ext --force
    }
}

# ------------------------------------------------------------
# 6. Final message
# ------------------------------------------------------------
Write-Host "`n=== Bootstrap complete ==="
Write-Host "Your dev environment is ready."

