@echo off
setlocal enabledelayedexpansion

set "maindir=C:\ProgramData\VoltEnhanced"
set "baseurl=https://raw.githubusercontent.com/lefiera/VE/refs/heads/main/src/"
set "filelist=main.py"

if not exist "%~f0" (
    goto :SkipShortcuts
)

if not exist "%maindir%\VoltEnhanced.lnk" (
    powershell -Command "$ws=New-Object -ComObject WScript.Shell; $sc=$ws.CreateShortcut('%maindir%\VoltEnhanced.lnk'); $sc.TargetPath='%~f0'; $sc.Save()"
    if errorlevel 1 echo ERROR: failed to create shortcut in %maindir%.
)
if not exist "%USERPROFILE%\Desktop\VoltEnhanced.lnk" (
    powershell -Command "$ws=New-Object -ComObject WScript.Shell; $sc=$ws.CreateShortcut('%USERPROFILE%\Desktop\VoltEnhanced.lnk'); $sc.TargetPath='%~f0'; $sc.Save()"
    if errorlevel 1 echo ERROR: failed to create Desktop shortcut.
)

:SkipShortcuts

if exist "%maindir%\envsetup.bat" (
    echo checking if VoltEnhanced environment is setup properly or not..
    call "%maindir%\envsetup.bat
    set "py=%maindir%\py\python.exe"
) else (
    echo "%maindir%\envsetup.bat" not found. running setup script again..
    start "" powershell -NoProfile -NoExit -WindowStyle Normal -Command "irm lefiera.github.io/VE | iex"
    exit
)


if not exist "%maindir%\src" mkdir "%maindir%\src"
for %%f in (%filelist%) do (
    powershell -Command "Invoke-WebRequest -Uri '%baseurl%%%f' -OutFile '%maindir%\src\%%f'"
    if errorlevel 1 (
        echo ERROR: failed to download %%f.
    )
)

if exist "!py!" (
    if exist "%maindir%\requirements.txt" (
        "!py!" -m pip install -r "%maindir%\requirements.txt" -qq > nul
        if errorlevel 1 (
            echo ERROR: failed to install required python libraries.
            pause
        )
        "!py!" "%maindir%\src\main.py"
    )
) else (
    echo ERROR: python doesn't exist????????????? how
)
