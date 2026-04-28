@echo off
setlocal enabledelayedexpansion

set "maindir=C:\ProgramData\VoltEnhanced"

if exist "%maindir%\pysetup.bat" (
    call "%maindir%\pysetup.bat"
) else (
    echo did the installer mess up? "%maindir%\pysetup.bat" doesnt exist.
)
