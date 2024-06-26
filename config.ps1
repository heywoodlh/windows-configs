# Create ~/.config directory
New-Item -Type Directory ~/.config -ErrorAction silentlycontinue

# Create ~/bin directory
New-Item -Type Directory ~/bin -ErrorAction silentlycontinue

# Set startup folder
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"


# Install winget packages
winget import -i packages/packages.json



# Configure Starship
Copy-Item dotfiles/starship.toml ~/.config/starship.toml


# Configure SSH
New-Item -ErrorAction silentlycontinue -Type Directory ~/.ssh
Copy-Item dotfiles/ssh/config ~/.ssh/config



# Configure PowerShell
New-Item -ErrorAction silentlycontinue -Type Directory $(Split-Path $PROFILE)
Copy-Item dotfiles/profile.ps1 $PROFILE
New-Item -ErrorAction silentlycontinue -Type Directory ~/.config/powershell
Copy-Item dotfiles/powershell/docker.ps1 ~/.config/powershell/docker.ps1
. $PROFILE



# Disable ctrl+super+s key (requires reboot)
# Doesn't seem to work, remap ctrl+super+s
# Use PowerToys Keyboard, use another bind
#Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name DisabledHotkeys -Value "SA" -Force



# Configure Vim for Windows
Copy-Item dotfiles/vimrc ~/_vimrc
New-Item -ErrorAction silentlycontinue -Type Directory ~/temp
Invoke-WebRequest -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force > $null



# Configure git
Copy-Item dotfiles/gitconfig ~/.gitconfig



# Configure Windows Terminal
New-Item -Type Directory ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/ -ErrorAction silentlycontinue
Copy-Item dotfiles/windows-terminal.json ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
#Copy-Item resources/wt-startup.bat $startupPath/wt-startup.bat
#Get-Process -Name "WindowsTerminal" 2> $null || Start-Process wt.exe -ArgumentList '-w _quake' -WindowStyle hidden



# Configure Komorebi
#Copy-Item dotfiles/komorebi-generated.ps1 ~/komorebi-generated.ps1
#Copy-Item dotfiles/komorebi.ps1 ~/komorebi.ps1
#Copy-Item dotfiles/whkdrc ~/.config/whkdrc
# Start Komorebi on login
#. ./scripts/komorebi-startup.ps1
# Start Komorebi
#Get-Process -Name "komorebi" 2> $null || Start-Process komorebi.exe -ArgumentList '--await-configuration' -WindowStyle hidden



# Disable desktop icons
$reg_path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $reg_path -Name "HideIcons" -Value 1
Get-Process "explorer" | Stop-Process



# Set dark theme
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force



# Hide the search bar
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force



# Disable web search taskbar
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name "BingSearchEnabled" -Value 0 -Type DWord



# Add hide-mouse-cursor.exe to startup folder
# Start it if not already running
Copy-Item ./resources/hide-mouse-cursor.exe $startupPath -ErrorAction silentlycontinue
Get-Process -Name "hide-mouse-cursor" 2> $null || & "$startupPath/hide-mouse-cursor.exe"



# Remove all pinned items
Copy-Item -Force resources/start2.bin $env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin



# Download NixOS-WSL from latest release
curl.exe --silent -L -C - https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz -o $HOME\Documents\nixos-wsl.tar.gz
if (C:\Windows\system32\wsl.exe --list | select-string nixos)
{
  write-output "wsl already set up with nixos"
} else {
  write-output "installing nixos-wsl"
  C:\Windows\system32\wsl.exe --update
  new-item -itemtype directory $HOME\Documents\wsl
  C:\Windows\system32\wsl.exe --import nixos $env:USERPROFILE\Documents\wsl\nixos\ $HOME\Documents\wsl\nixos-wsl.tar.gz
  C:\Windows\system32\wsl.exe --set-version nixos 2
  C:\Windows\system32\wsl.exe --set-default nixos
  C:\Windows\system32\wsl.exe -d nixos
}
