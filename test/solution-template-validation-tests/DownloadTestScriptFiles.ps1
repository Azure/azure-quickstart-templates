[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)][string]$githubTestFilesFolderUri,
    [Parameter(Mandatory=$false)][string]$githubBuildFilesFolderUri
)

if(!$githubTestFilesFolderUri) {
    # default to azure quickstart template uri
    Write-Host "Defaulting to azure quick start uri"
    $githubTestFilesFolderUri = "https://api.github.com/repos/Azure/azure-quickstart-templates/contents/test/solution-template-validation-tests/test"
}

if(!$githubBuildFilesFolderUri) {
    # default to azure quickstart template uri
    Write-Host "Defaulting to azure quick start uri"
    $githubBuildFilesFolderUri = "https://api.github.com/repos/Azure/azure-quickstart-templates/contents/test/solution-template-validation-tests/buildfiles"
}

Write-Host "Getting contents from $githubTestFilesFolderUri"
$folderContents = Invoke-WebRequest $githubTestFilesFolderUri -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json

Write-Host "Creating test directory if one doesn't exist already"
$path = (Get-Item -Path ".\" -Verbose).FullName + "\test"
If(!(test-path $path))
{
    Write-Host "Creating test directory"
    New-Item -ItemType Directory -Force -Path $path
}

cd $path
foreach($file in $folderContents) 
{
    Write-Host "Downloading file $file.name"
    Invoke-WebRequest $file.download_url -UseBasicParsing -OutFile $file.name
}

Write-Host "Listing files downloaded"
dir

# go back to current directory
cd ..

Write-Host "Getting contents from $githubBuildFilesFolderUri"
$folderContents = Invoke-WebRequest $githubBuildFilesFolderUri -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json

foreach($file in $folderContents) 
{
    Write-Host "Downloading file $file.name"
    Invoke-WebRequest $file.download_url -UseBasicParsing -OutFile $file.name
}

$packageJsonFile = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/test/solution-template-validation-tests/package.json"
Write-Host "Downloading package.json file from $packageJsonFile"
Invoke-WebRequest $packageJsonFile -UseBasicParsing -OutFile "package.json"

$npmrcFile = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/test/solution-template-validation-tests/.npmrc"
Write-Host "Downloading .npmrc file from $npmrcFile"
Invoke-WebRequest $npmrcFile -UseBasicParsing -OutFile ".npmrc"

Write-Host "Listing files downloaded"
dir