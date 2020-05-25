#Script based on https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/visual-studio-dev-vm-chocolatey/scripts/SetupChocolatey.ps1
param(
    [Parameter(Mandatory=$true)][string]$artifactsLocation,
    [Parameter(Mandatory=$true)][string]$artifactsLocationSasToken,
    [Parameter(Mandatory=$true)][string]$folderName,
    [Parameter(Mandatory=$true)][string]$fileToInstall,
    [Parameter(Mandatory=$true)][string]$chocoPackages)

Write-Host "File packages URL: $linktopackages"

#Changing ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

#Change securoty protocol
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Install Choco
$sb = { iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) }
Invoke-Command -ScriptBlock $sb 

$sb = { Set-ItemProperty -path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -name EnableLua -value 0 }
Invoke-Command -ScriptBlock $sb 

#Install Chocolatey Packages
$chocoPackages.Split(";") | ForEach {
    choco install $_ -y -force
}

Write-Host "Packages from choco.org were installes"
#Isntall OBS-NDI package from sources

$source = $artifactsLocation + "\$folderName\$fileToInstall" + $artifactsLocationSasToken
$dest = "C:\WindowsAzure\$folderName"
New-Item -Path $dest -ItemType directory
Invoke-WebRequest $source -OutFile "$dest\$fileToInstall"

Expand-Archive -Path "$dest\$fileToInstall" -DestinationPath ./

choco pack
choco install -y .\obs-ndi.4.9.0.nupkg
