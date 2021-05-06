<# Custom Script for Windows to install a file from Azure Storage using the staging folder created by the deployment script #>
param (
    [string]$artifactsLocation,
    [string]$fileToInstall,
    [string]$folderName
)

$source = $artifactsLocation
$dest = "C:\WindowsAzure\$folderName"
Invoke-WebRequest $source -OutFile "$dest\$fileToInstall"