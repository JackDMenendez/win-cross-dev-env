@echo off
rem Subroutine to restore previous prompt

if not "%SAVED_PROMPT%0" == "0" goto restore_saved_prompt

prompt %SAVED_SYSTEM_PROMPT%
exit /b 0

:restore_saved_prompt

prompt (%SAVED_PROMPT%)$_$p$g

rem --- Return to caller ---
exit /b 0

