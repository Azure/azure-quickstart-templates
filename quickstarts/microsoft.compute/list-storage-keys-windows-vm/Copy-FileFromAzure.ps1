param (
    [string]$artifactsLocation,
    [string]$artifactsLocationSasToken,
    [string]$folderName,
    [string]$fileToInstall
)

$source = "{0}{1}\{2}\{3}" -f $artifactsLocation,$folderName,$fileToInstall,$artifactsLocationSasToken
$dest = "C:\WindowsAzure\scripts"
New-Item -Path $dest -ItemType "directory" -Force
Invoke-WebRequest $source -OutFile "$dest\$fileToInstall"
