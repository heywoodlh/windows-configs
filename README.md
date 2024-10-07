## Windows Configs

Automated Windows deployment using PowerShell Core.

Tested on Windows 11 Pro.

![screenshot](./screenshot.png)

## Features:

- Nord-themed [Windows Terminal](https://github.com/microsoft/terminal)
- Fully configured Vim with plugins managed via [vim-plug](https://github.com/junegunn/vim-plug)

## Dependencies:

[Winget](https://github.com/microsoft/winget-cli):

[PowerShell Core](https://github.com/PowerShell/PowerShell):

```
winget install --id Microsoft.PowerShell
```

[Git](https://git-scm.com/):

```
winget install --id Git.Git
```

## Usage:

Executed from a PowerShell Core shell session:

```
git clone https://github.com/heywoodlh/windows-configs
cd windows-configs
. .\config.ps1
```

### Vim Plugins:

Launch `vim.exe` and the run the following command within Vim:

```
:PlugInstall
```

## WSL setup:

Run the following in WSL to configure it:

```
curl https://files.heywoodlh.io/scripts/linux.sh | bash -s -- workstation --ansible --home-manager
```
