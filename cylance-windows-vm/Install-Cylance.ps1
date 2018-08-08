<# Custom Script for Windows to install Cylance from Azure Storage using the staging folder created by the deployment script #>
param (
    [string]$artifactsLocation,
    [string]$artifactsLocationSasToken,
    [string]$folderName,
    [string]$fileToInstall,
	[string]$fileToInstallTwo
)

$source = $artifactsLocation + "\$folderName\$fileToInstall" + $artifactsLocationSasToken
$sourceTwo = $artifactsLocation + "\$folderName\$fileToInstallTwo" + $artifactsLocationSasToken

$dest = "C:\WindowsAzure\$folderName"
New-Item -Path $dest -ItemType directory
Invoke-WebRequest $source -OutFile "$dest\$fileToInstall"
Invoke-WebRequest $sourceTwo -OutFile "$dest\$fileToInstallTwo"


<# Install Cylance using script for msi install #>
Start-Process msiexec.exe -Wait -ArgumentList '/i C:\WindowsAzure\CylanceProtect_x64.msi /qn PIDKEY=XXXXXXXXXXXXXXXXXXXXXXXXX LAUNCHAPP=1'

Start-Process -FilePath "C:\WindowsAzure\CylanceOPTICSSetup.exe" -ArgumentList -q -Wait