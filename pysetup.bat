@echo off
setlocal enabledelayedexpansion

set "maindir=C:\ProgramData\VoltEnhanced"

if defined PROCESSOR_ARCHITEW6432 (
    set "arch=!PROCESSOR_ARCHITEW6432!"
) else (
    set "arch=!PROCESSOR_ARCHITECTURE!"
)
if /i "!arch!"=="AMD64" set "pyarch=amd64"
if /i "!arch!"=="x86"   set "pyarch=win32"
if /i "!arch!"=="ARM64" set "pyarch=arm64"
for /f %%i in ('powershell -NoProfile -Command "(Invoke-RestMethod -Uri 'https://endoflife.date/api/python.json')[0].latest"') do set "pyver=%%i"

set "installedver="
if exist "%maindir%\py\python.exe" (
    for /f "tokens=2" %%v in ('"%maindir%\py\python.exe" --version 2^>^&1') do set "installedver=%%v"
    if "!installedver!" neq "%pyver%" (
        rmdir /s /q "%maindir%\py"
        call :pyinstall
    )
) else (
    if exist "%maindir%\py" (
        rmdir /s /q "%maindir%\py"
    )
    call :pyinstall
)

if exist "%maindir%\py\python.exe" (
    echo %maindir%\py\python.exe
    exit /b 0
) else (
    exit /b 1
)

::funcs
:pyinstall
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; $url='https://www.python.org/ftp/python/%pyver%/python-%pyver%-embed-%pyarch%.zip'; $zip=Join-Path $env:TEMP 'python_embed.zip'; Invoke-WebRequest -Uri $url -OutFile $zip; Expand-Archive -Path $zip -DestinationPath '%maindir%\py' -Force; Remove-Item $zip"
goto :eof
