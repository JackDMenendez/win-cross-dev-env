:: requires.cmd - Check for required environment files and call them.
@echo off
echo building requirements %*
for %%P in (%*) do (
    if not exist "%~dp0%%P-env.cmd" (
        echo File "%~dp0%%P-env.cmd" not found
        exit /b 2
    )
    rem Use || so the exit code is read at runtime; %errorlevel% inside a
    rem for-block is expanded once at parse time and would never update.
    call "%~dp0%%P-env.cmd" || exit /b 1
)
rem --- Return to caller ---
exit /b 0

