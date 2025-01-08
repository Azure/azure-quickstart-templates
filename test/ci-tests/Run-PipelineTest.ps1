<#
 .SYNOPSIS
    Creates a set of test deployments in the pipeline

 .DESCRIPTION
    Creates a set of test deployments by creating PRs for saved test deployment branches (that begin with keep/testdeployment/)

#>

param(
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path "$PSScriptRoot/../.."

# Names of current test branches that can be deployed (without the keep/testdeployment/ prefix)
# CONSIDER: Automatically populate by running git branch -r
$testBranches = @( `
    "bicep-json-doesnt-match", `
    "bicep-success", `
    "bicep-warnings", `
    "bicep-errors", `
    "bicep-with-prereqs-success" `
)

$yesAll = $false
foreach ($shortBranch in $TestBranches) {
  write-warning $shortBranch
  $fullBranch = "keep/testdeployment/$shortBranch"
  write-warning $fullBranch
  
  $yes = $false
  if (!$yesAll) {
    $answer = Read-Host "Create a PR for $($fullBranch)? (Y/N/A)"
    if ($answer -eq 'Y') {
      $yes = $true
    }
    elseif ($answer -eq 'All' -or $answer -eq 'A') {
      $yes = $true
      $yesAll = $true
    }
  }
  else {
    $yes = $true
  }

  if ($yes) {
    git stash

    git checkout master
    git pull
    git checkout $fullBranch
    git rebase master
    git push -f

    $body = @"
DO NOT CHECK IN!
This is a test deployment for branch $fullBranch
"@

    gh pr create --head $fullBranch --title "Test: $shortBranch" --body $body --label "test deployment" --repo "Azure/azure-quickstart-templates" --draft

    git stash apply
  }
}
