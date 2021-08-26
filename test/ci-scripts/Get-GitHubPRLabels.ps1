<#

This script will get the labels on a PR - right now we look to see if the "bypass delete" label is set to preserve the RGs

#>

param(
    [string]$GitHubRepository = $ENV:BUILD_REPOSITORY_NAME,
    [string]$GitHubPRNumber = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER,
    [string]$RepoRoot = $ENV:BUILD_REPOSITORY_LOCALPATH
)

# only run this on PR - should also be protected in the pipeline
if ($ENV:BUILD_REASON -eq "PullRequest") {

    $PRUri = "https://api.github.com/repos/$($GitHubRepository)/pulls/$($GitHubPRNumber)"

    $r = Invoke-Restmethod "$PRUri" -Verbose

    foreach ($l in $r.labels) {
        Write-Host "Found label = $($l.name)"
        if($l.name -eq "bypass delete"){
            Write-Host "Setting bypass.delete env var = true..."
            Write-Host "##vso[task.setvariable variable=bypass.delete]true"
        }
    }
}
