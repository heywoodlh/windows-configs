## Better PSReadline defaults
Set-PSReadlineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode vi -ViModeIndicator cursor
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

## Add ~/bin to $PATH
$env:PATH = "${HOME}\bin;" + $env:PATH

## Add $startupPath variable
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

## Add vim to $PATH
$vim_dir = Get-ChildItem -Path "C:\Program Files\Vim\" -Attribute 'Directory' -ErrorAction silentlycontinue | Select-Object -ExpandProperty FullName | Select -Last 1
if (${vim_dir}) {
  $env:PATH = "${vim_dir};" + $env:PATH
}

## Add helix to $PATH
$env:PATH = "$env:HOME\AppData\Local\Microsoft\WinGet\Packages\Helix.Helix_Microsoft.Winget.Source_8wekyb3d8bbwe\helix-24.07-x86_64-windows;" + $env:PATH

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:PATH

## Add gnuwin32 executables to $PATH
$env:PATH = "C:\Program Files (x86)\GnuWin32\bin;" + $env:PATH

## Windows functions
function battpop() {
  notify-send "$((Get-WmiObject win32_battery).EstimatedChargeRemaining)"
}

function notify-send() {
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

  $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon

  $objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
  $objNotifyIcon.BalloonTipIcon = "Info"
  $objNotifyIcon.BalloonTipText = "$args"
  $objNotifyIcon.BalloonTipTitle = "notify-send"
  $objNotifyIcon.Visible = $True

  $objNotifyIcon.ShowBalloonTip(10000)
}

function which() {
  (get-command $args -erroraction silentlycontinue).source
}

## Unix-like `ls`
Remove-Alias -Name ls -ErrorAction silentlycontinue
function ls { get-childitem -path $args[0] | format-wide -property name }

## Starship Prompt
Invoke-Expression (&starship init powershell)

# Sign into 1Password CLI to allow the
$env:PATH += ";$env:LOCALAPPDATA\Microsoft\WinGet\Links"
function op-unlock() {
  Invoke-Expression $(op signin)
}

function ssh-unlock() {
  op-unlock
  new-item -itemtype Directory -path $env:HOME\.ssh -erroraction silentlycontinue
  op read 'op://Personal/rlt3q545cf5a4r4arhnb4h5qmi/private_key' > $env:HOME\.ssh\id_rsa
  Cmd /c Icacls  %UserProfile%\.ssh /c /t /Inheritance:d | out-null
  Cmd /c Icacls  %UserProfile%\.ssh /c /t /Grant %UserName%:F | out-null
  Cmd /c Icacls  %UserProfile%\.ssh /c /t /Remove Administrator "Authenticated Users" BUILTIN\Administrators BUILTIN Everyone System Users
  ssh-add $env:HOME\.ssh\id_rsa
  remove-item -ErrorAction silentlycontinue $env:HOME\.ssh\id_rsa
}

function vim() {
  nvim.exe $args
}
