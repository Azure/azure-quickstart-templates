<# 
This script gets the folders that have changed in the PR - only one sample is allowed per PR.  

Currently it expects the folder to be in the root - but once the repo is re-orged, this will need to change
#>

#region variables

$GitHubRepository = $ENV:BUILD_REPOSITORY_NAME
$GitHubPRNumber = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER
#for testing
$GitHubRepository = "Azure/azure-quickstart-templates"
$GitHubPRNumber = "5980"

#endregion

# Get Changed Files
$ChangedFile = Invoke-Restmethod "https://api.github.com/repos/$($GitHubRepository)/pulls/$($GitHubPRNumber)/files"
Write-Debug ($ChangedFile | Out-String)

# Get Folders
$FolderArray = @()
$ChangedFile | Foreach-Object {
    Write-Host $_.filename
    if ($_.filename.contains('/')) {
        $FolderArray += $_.filename.split('/')[0]
    }
    else {
        write-warning "The pull request contains a top level file of the repository. The repo admin is notified to review the pull request."
    }
}

$FolderArray = $FolderArray | Select-Object -Unique

# Files changes span scenario folders?
if ($FolderArray.count -gt 1) {
    Write-Error "The Pull request contains file changes in sample level folders. A pull request can only contain changes to files from a single sample)" 
}

# Updare pipeline varibale
$FolderString = $FolderArray -join ","
Write-Host $FolderString
Write-Host "##vso[task.setvariable variable=SampleFolder]$FolderString"
