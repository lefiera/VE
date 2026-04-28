@echo off
setlocal enabledelayedexpansion
set "main=C:\ProgramData\VoltEnhanced"

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
if exist "%main%\py\python.exe" (
    for /f "tokens=2" %%v in ('"%main%\py\python.exe" --version 2^>^&1') do set "installedver=%%v"
    if "!installedver!" neq "%pyver%" (
        rmdir /s /q "%main%\py"
        call :pyinstall
    )
) else (
    if exist "%main%\py" (
        rmdir /s /q "%main%\py"
    )
    call :pyinstall
)

if exist "%main%\py\python.exe" (
    echo %main%\py\python.exe
    exit /b 0
) else (
    exit /b 1
)

::funcs
:pyinstall
powershell -NoProfile -Command "$url='https://www.python.org/ftp/python/%pyver%/python-%pyver%-embed-%pyarch%.zip'; $zip=Join-Path $env:TEMP 'python_embed.zip'; Invoke-WebRequest -Uri $url -OutFile $zip; Expand-Archive -Path $zip -DestinationPath '%main%\py' -Force; Remove-Item $zip"
goto :eof
