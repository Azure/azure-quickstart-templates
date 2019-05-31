<# 
This script gets the folders that have changed in the PR - only one sample is allowed per PR.  
Currently it expects the folder to be in the root - but once the repo is re-orged, this will need to change
#>

#region variables

# These ENV vars are set in AzDO
$GitHubRepository = $ENV:BUILD_REPOSITORY_NAME
$GitHubPRNumber = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER

# for local testing
$GitHubRepository = "Azure/azure-quickstart-templates"
$GitHubPRNumber = "5976"

#endregion

# Get Changed Files
$ChangedFile = Invoke-Restmethod "https://api.github.com/repos/$($GitHubRepository)/pulls/$($GitHubPRNumber)/files"
Write-Debug ($ChangedFile | Out-String)

# Get Folders
$FolderArray = @()
$ChangedFile | Foreach-Object {
    Write-Host $_.filename
    if ($_.filename.contains('/')) {
        #$FolderArray += $_.filename.split('/')[0]
        $FolderArray += "$($_.filename | Split-Path)"
    }
    else {
        write-warning "The pull request contains a top level file of the repository. The repo admin is notified to review the pull request."
    }
}

$FolderArray = @($FolderArray | Select-Object -Unique)

# go through folders
# look for azuredeploy.json - if not go to it's parent to find it
# if there's more than one at a different path fail the build

<#
/foo/bar/baz/foo.json (azuredeploy in bar)
/foo/bar/baz/scripts/script.ps1 (azuredeploy in bar)
/foo/bar/baz/stuff/script.ps1 (azuredeploy in bar)
/foo/not/too/scripts/script.ps1 (azuredeploy in not)
/foo/not/too/foo.json
#>


# Files changes span scenario folders?
if ($FolderArray.count -gt 1) {
    Write-Error "The Pull request contains file changes in sample level folders. A pull request can only contain changes to files from a single sample)" 
}

# Update pipeline variable
$FolderString = $FolderArray -join ","
Write-Host $FolderString
Write-Host "##vso[task.setvariable variable=SampleFolder]$FolderString"
