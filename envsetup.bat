@echo off
setlocal enabledelayedexpansion
:: hello to the person reading this file. the embedded aka cab webview files being used were downloaded from these links:
:: https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d06215b5-f2eb-48b4-96cc-a39989cd07cd/Microsoft.WebView2.FixedVersionRuntime.147.0.3912.86.x86.cab
:: https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/df975e04-d266-4b64-8d9d-6e7a87b472d8/Microsoft.WebView2.FixedVersionRuntime.147.0.3912.86.x64.cab
:: https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/b7548b20-4df0-4329-b3b4-8896fd86552f/Microsoft.WebView2.FixedVersionRuntime.147.0.3912.86.arm64.cab
:: the version of the webview im using is: 147.0.3912.86
:: the page i downloaded the webview cab files from is:
:: https://developer.microsoft.com/en-us/microsoft-edge/webview2/
:: if you are suspicious (good of you) of ANY piece of code or binary being used in this project, i HIGHLY recommend you to take your time to go through it yourself because i tried to make everything as transparent as possible.
:: if you are wondering why i am hosting the embedded webview files on github, its because microsoft doesnt provide a simple/clean way to pull the embedded versions of webview from links like i can with python. and i cant find any other good/safe ways to upload the files somewhere and have permanent download links to faithfully use in this project.
:: for the rest of the files im pulling and running/using (embedded python, get_pip.py), i hope you can put 2 and 2 together and use your brain to figure out the legitimacy of them yourself.
set "maindir=C:\ProgramData\VoltEnhanced"
set "webviewurl=https://github.com/lefiera/VE/releases/download/webviews/"
set "pyver=3.11.0"

if defined PROCESSOR_ARCHITEW6432 (
    set "arch=!PROCESSOR_ARCHITEW6432!"
) else (
    set "arch=!PROCESSOR_ARCHITECTURE!"
)
if /i "!arch!"=="AMD64" set "arch=amd64"
if /i "!arch!"=="x86"   set "arch=win32"
if /i "!arch!"=="ARM64" set "arch=arm64"

set "installedver="
if exist "%maindir%\py\python.exe" (
    for /f "tokens=2" %%v in ('"%maindir%\py\python.exe" --version 2^>^&1') do set "installedver=%%v"
    if "!installedver!" neq "%pyver%" (
        rmdir /s /q "%maindir%\py"
        echo incorrect python version installed.
        call :pyinstall
    )
) else (
    if exist "%maindir%\py" (
        rmdir /s /q "%maindir%\py"
    )
    echo python not installed.
    call :pyinstall
)

if not exist "%maindir%\webview\msedgewebview2.exe" (
    echo embedded webview2 not installed, downloading and installing webview2 version: 147.0.3912.86
    if not exist "%maindir%\webview2.!arch!.cab" (
        powershell -NoProfile -Command "Invoke-WebRequest -Uri '%webviewurl%webview2.!arch!.cab' -OutFile '%maindir%\webview2.!arch!.cab'"
        if errorlevel 1 (
            echo webview2 download failed. cannot continue setup for embedded webview2.
            goto :eof
        )
    )
    expand -F:* "%maindir%\webview2.!arch!.cab" "%maindir%" >nul
    if exist "%maindir%\webview" rmdir /s /q "%maindir%\webview"
    for /d %%i in ("%maindir%\Microsoft*") do ren "%%i" "webview"
)

if exist "%maindir%\py\python.exe" (
    :: for setting up pip cuz pip is pip so pip pipiipipipipipiip
    "%maindir%\py\python.exe" -m pip --version >nul
    if !errorlevel! neq 0 (
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%maindir%\get-pip.py'"
        "%maindir%\py\python.exe" "%maindir%\get-pip.py" -qq > nul
        del "%maindir%\get-pip.py"
        for %%f in ("%maindir%\py\*._pth") do (
            powershell -NoProfile -Command "(Get-Content '%%f') -replace '^#import site$','import site' | Set-Content '%%f'"
        )
    )
    exit /b 0
) else (
    exit /b 1
)

::funcs
:pyinstall
echo installing embedded python version: !pyver!
powershell -NoProfile -Command "$url='https://www.python.org/ftp/python/%pyver%/python-%pyver%-embed-%arch%.zip'; $zip=Join-Path $env:TEMP 'python_embed.zip'; Invoke-WebRequest -Uri $url -OutFile $zip; Expand-Archive -Path $zip -DestinationPath '%maindir%\py' -Force; Remove-Item $zip"
goto :eof