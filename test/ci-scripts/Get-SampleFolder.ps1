<#
This script will find the sample folder for the PR - Tests are run on that folder only
If the PR contains more than one sample the build must fail
If the PR does not contain changes to a sample folder, it will currently fail but we'll TODO this to
pass the build in order to trigger a manual review
#>

# Get-ChildItem env: # debugging

$GitHubRepository = $ENV:BUILD_REPOSITORY_NAME
$RepoRoot = $ENV:BUILD_REPOSITORY_LOCALPATH

if ($ENV:BUILD_REASON -eq "PullRequest") {
    $GitHubPRNumber = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER
}
elseif ($ENV:BUILD_REASON -eq "BatchedCI" -or $ENV:BUILD_REASON -eq "IndividualCI" -or $ENV:BUILD_REASON -eq "Manual") {
    <#
        When a CI trigger is running, we get no information in the environment about what changed in the incoming PUSH (i.e. PR# or files changed) except...
        In the source version message - so even though this fragile, we can extract from there - the expected format is:
        BUILD_SOURCEVERSIONMESSAGE = "Merge pull request #9 from bmoore-msft/bmoore-msft-patch-2…"
        2021-04-18 - they changed the format of the message again, now its:
        BUILD_SOURCEVERSIONMESSAGE = 101 event grid - Add bicep badge (#8997)
    #>
    try {
        $pr = $ENV:BUILD_SOURCEVERSIONMESSAGE # TODO: sometimes AzDO is not setting the message, not clear why...
        $begin = 0
        $begin = $pr.IndexOf("#") # look for the #
    }
    catch { }
    if ($begin -ge 0) {
        $end = $pr.IndexOf(")", $begin) # look for the trailing space
        if($end -eq -1){
            $end = $pr.IndexOf(" ", $begin) # look for the trailing space
        }
        $GitHubPRNumber = $pr.Substring($begin + 1, $end - $begin - 1)
    }
    else {
        Write-Error "BuildSourceVersionMessage does not contain PR #: `'$pr`'"
    }
}
else {
    Write-Error "Unknown Build Reason ($ENV:BUILD_REASON) - cannot get PR number... "
}

$PRUri = "https://api.github.com/repos/$($GitHubRepository)/pulls/$($GitHubPRNumber)/files"

# Get all of the files changed in the PR
$ChangedFile = Invoke-Restmethod "$PRUri"

# Now check to make sure there is exactly one sample in this PR per repo guidelines
$FolderArray = @()
$ChangedFile | ForEach-Object {
    Write-Output $_.blob_url
    if ($_.status -ne "removed") {
        # ignore deleted files, for example when a sample folder is renamed
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
}

# Get the unique paths we found metadata.json in - there should be no more then one
$FolderArray = @($FolderArray | Select-Object -Unique)
 
If ($FolderArray.count -gt 1) {
    Write-Error "### Error ### The Pull request contains file changes from $($FolderArray.count) scenario folders. A pull request can only contain changes to files from a single scenario folder."
}

# Update pipeline variable with the sample folder and name
$FolderString = $FolderArray[0]
Write-Output "Using sample folder: $FolderString"
Write-Host "##vso[task.setvariable variable=sample.folder]$FolderString"

$sampleName = $FolderString.Replace("$ENV:BUILD_SOURCESDIRECTORY\", "").Replace("$ENV:BUILD_SOURCESDIRECTORY/", "")
Write-Output "Using sample name: $sampleName"
Write-Host "##vso[task.setvariable variable=sample.name]$sampleName"
