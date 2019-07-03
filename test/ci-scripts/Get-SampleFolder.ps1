<#
This script will find the sample folder for the PR - Test are run on that folder only
If the PR contains more than one sample the build must fail
If the PR does not contain changes to a sample folder, it will currently fail but we'll TODO this
#>

$GitHubRepository = $ENV:BUILD_REPOSITORY_NAME
$GitHubPRNumber = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER
$RepoRoot = $ENV:BUILD_REPOSITORY_LOCALPATH

#$ChangedFile = Invoke-Restmethod "https://api.github.com/repos/$($GitHubRepository)/pulls/$($GitHubPRNumber)/files"
#$RepoRoot = "c:\users\bmoore\source\repos\azure-quickstart-templates"
$ChangedFile = Invoke-Restmethod "https://api.github.com/repos/Azure/azure-quickstart-templates/pulls/6267/files"

Get-ChildItem env:
#Write-Output "$(Get-ChildItem -Path $ENV:AGENT_BUILDDIRECTORY -Recurse)"
Write-Output "$RepoRoot"

$FolderArray = @()
$ChangedFile | ForEach-Object {
    Write-Output $_.blob_url
    $CurrentPath = Split-Path (Join-Path -path $RepoRoot -ChildPath $_.filename)
 
    # File in root of repo?
    If ($CurrentPath -eq $RepoRoot) {
        Write-Error "### Error ### The file $($_.filename) is in the root of the repository. A PR can only contain changes to files from a sample folder at this time."
    }
    Else {
        # Metadata in current folder?
        while (!(Test-Path (Join-Path -path $CurrentPath -ChildPath "metadata.json")) -and $CurrentPath -ne $RepoRoot) {
            $CurrentPath = Split-Path $CurrentPath
        }
 
        If ($CurrentPath -eq $RepoRoot) {
            Write-Error "### Error ### The scenario folder for $($_.filename) does not include a metadata.json file. Please add a metadata.json file to your scenario folder as part of the pull request."
        }
        Else {
            $FolderArray += $currentpath
        }
    }
}
 
$FolderArray = @($FolderArray | Select-Object -Unique)
 
If ($FolderArray.count -gt 1) {
 
    Write-Error "### Error ### The Pull request contains file changes from $($FolderArray.count) scenario folders. A pull request can only contain changes to files from a single scenario folder."
 
}
 
# Update pipeline variable
$FolderString = $FolderArray[0]
Write-Output "Using sample folder: $FolderString"
Write-Host "##vso[task.setvariable variable=SampleFolder]$FolderString"

