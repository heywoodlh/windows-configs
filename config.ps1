# Create ~/.config directory
New-Item -Type Directory ~/.config -ErrorAction silentlycontinue

# Create ~/bin directory
New-Item -Type Directory ~/bin -ErrorAction silentlycontinue

# Set startup folder
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

function filter_winget() {
  $input | select-string -NotMatch -Pattern 'No available upgrade found|No newer package versions are available from the configured sources|Package is already installed|Found an existing package already|^   -|^   \|^   /'
}

# Install winget packages
# No available upgrade found.
# No newer package versions are available from the configured sources.
# Package is already installed
Write-Output "Installing packages"
winget import --ignore-warnings -i ./packages/packages.json | filter_winget

# Configure Starship
Copy-Item dotfiles/starship.toml ~/.config/starship.toml

# Configure SSH
New-Item -ErrorAction silentlycontinue -Type Directory ~/.ssh
Copy-Item dotfiles/ssh/config ~/.ssh/config

# Configure PowerShell
New-Item -ErrorAction silentlycontinue -Type Directory $(Split-Path $PROFILE)
Copy-Item dotfiles/profile.ps1 $PROFILE
New-Item -ErrorAction silentlycontinue -Type Directory ~/.config/powershell
#Copy-Item dotfiles/powershell/docker.ps1 ~/.config/powershell/docker.ps1
. $PROFILE

# Configure Vim for Windows
Copy-Item dotfiles/vimrc ~/_vimrc
New-Item -ErrorAction silentlycontinue -Type Directory ~/temp
New-Item -ErrorAction silentlycontinue -Type Directory ~/AppData/Local/nvim/
Copy-Item dotfiles/init.vim ~/AppData/Local/nvim/init.vim
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force

# Configure Helix
New-Item -ErrorAction silentlycontinue -Type Directory $env:APPDATA\helix\
Copy-Item dotfiles/helix/config.toml $env:APPDATA/helix/config.toml

# Configure git
Copy-Item dotfiles/gitconfig ~/.gitconfig

# Configure Windows Terminal
New-Item -Type Directory ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/ -ErrorAction silentlycontinue
Copy-Item dotfiles/windows-terminal.json ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
#Copy-Item resources/wt-startup.bat $startupPath/wt-startup.bat
#Get-Process -Name "WindowsTerminal" 2| out-null || Start-Process wt.exe -ArgumentList '-w _quake' -WindowStyle hidden

# Disable desktop icons
$reg_path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $reg_path -Name "HideIcons" -Value 1
Get-Process "explorer" | Stop-Process | out-null

# Set dark theme
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force

# Hide the search bar
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force

# Disable web search taskbar
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name "BingSearchEnabled" -Value 0 -Type DWord

# Remove all pinned items
Copy-Item -Force resources/start2.bin $env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin

if ($args[0] -eq "dev") {
  # Add hide-mouse-cursor.exe to startup folder
  # Start it if not already running
  Copy-Item ./resources/hide-mouse-cursor.exe $startupPath -ErrorAction silentlycontinue
  Get-Process -Name "hide-mouse-cursor" | out-null || & "$startupPath/hide-mouse-cursor.exe" | out-null

  # Install WSL (Ubuntu)
  wsl.exe --list | select-string Ubuntu || wsl.exe --install

  # Download NixOS-WSL from latest release
  #curl.exe --silent -L -C - https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz -o $env:HOME\Documents\nixos-wsl.tar.gz
  #if (C:\Windows\system32\wsl.exe --list | select-string nixos)
  #{
  #  write-output "wsl already set up with nixos"
  #} else {
  #  write-output "installing nixos-wsl"
  #  C:\Windows\system32\wsl.exe --update
  #  new-item -itemtype directory $env:HOME\Documents\wsl\nixos
  #  C:\Windows\system32\wsl.exe --import nixos $env:HOME\Documents\wsl\nixos\ $env:HOME\Documents\nixos-wsl.tar.gz
  #  C:\Windows\system32\wsl.exe --set-version nixos 2
  #  C:\Windows\system32\wsl.exe --set-default nixos
  #  C:\Windows\system32\wsl.exe -d nixos
  #}

  winget install Microsoft.PowerToys | filter_winget
}

function ssh_server_setup() {
  Write-Output "Configuring SSH"
  # SSH configuration
  Add-WindowsCapability -Online -Name "OpenSSH.Server" | out-null
  Get-Service -Name sshd | Set-Service -StartupType Automatic | out-null
  Get-Service ssh-agent | Set-Service -StartupType Automatic | out-null
  # Set PowerShell Core as the default shell over SSH
  New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force | out-null
  icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F" | out-null
  New-Item -ErrorAction Ignore -ItemType Directory -Path $env:ProgramData\ssh | out-null
  Invoke-WebRequest https://github.com/heywoodlh.keys -OutFile $env:ProgramData\ssh\administrators_authorized_keys
}

if ($args[0] -eq "gaming") {
  ssh_server_setup

  # Set active hours from 8:00 a.m. to 2:00 a.m.
  Write-Output "Setting active hours"
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursStart" -Value 8
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursEnd" -Value 2

  # Configure windows-terminal for gaming machine
  Copy-Item dotfiles/windows-terminal-gaming.json ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json

  winget install LizardByte.Sunshine Valve.Steam RustDesk.RustDesk | filter_winget
}
