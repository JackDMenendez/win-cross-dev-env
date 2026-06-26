<#
    profile.ps1 - PowerShell profile for pwsh.exe.

    Mirrors the cmd-shell environment classes for PowerShell sessions:
      1. Adds Git and GitHub CLI to PATH (equivalent of env\git-cli-env.cmd).
      2. Adds R to PATH if installed (equivalent of env\R-env.cmd; needed for
         Quarto knitr R code cells).
      3. Activates the preferred Windows Python virtual environment
         (same discovery order as cmd\lib\python-activate.cmd).

    Hook it up by dot-sourcing it from your real pwsh profile ($PROFILE):

        . "J:\dev\wcde\shells\windows\PowerShell\profile.ps1"

    or copy/symlink it to one of the $PROFILE paths, e.g.
        $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

    Like the *-env.cmd scripts it is idempotent: re-sourcing it is a no-op
    for the work that has already been done in this session.
#>

# --- git-cli-env.cmd equivalent: Git + GitHub CLI on PATH ----------------
function Add-GitCliEnv {
    # Idempotent by PATH membership, NOT by an early-return on $env:SHELL_GIT_CLI_ENV.
    # A boolean guard is unsafe because the flag can be inherited as '1' from a
    # parent that built a *different* PATH (e.g. a cmd launcher); returning early
    # would then leave Git off this session's PATH. The prepend below strips any
    # existing entry first and the append checks membership, so re-running is a
    # no-op. SHELL_GIT_CLI_ENV is still published for external consumers.
    $env:SHELL_GIT_CLI_ENV = '1'

    $pf = $env:ProgramFiles

    # Remove any existing occurrence of $dir from PATH (case-insensitive,
    # trailing-slash tolerant) so prepend/append truly controls precedence.
    $strip = {
        param($dir)
        ($env:PATH -split ';' | Where-Object {
            $_ -and ($_.TrimEnd('\') -ne $dir.TrimEnd('\'))
        }) -join ';'
    }

    # Prepend git.exe + gh so Git-for-Windows wins over any MSYS2 git already on
    # PATH (e.g. C:\msys64\ucrt64\bin). Git\cmd is last so it lands at the front.
    foreach ($dir in @((Join-Path $pf 'GitHub CLI'), (Join-Path $pf 'Git\cmd'))) {
        if (Test-Path -LiteralPath $dir) {
            $env:PATH = "$dir;$(& $strip $dir)"
        }
    }

    # Append the rest of the toolchain so Git's coreutils don't shadow MSYS2's.
    foreach ($dir in @((Join-Path $pf 'Git\mingw64\bin'), (Join-Path $pf 'Git\usr\bin'))) {
        if ((Test-Path -LiteralPath $dir) -and (";$env:PATH;" -notlike "*;$dir;*")) {
            $env:PATH = "$env:PATH;$dir"
        }
    }
}

# --- R-env.cmd equivalent: R on PATH (needed for Quarto knitr R cells) ---
function Add-REnv {
    # Idempotent by PATH membership, NOT by an early-return on $env:SHELL_R_ENV.
    # A boolean guard is unsafe because the flag can be inherited as '1' from a
    # parent that built a different PATH (e.g. ucrt64-env.cmd exports SHELL_R_ENV);
    # returning early would then leave R off this session's PATH. The R-home
    # detection is guarded by IsNullOrEmpty and the append checks membership, so
    # re-running is a no-op. SHELL_R_ENV is still published for external consumers.
    $env:SHELL_R_ENV = '1'

    # Honor an externally-provided R home, else auto-detect the newest install
    # (semver-correct via [version] sort), falling back to the env\R-env.cmd default.
    if ([string]::IsNullOrEmpty($env:WCDE_R_HOME)) {
        $rRoot = 'C:\Program Files\R'
        if (Test-Path -LiteralPath $rRoot) {
            $newest = Get-ChildItem -LiteralPath $rRoot -Directory -Filter 'R-*' -ErrorAction SilentlyContinue |
                Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin\x64\R.exe') } |
                Sort-Object { try { [version]($_.Name -replace '^R-', '') } catch { [version]'0.0' } } |
                Select-Object -Last 1
            if ($newest) { $env:WCDE_R_HOME = $newest.FullName }
        }
        if ([string]::IsNullOrEmpty($env:WCDE_R_HOME)) {
            $env:WCDE_R_HOME = 'C:\Program Files\R\R-4.6.0'
        }
    }
    $env:WCDE_R_BIN_PATH = Join-Path $env:WCDE_R_HOME 'bin\x64'

    $rExe = Join-Path $env:WCDE_R_BIN_PATH 'R.exe'
    if ((Test-Path -LiteralPath $rExe) -and
        (";$env:PATH;" -notlike "*;$env:WCDE_R_BIN_PATH;*")) {
        $env:PATH = "$env:PATH;$env:WCDE_R_BIN_PATH"
    }
}

# --- python-activate.cmd equivalent: find + activate the venv ------------
function Get-PreferredVenv {
    # Same precedence as cmd\lib\python-activate.cmd, but resolving the
    # PowerShell activation script (Activate.ps1) instead of activate.bat.
    $candidates = @(
        (Join-Path $PWD '.venv-win'),
        (Join-Path $PWD '.venv_win64'),
        (Join-Path $PWD '.venv'),
        $env:DEV_SHELL_DEFAULT_VENV,
        (Join-Path $env:USERPROFILE '.venv')
    )

    foreach ($venv in $candidates) {
        if ([string]::IsNullOrEmpty($venv)) { continue }
        $activate = Join-Path $venv 'Scripts\Activate.ps1'
        if (Test-Path -LiteralPath $activate) {
            return [pscustomobject]@{ Path = $venv; Activate = $activate }
        }
    }
    return $null
}

function Enable-PreferredVenv {
    # Don't stomp an already-active environment (idempotent / nested-safe).
    if ($env:VIRTUAL_ENV) {
        Write-Host "[profile] Virtual environment already active: $env:VIRTUAL_ENV"
        return
    }

    $venv = Get-PreferredVenv
    if ($null -eq $venv) {
        Write-Host '[profile] No Python virtual environment found; skipping activation.'
        return
    }

    Write-Host "[profile] Activating virtual environment: $($venv.Path)"
    . $venv.Activate
}

# --- Run on profile load -------------------------------------------------
Add-GitCliEnv
Add-REnv
Enable-PreferredVenv
