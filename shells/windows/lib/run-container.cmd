:: run-container.cmd - Run a command inside the repo-configured container image.
@echo off
setlocal EnableExtensions EnableDelayedExpansion

if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--help" goto :show_help
if "%~1"=="" goto :show_help_error

set "SEARCH_DIR=%CD%"

:find_config
if exist "%SEARCH_DIR%\.dev-shell\container.conf" (
    set "REPO_DIR=%SEARCH_DIR%"
    set "CONFIG_PATH=%SEARCH_DIR%\.dev-shell\container.conf"
    goto :load_config
)

for %%I in ("%SEARCH_DIR%\..") do set "PARENT_DIR=%%~fI"
if /i "%PARENT_DIR%"=="%SEARCH_DIR%" goto :config_not_found
set "SEARCH_DIR=%PARENT_DIR%"
goto :find_config

:load_config
set "DEV_SHELL_CONTAINER_ENGINE="
set "DEV_SHELL_CONTAINER_IMAGE="
set "DEV_SHELL_CONTAINER_WORKDIR=/workspace"
set "DEV_SHELL_CONTAINER_ENV_PASSTHROUGH="
set "DEV_SHELL_CONTAINER_CACHE_VOLUMES="
set "DEV_SHELL_CONTAINER_EXTRA_ARGS="

for /f "usebackq tokens=1* delims==" %%A in ("%CONFIG_PATH%") do (
    if not "%%A"=="" if /i not "%%A"=="#" (
        if /i "%%A"=="DEV_SHELL_CONTAINER_ENGINE" set "DEV_SHELL_CONTAINER_ENGINE=%%B"
        if /i "%%A"=="DEV_SHELL_CONTAINER_IMAGE" set "DEV_SHELL_CONTAINER_IMAGE=%%B"
        if /i "%%A"=="DEV_SHELL_CONTAINER_WORKDIR" set "DEV_SHELL_CONTAINER_WORKDIR=%%B"
        if /i "%%A"=="DEV_SHELL_CONTAINER_ENV_PASSTHROUGH" set "DEV_SHELL_CONTAINER_ENV_PASSTHROUGH=%%B"
        if /i "%%A"=="DEV_SHELL_CONTAINER_CACHE_VOLUMES" set "DEV_SHELL_CONTAINER_CACHE_VOLUMES=%%B"
        if /i "%%A"=="DEV_SHELL_CONTAINER_EXTRA_ARGS" set "DEV_SHELL_CONTAINER_EXTRA_ARGS=%%B"
    )
)

if not defined DEV_SHELL_CONTAINER_IMAGE (
    echo DEV_SHELL_CONTAINER_IMAGE is required in "%CONFIG_PATH%"
    exit /b 1
)

if not defined DEV_SHELL_CONTAINER_ENGINE (
    where /q docker
    if not errorlevel 1 (
        set "DEV_SHELL_CONTAINER_ENGINE=docker"
    ) else (
        where /q podman
        if not errorlevel 1 (
            set "DEV_SHELL_CONTAINER_ENGINE=podman"
        ) else (
            echo No container engine found. Install docker or podman, or set DEV_SHELL_CONTAINER_ENGINE.
            exit /b 1
        )
    )
)

where /q "%DEV_SHELL_CONTAINER_ENGINE%"
if errorlevel 1 (
    echo Configured container engine not found: %DEV_SHELL_CONTAINER_ENGINE%
    exit /b 1
)

set "ENV_ARGS="
for %%V in (%DEV_SHELL_CONTAINER_ENV_PASSTHROUGH%) do (
    set "ENV_ARGS=!ENV_ARGS! --env %%V"
)

set "CACHE_ARGS="
for %%V in (%DEV_SHELL_CONTAINER_CACHE_VOLUMES%) do (
    set "CACHE_ARGS=!CACHE_ARGS! --volume %%V"
)

"%DEV_SHELL_CONTAINER_ENGINE%" run --rm -i -v "%REPO_DIR%:%DEV_SHELL_CONTAINER_WORKDIR%" -w "%DEV_SHELL_CONTAINER_WORKDIR%" %ENV_ARGS% %CACHE_ARGS% %DEV_SHELL_CONTAINER_EXTRA_ARGS% "%DEV_SHELL_CONTAINER_IMAGE%" %*
set "RUN_CONTAINER_RC=%ERRORLEVEL%"
endlocal & exit /b %RUN_CONTAINER_RC%

:config_not_found
echo Container config not found. Expected .dev-shell\container.conf in the current repo or a parent directory.
exit /b 1

:show_help
echo Usage: %~nx0 [-h^|--help] ^<command^> [args...]
echo Runs a command inside the container configured by .dev-shell\container.conf.
echo.
echo Config variables recognized:
echo   DEV_SHELL_CONTAINER_ENGINE           Optional. Defaults to docker or podman if found.
echo   DEV_SHELL_CONTAINER_IMAGE            Required. Image to run.
echo   DEV_SHELL_CONTAINER_WORKDIR          Optional. Defaults to /workspace.
echo   DEV_SHELL_CONTAINER_ENV_PASSTHROUGH  Optional. Space-separated environment names.
echo   DEV_SHELL_CONTAINER_CACHE_VOLUMES    Optional. Space-separated volume specs.
echo   DEV_SHELL_CONTAINER_EXTRA_ARGS       Optional. Extra engine run arguments.
exit /b 0

:show_help_error
call :show_help
exit /b 1