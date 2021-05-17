## Install Chocolatey using Powershell script
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

## Install VSCode & GIT for OSS Development
choco install vscode git sql-server-management-studio -y

## Install Visual Studio 2019 Community edition
choco install -y visualstudio2019community --package-parameters "--allWorkloads --includeRecommended --passive --locale en-IN"

## Install AzureCLI
choco install -y azure-cli

## Install Azure Powershell Module Az
install-module Az -AllowClobber -Scope AllUsers -Force -Confirm
