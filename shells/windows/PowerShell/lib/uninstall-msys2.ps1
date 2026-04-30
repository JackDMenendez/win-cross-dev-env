# ============================================
# MSYS2 SAFE UNINSTALL SCRIPT
# ============================================

Write-Host "Checking for running MSYS2 processes..."

$procs = Get-Process | Where-Object {
    $_.Name -match "msys2|bash|mintty|pacman|sh|ucrt64|mingw64|clang64"
}

if ($procs) {
    Write-Host "ERROR: MSYS2-related processes are still running:"
    $procs | Select-Object Name, Id
    Write-Host "Close all MSYS2 terminals and retry."
    exit 1
}

Write-Host "No MSYS2 processes running."

# --------------------------------------------
# DIRECTORIES TO REMOVE
# --------------------------------------------

$dirs = @(
    "C:\msys64",
    "C:\usr",
    "C:\etc",
    "C:\var",
    "C:\home",
    "C:\home-backup",
    "C:\opt",
    "C:\.venv"
)

Write-Host "Scanning for stray POSIX directories..."

foreach ($d in $dirs) {
    if (Test-Path $d) {
        Write-Host "Found: $d"
    }
}

Write-Host ""
Write-Host "The above directories will be permanently deleted."
Write-Host "Press Y to continue, or anything else to abort."
$confirm = Read-Host

if ($confirm -ne "Y") {
    Write-Host "Aborted."
    exit 0
}

# --------------------------------------------
# DELETE DIRECTORIES
# --------------------------------------------

foreach ($d in $dirs) {
    if (Test-Path $d) {
        Write-Host "Deleting $d ..."
        Remove-Item -Recurse -Force $d
    }
}

Write-Host "All MSYS2-related directories removed."
Write-Host "System is now clean for a fresh MSYS2 install."
