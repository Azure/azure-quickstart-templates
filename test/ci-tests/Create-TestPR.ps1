param(
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path "$PSScriptRoot/../.."

$testBranches = @( `
    "bicep-json-doesnt-match", `
    "bicep-needs-fixing", `
    "bicep-success", `
    "bicep-warnings", `
    "bicep-with-prereqs-success" `
)

$yesAll = $false
foreach ($shortBranch in $TestBranches) {
  $fullBranch = "keep/testdeployment/$shortBranch"
  
  $yes = $false
  if (!$yesAll) {
    $answer = Read-Host "Create a PR for $fullBranch (Y/N/A)"
    if ($answer -eq 'Y') {
      $yes = $true
    }
    elseif ($answer -eq 'All' -or $answer -eq 'A') {
      $yes = $true
      $yesAll = $true
    }
  } else {
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
