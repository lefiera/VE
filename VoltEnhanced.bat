@echo off
setlocal enabledelayedexpansion

set "maindir=C:\ProgramData\VoltEnhanced"

if exist "%maindir%\pysetup.bat" (
    for /f "delims=" %%i in ('call "%maindir%\pysetup.bat"') do set "py=%%i"
    echo python path: !py!
) else (
    echo did the installer mess up? "%maindir%\pysetup.bat" doesnt exist.
)
