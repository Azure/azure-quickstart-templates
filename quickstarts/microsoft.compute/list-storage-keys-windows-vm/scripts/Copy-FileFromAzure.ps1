param (
    [string]$artifactsLocation,
    [string]$artifactsLocationSasToken,
    [string]$folderName,
    [string]$fileToInstall
)

$source = $artifactsLocation + "\$folderName\$fileToInstall" + $artifactsLocationSasToken
$dest = "C:\WindowsAzure\$folderName"
New-Item -Path $dest -ItemType Directory
Invoke-WebRequest $source -OutFile "$dest\$fileToInstall"
