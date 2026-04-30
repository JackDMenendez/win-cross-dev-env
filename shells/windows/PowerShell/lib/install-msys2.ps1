# ================================
# MSYS2 CLEAN INSTALL SCRIPT
# ================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$installer = Join-Path $env:TEMP "msys2-installer.exe"
$msysRoot = "C:\msys64"
$bashExe = Join-Path $msysRoot "usr\bin\bash.exe"

function Invoke-BashCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $output = & $bashExe -lc $Command 2>&1
    if ($LASTEXITCODE -ne 0) {
        if ($output) {
            $output | Write-Host
        }

        throw "MSYS2 command failed with exit code ${LASTEXITCODE}: $Command"
    }

    return $output
}

Write-Host "Downloading MSYS2 installer..."
Invoke-WebRequest -Uri "https://github.com/msys2/msys2-installer/releases/latest/download/msys2-x86_64-latest.exe" -OutFile $installer

Write-Host "Running MSYS2 installer..."
$installerProcess = Start-Process $installer -ArgumentList "/S" -Wait -PassThru
if ($installerProcess.ExitCode -ne 0) {
    throw "MSYS2 installer failed with exit code $($installerProcess.ExitCode)."
}

if (-not (Test-Path $bashExe)) {
    throw "MSYS2 bash was not found at $bashExe after installation."
}

# --------------------------------
# STEP 1 - FIRST-RUN INITIALIZATION
# --------------------------------
Write-Host "Initializing MSYS2..."
Invoke-BashCommand -Command "true"
Write-Host "Initialization complete."

# --------------------------------
# STEP 2 - VERIFY BASIC LAYOUT
# --------------------------------
Write-Host "Verifying MSYS2 filesystem layout..."
Invoke-BashCommand -Command "test -d /usr && test -d /var/lib/pacman && test -x /usr/bin/pacman"
Write-Host "Filesystem layout OK."

# --------------------------------
# STEP 3 - UPDATE BASE SYSTEM
# --------------------------------
Write-Host "Updating base MSYS2 system..."
Invoke-BashCommand -Command "pacman -Syu --noconfirm"
Invoke-BashCommand -Command "pacman -Su --noconfirm"

# --------------------------------
# STEP 4 - INSTALL MSYS BASE TOOLS
# --------------------------------
Write-Host "Installing MSYS base tools..."
Invoke-BashCommand -Command "pacman -S --needed --noconfirm base-devel git jq lcov doxygen"

# --------------------------------
# STEP 5 - INSTALL UCRT64 TOOLCHAIN
# --------------------------------
Write-Host "Installing UCRT64 toolchain..."
Invoke-BashCommand -Command @"
pacman -S --needed --noconfirm \
    mingw-w64-ucrt-x86_64-gcc \
    mingw-w64-ucrt-x86_64-gdb \
    mingw-w64-ucrt-x86_64-cmake \
    mingw-w64-ucrt-x86_64-make \
    mingw-w64-ucrt-x86_64-python \
    mingw-w64-ucrt-x86_64-python-pip \
    mingw-w64-ucrt-x86_64-neovim \
    mingw-w64-ucrt-x86_64-nodejs \
    mingw-w64-ucrt-x86_64-nodejs-webpack-cli
"@

# --------------------------------
# STEP 6 - INSTALL MINGW64 TOOLCHAIN
# --------------------------------
Write-Host "Installing MINGW64 toolchain..."
Invoke-BashCommand -Command @"
pacman -S --needed --noconfirm \
    mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-gdb \
    mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-make \
    mingw-w64-x86_64-python \
    mingw-w64-x86_64-python-pip \
    mingw-w64-x86_64-tools
"@

# --------------------------------
# STEP 7 - INSTALL CLANG64 TOOLCHAIN
# --------------------------------
Write-Host "Installing CLANG64 toolchain..."
Invoke-BashCommand -Command @"
pacman -S --needed --noconfirm \
    mingw-w64-clang-x86_64-clang \
    mingw-w64-clang-x86_64-clang-tools-extra \
    mingw-w64-clang-x86_64-cmake \
    mingw-w64-clang-x86_64-make \
    mingw-w64-clang-x86_64-neovim
"@

Write-Host "MSYS2 installation complete."
