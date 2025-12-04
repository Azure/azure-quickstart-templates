Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart 
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart

## Install Chocolatey using PowerShell script
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

## Install docker-desktop for Windows
choco install docker-desktop -y

## Install Git and VS Code
choco install git vscode -y

# Install VS2019 Community with ALL packages and recommendations
choco install -y visualstudio2019community --package-parameters "--allWorkloads --includeRecommended --passive --locale en-IN"
