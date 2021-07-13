param (
    [string]$artifactsLocation,
    [string]$artifactsLocationSasToken,
    [string]$folderName,
    [string]$fileToInstall
)

$source = $artifactsLocation + "\$folderName\$fileToInstall" + $artifactsLocationSasToken
$dest = "C:\WindowsAzure\"
New-Item -Path $dest -Name $folderName -ItemType "directory"
Invoke-WebRequest $source -OutFile "$dest\$fileToInstall"
