# create shortcuts in startup for komorebi and nircmd
# path to windows startup folder
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# scriptblock for creating a shortcut
    $createLink = {
        param($name,$sourceExe,$argumentsExe,$destination)
        $WshShell = New-Object -comObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut("$destination\$name.lnk")
        $shortcut.TargetPath = $sourceExe
        $shortcut.Arguments = $argumentsExe
        $shortcut.Save()
    }

# init $list as arraylist
    $list = [System.Collections.ArrayList]::new()

# add nircmd to list
    [void]$list.Add(@{
        name = 'nircmd'
        sourceExe = (Get-Command nircmd).Path
        argumentsExe = 'win trans class Shell_TrayWnd 255'
        destination = $startupPath
    })

# add komorebi to list
    [void]$list.Add(@{
        name = 'komorebi'
        sourceExe = "powershell.exe"
        argumentsExe = '-WindowStyle hidden -Command komorebic start --await-configuration'
        destination = $startupPath
    })

# create shortcut for every item in $list
    foreach ($item in $list) {
        if (!(Test-Path -Path "$startupPath\$($item.name).lnk")) {
            & $createLink @item
        } else {
            $null = Remove-Item -Path "$startupPath\$($item.name).lnk"
            & $createLink @item
        }
    }
