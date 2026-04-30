@echo off
setlocal

:: ---------------------------------------------------------
:: makesymlink.cmd
:: Create a symbolic link with simple help text.
::
:: Usage:
::   makesymlink.cmd <LinkPath> <TargetPath> [/D|/J|/H]
::
::   <LinkPath>   = The path of the link to create
::   <TargetPath> = The real file or directory
::
::   /D = Directory symlink
::   /J = Junction (directory only, no admin needed)
::   /H = Hardlink (file only)
::
:: Examples:
::   makesymlink.cmd C:\Work\Logs C:\Data\Logs /D
::   makesymlink.cmd C:\Work\Data C:\Archive\Data /J
::   makesymlink.cmd C:\Work\config.ini C:\Real\config.ini /H
:: ---------------------------------------------------------

if "%~1"=="" (
    echo
    echo Usage: sudo win-link.cmd ^<LINK^> ^<TARGET^> [/D ^| /J ^| /H]
    echo Options:
    echo   /d: Creates a symbolic link "Link" for a directory "Target" (default is for files).
    echo   /h: Creates a hard link instead of a symbolic link.
    echo   /j: Creates a directory junction.
    echo
    echo Example: Creating a Symbolic Link for a Directory
    echo
    echo sudo win-link.cmd C:\MyLink C:\Users\User1\Documents /D
    echo
    echo This creates a symbolic link named MyLink in the C:\ directory that points to C:\Users\User1\Documents.
    echo
    echo Example: Creating a Hard Link for a File
    echo
    echo sudo win-link.cmd C:\MyFileLink.txt C:\Users\User1\Documents\example.txt /H
    echo
    echo This creates a hard link named MyFileLink.txt pointing to example.txt.
    echo
    echo Example: Creating a Directory Junction
    echo
    echo sudo win-link.cmd C:\MyJunction C:\Users\User1\Projects /J
    echo
    goto :EOF
)

if "%~3"=="" (
    echo Missing link type. Use /D, /J, or /H.
    goto :EOF
)

set LINK=%~1
set TARGET=%~2
set TYPE=%~3

echo Creating link:
echo   Link:   "%LINK%"
echo   Target: "%TARGET%"
echo   Type:   %TYPE%
echo

mklink %TYPE% "%LINK%" "%TARGET%"
if errorlevel 1 (
    echo
    echo Failed to create link.
    goto :EOF
)

echo
echo Link created successfully.
