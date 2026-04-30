$ErrorActionPreference = "Stop"

try {
    $maindir = "C:\ProgramData\VoltPlus"
    $baseurl = "https://raw.githubusercontent.com/lefiera/VP/refs/heads/main/src/"
    $filelist = "main.py"

    Write-Host "welcome to VoltPlus! a custom UI made for Volt"

    if ($PSCommandPath) {
        $shortcutMain = "$maindir\VoltPlus.lnk"
        if (-not (Test-Path $shortcutMain)) {
            $WshShell = New-Object -ComObject WScript.Shell
            $sc = $WshShell.CreateShortcut($shortcutMain)
            $sc.TargetPath = "powershell.exe"
            $sc.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
            $iconPath = "$maindir\voltplus.png"
            if (Test-Path $iconPath) {
                $sc.IconLocation = $iconPath
            }
            $sc.Save()
        }

        $shortcutDesktop = "$env:USERPROFILE\Desktop\VoltPlus.lnk"
        if (-not (Test-Path $shortcutDesktop)) {
            $WshShell = New-Object -ComObject WScript.Shell
            $sc = $WshShell.CreateShortcut($shortcutDesktop)
            $sc.TargetPath = "powershell.exe"
            $sc.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
            $iconPath = "$maindir\voltplus.png"
            if (Test-Path $iconPath) {
                $sc.IconLocation = $iconPath
            }
            $sc.Save()
        }
    }

    $envsetup = "$maindir\envsetup.ps1"
    if (Test-Path $envsetup) {
        Write-Host "checking if VoltPlus environment is setup properly or not.."
        & $envsetup
        $py = "$maindir\py\python.exe"
    } else {
        Write-Host "$envsetup not found. running setup script again.."
        Start-Process powershell -ArgumentList "-NoProfile -NoExit -WindowStyle Normal -Command `"irm lefiera.github.io/VE | iex`""
        exit
    }

    if (-not (Test-Path "$maindir\src")) {
    New-Item -ItemType Directory -Path "$maindir\src" -Force | Out-Null
    }
    $files = $filelist -split '\s+'   # $filelist is a space‑separated string like "main.py"
    foreach ($f in $files) {
        if ($f) {
            try {
                Invoke-WebRequest -Uri "$baseurl$f" -OutFile "$maindir\src\$f" -ErrorAction Stop
            } catch {
                Write-Host "ERROR: failed to download $f."
            }
        }
    }
    
    if (Test-Path $py) {
        $reqfile = "$maindir\requirements.txt"
        if (Test-Path $reqfile) {
            & $py -m pip install -r $reqfile -qq
        }
        Write-Host "starting VoltPlus.."
        & $py "$maindir\src\main.py"
    } else {
        Write-Host "ERROR: python doesn't exist????????????? how" -ForegroundColor Red
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