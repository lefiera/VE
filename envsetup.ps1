$ErrorActionPreference = "Stop"

# hello to the person reading this file. the embedded aka cab webview files being used were downloaded from these links:
# https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d06215b5-f2eb-48b4-96cc-a39989cd07cd/Microsoft.WebView2.FixedVersionRuntime.147.0.3912.86.x86.cab
# https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/df975e04-d266-4b64-8d9d-6e7a87b472d8/Microsoft.WebView2.FixedVersionRuntime.147.0.3912.86.x64.cab
# https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/b7548b20-4df0-4329-b3b4-8896fd86552f/Microsoft.WebView2.FixedVersionRuntime.147.0.3912.86.arm64.cab
# the version of the webview im using is: 147.0.3912.86
# the page i downloaded the webview cab files from is:
# https://developer.microsoft.com/en-us/microsoft-edge/webview2/
# if you are suspicious (good of you) of ANY piece of code or binary being used in this project, i HIGHLY recommend you to take your time to go through it yourself because i tried to make everything as transparent as possible.
# if you are wondering why i am hosting the embedded webview files on github, its because microsoft doesnt provide a simple/clean way to pull the embedded versions of webview from links like i can with python. and i cant find any other good/safe ways to upload the files somewhere and have permanent download links to faithfully use in this project.
# for the rest of the files im pulling and running/using (embedded python, get_pip.py), i hope you can put 2 and 2 together and use your brain to figure out the legitimacy of them yourself.

try {
    $maindir = "C:\ProgramData\VoltPlus"
    $webviewurl = "https://github.com/lefiera/VP/releases/download/webviews/"
    $pyver = "3.11.0"

    $arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    switch ($arch.ToUpper()) {
        "AMD64" { $arch = "amd64" }
        "X86"   { $arch = "win32" }
        "ARM64" { $arch = "arm64" }
        default { throw "unsupported architecture: $arch" }
    }

    if (-not (Test-Path "$maindir\files")) { New-Item -ItemType Directory -Path "$maindir\files" -Force | Out-Null }

    function pyinstall {
        Write-Host "downloading and installing embedded python version: $pyver"
        $url = "https://www.python.org/ftp/python/$pyver/python-$pyver-embed-$arch.zip"
        $zip = "$maindir\files\python_embedded.zip"
        if (-not (Test-Path $zip)) {
            Invoke-WebRequest -Uri $url -OutFile $zip
        }
        Expand-Archive -Path $zip -DestinationPath "$maindir\py" -Force
    }

    $installedver = $null
    if (Test-Path "$maindir\py\python.exe") {
        $versionout = & $maindir\py\python.exe --version 2>&1
        $installedver = ($versionout -split ' ')[1]
        if ($installedver -ne $pyver) {
            if (Test-Path "$maindir\py") { Remove-Item -Recurse -Force "$maindir\py" }
            Write-Host "incorrect python version installed."
            pyinstall
        }
    } else {
        if (Test-Path "$maindir\py") { Remove-Item -Recurse -Force "$maindir\py" }
        Write-Host "python not installed."
        pyinstall
    }

    $webviewExe = "$maindir\webview\msedgewebview2.exe"
    if (-not (Test-Path $webviewExe)) {
        Write-Host "embedded webview2 not installed, downloading and installing webview2 version: 147.0.3912.86"
        $cabfile = "$maindir\files\webview2.$arch.cab"
        if (-not (Test-Path $cabfile)) {
            Invoke-WebRequest -Uri "$webviewurl`webview2.$arch.cab" -OutFile $cabfile
        }
        & expand.exe -F:* "$cabfile" "$maindir" > $null
        if (Test-Path "$maindir\webview") { Remove-Item -Recurse -Force "$maindir\webview" }
        $extracteddir = Get-ChildItem -Directory -Path "$maindir" -Filter "Microsoft*" | Select-Object -First 1
        if ($extracteddir) { Rename-Item -Path $extracteddir.FullName -NewName "webview" }
    }

    if (Test-Path $maindir\py\python.exe) {
        $ErrorActionPreference = "Continue"
        & $maindir\py\python.exe -m pip --version >$null 2>$null
        $ErrorActionPreference = "Stop"
        if ($LASTEXITCODE -ne 0) {
            Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile "$maindir\get-pip.py"
            & $maindir\py\python.exe "$maindir\get-pip.py" -qq
            Remove-Item "$maindir\get-pip.py"
            Get-ChildItem -Path "$maindir\py\*._pth" | ForEach-Object {
                (Get-Content $_.FullName) -replace '^#import site$', 'import site' | Set-Content $_.FullName
            }
        }
        exit 0
    } else {
        exit 1
    }
}
catch {
    $err = $_
    Write-Host "`nplease show this message to tainted(zlsb) on discord" -ForegroundColor Red
    Write-Host "ERROR: $($err.Exception.Message)" -ForegroundColor Red
    if ($err.InvocationInfo) {
        $invocation = $err.InvocationInfo
        Write-Host "errored at line number: $($invocation.ScriptLineNumber)" -ForegroundColor Yellow
        if ($PSCommandPath) {
            Write-Host "running script path: $PSCommandPath" -ForegroundColor Red
        }
        else {
            Write-Host "running script isn't on disk."
        }
        Write-Host "errored line of code:" -ForegroundColor Yellow
        Write-Host "$($invocation.Line.Trim())" -ForegroundColor Red
        try {
            $expanded = $ExecutionContext.InvokeCommand.ExpandString($invocation.Line).Trim()
            if ($expanded) {
                Write-Host "errored line of code at runtime:" -ForegroundColor Yellow
                Write-Host "$expanded" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "could not expand variables in this scope."
        }
    }
    Read-Host "`npress enter to close"
    exit 1
}