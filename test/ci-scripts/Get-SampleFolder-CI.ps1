<#

When CI is triggered, get the commit from that trigger and run post processing

If the PR contains more than one sample the build must fail

If the PR does not contain changes to a sample folder ??? it will currently fail but we'll TODO this to pass the build in order to trigger a manual review

#>

param(
    $GitHubRepository = $ENV:BUILD_REPOSITORY_NAME, # Azure/azure-quickstart-templates
    $RepoRoot = $ENV:BUILD_REPOSITORY_LOCALPATH, # D:\a\1\s
    $commit = $ENV:BUILD_SOURCEVERSION
    
)

#https://api.github.com/repos/Azure/azure-quickstart-templates/commits/e4d70f11e18e93c3ea659c2e5f8b1ae6891a0fdf

$uri = "https://api.github.com/repos/$($GitHubRepository)/commits/$($commit)"

# Get all of the files changed in the PR
$r = Invoke-Restmethod -method GET -uri "$uri"

# Now check to make sure there is exactly one sample in this PR per repo guidelines
$FolderArray = @()

foreach ($f in $r.files) {
    <# $f is tr.files tem #>
    Write-Output $f.filename
    if ($f.status -ne "removed") {
        # ignore deleted files, for example when a sample folder is renamed
        $CurrentPath = Split-Path (Join-Path -path $RepoRoot -ChildPath $f.filename)

        # find metadata.json
        while (!(Test-Path (Join-Path -path $CurrentPath -ChildPath "metadata.json")) -and $CurrentPath -ne $RepoRoot) {
            $CurrentPath = Split-Path $CurrentPath # if it's not in the same folder as this file, search it's parent
        }
        # if we made it to the root searching for metadata.json write the error
        If ($CurrentPath -eq $RepoRoot) {
            Write-Error "### Error ### The scenario folder for $($f.filename) does not include a metadata.json file. Please add a metadata.json file to your scenario folder as part of the pull request."
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

# Update pipeline variable with the sample folder and name
$FolderString = $FolderArray[0]
Write-Output "Using sample folder: $FolderString"
Write-Host "##vso[task.setvariable variable=sample.folder]$FolderString"

# if this is a bicep sample, is the json file in the list of changed files?  if so, flag it
if (Test-Path -Path "$FolderString\main.bicep") {
    foreach($f in $r.files) {
        # Write-Output "File in PR: $f"
        if (($f.filename).EndsWith("azuredeploy.json") -and ($f.status -ne "removed")) {
            Write-Warning "$($f.filename) is included in the PR for a bicep sample"
            Write-Host "##vso[task.setvariable variable=json.with.bicep]$true"
        }
    }
}

$sampleName = $FolderString.Replace("$RepoRoot\", "").Replace("$RepoRoot/", "")
Write-Output "Using sample name: $sampleName"
Write-Host "##vso[task.setvariable variable=sample.name]$sampleName"

#Write-Output "Using github PR#: $GitHubPRNumber"
#Write-Host "##vso[task.setvariable variable=github.pr.number]$GitHubPRNumber"
