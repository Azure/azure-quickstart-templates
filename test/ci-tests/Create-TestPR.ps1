param(
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path "$PSScriptRoot/../.."
Write-Warning $repoRoot

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
  }

  if ($yes) {
    $body = @"
This is a test deployment for branch $longBranch
"@

    gh pr create --title "Test: $shortBranch" --body $body --label "test deployment" --repo "Azure/azure-quickstart-templates" --draft
  }
}
