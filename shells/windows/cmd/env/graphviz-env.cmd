:: graphviz-env.cmd - Graphviz `dot` for dependency graphs (leanblueprint web,
:: doxygen, plasTeX). Graphviz is a system install; this only puts it on PATH.
@echo off
if not "%SHELL_GRAPHVIZ_ENV%0"=="0" exit /b 0
set SHELL_GRAPHVIZ_ENV=1
call "%~dp0requires.cmd" global
if %errorlevel% neq 0 exit /b %errorlevel%
echo ------------ graphviz
:: WCDE_GRAPHVIZ_ACTIVE marks Graphviz as active for this session (parallels the
:: other *_ACTIVE markers; available to setup-vscode.cmd if ever needed).
set WCDE_GRAPHVIZ_ACTIVE=1
set "GRAPHVIZ_HOME=C:\Program Files\Graphviz"
if exist "%GRAPHVIZ_HOME%\bin\dot.exe" echo Adding Graphviz to path
if exist "%GRAPHVIZ_HOME%\bin\dot.exe" set "PATH=%GRAPHVIZ_HOME%\bin;%PATH%"
if not exist "%GRAPHVIZ_HOME%\bin\dot.exe" echo Warning: graphviz dot.exe not found at %GRAPHVIZ_HOME%\bin
exit /b 0
