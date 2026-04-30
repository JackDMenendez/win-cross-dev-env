@echo off
rem subroutine to set shell prompt
rem Must be called within saved local
set SAVED_SYSTEM_PROMPT=%PROMPT%
set SAVED_PROMPT=%CURRENT_PROMPT%
if "%SAVED_PROMPT%0" == "0" (
    set CURRENT_PROMPT=%1
) else (
    set CURRENT_PROMPT=%SAVED_PROMPT% %1
)
prompt (%CURRENT_PROMPT%)$_$p$g

exit /b 0
