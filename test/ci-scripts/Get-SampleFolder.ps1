<#
This script will find the sample folder for the PR - Test are run on that folder only
If the PR contains more than one sample the build must fail
If the PR does not contain changes to a sample folder, it will currently fail but we'll TODO this to
pass the build in order to trigger a manual review
#>

param(
    [string] $ResourceGroupNamePrefix = "azdo",
    [string] $PrereqResourceGroupNameSuffix = "" # leave this to deploy prereqs to the same RG as the rest of the resources
)

# Get-ChildItem env: # debugging

$GitHubRepository = $ENV:BUILD_REPOSITORY_NAME
$GitHubPRNumber = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER
$RepoRoot = $ENV:BUILD_REPOSITORY_LOCALPATH
$PRUri = "https://api.github.com/repos/$($GitHubRepository)/pulls/$($GitHubPRNumber)/files"

# Get all of the files changed in the PR
$ChangedFile = Invoke-Restmethod "$PRUri"

# Now check to make sure there is exactly one sample in this PR per repo guidelines
$FolderArray = @()
$ChangedFile | ForEach-Object {
    Write-Output $_.blob_url
    $CurrentPath = Split-Path (Join-Path -path $RepoRoot -ChildPath $_.filename)
 
    # File in root of repo - TODO: should we block this?
    If ($CurrentPath -eq $RepoRoot) {
        Write-Error "### Error ### The file $($_.filename) is in the root of the repository. A PR can only contain changes to files from a sample folder at this time."
    }
    Else {
        # find metadata.json
        while (!(Test-Path (Join-Path -path $CurrentPath -ChildPath "metadata.json")) -and $CurrentPath -ne $RepoRoot) {
            $CurrentPath = Split-Path $CurrentPath # if it's not in the same folder as this file, search it's parent
        }
        # if we made it to the root searching for metadata.json write the error
        If ($CurrentPath -eq $RepoRoot) {
            Write-Error "### Error ### The scenario folder for $($_.filename) does not include a metadata.json file. Please add a metadata.json file to your scenario folder as part of the pull request."
        }
        Else {
            $FolderArray += $currentpath
        }
    }
}

# Get the unique paths we found metadata.json in - there should be no more then one
$FolderArray = @($FolderArray | Select-Object -Unique)
 
If ($FolderArray.count -gt 1) {
    Write-Error "### Error ### The Pull request contains file changes from $($FolderArray.count) scenario folders. A pull request can only contain changes to files from a single scenario folder."
}

# Update pipeline variable with the sample folder
$FolderString = $FolderArray[0]
Write-Output "Using sample folder: $FolderString"
Write-Host "##vso[task.setvariable variable=sample.folder]$FolderString"

# Generate a resourceGroup Name
$resourceGroupName = "$ResourceGroupNamePrefix-$(New-Guid)"
Write-Host "##vso[task.setvariable variable=resourceGroup.name]$resourceGroupName"
Write-Host "##vso[task.setvariable variable=prereq.resourceGroup.name]$resourceGroupName-$PrereqResourceGroupNameSuffix"
