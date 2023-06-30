## Disable beep
Set-PSReadlineOption -BellStyle None

## Add ~/bin to $PATH
$env:PATH = "${HOME}\bin;" + $env:PATH

## Add vim to $PATH
$vim_dir = Get-ChildItem -Path "C:\Program Files\Vim\" -Attribute 'Directory' -ErrorAction silentlycontinue | Select-Object -ExpandProperty FullName | Select -Last 1
if (${vim_dir}) {
  $env:PATH = "${vim_dir};" + $env:PATH
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:PATH

## Add gnuwin32 executables to $PATH
$env:PATH = "C:\Program Files (x86)\GnuWin32\bin;" + $env:PATH

## Add whkd to $PATH
$env:PATH = "C:\Program Files\whkd\bin;" + $env:PATH

## Add rancher tools to $PATH
$env:PATH = "$HOME\AppData\Local\Programs\Rancher Desktop\resources\resources\win32\bin;" + $env:PATH

## Windows functions
function restart-komorebi() {
  get-process -name whkd | stop-process
  get-process -name komorebi | stop-process
  start-process komorebi.exe -ArgumentList '--await-configuration' -WindowStyle hidden
}

function which() {
  (get-command $args -erroraction silentlycontinue).source
}

## Docker functions
. ~/.config/powershell/docker.ps1

## Starship Prompt
Invoke-Expression (&starship init powershell)
