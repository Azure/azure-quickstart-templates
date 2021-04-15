
<# 

Verifies that two JSON template files match by hash

#>
param(
    [string][Parameter(mandatory = $true)] $templateFilePathExpected,
    [string][Parameter(mandatory = $true)] $templateFilePathActual,
    [string]$bearerToken
)

Write-Host "Comparing $templateFilePathExpected and $templateFilePathActual"

$templateHashExpected = $null
$templateHashActual = $null

$templateContentsExpected = Get-Content $templateFilePathExpected -Raw
$templateContentsActual = Get-Content $templateFilePathActual -Raw

$templateHashExpected = & "$PSScriptRoot/Get-TemplateHash.ps1" -templateFilePath $templateFilePathExpected -bearerToken $bearerToken
$templateHashActual = & "$PSScriptRoot/Get-TemplateHash.ps1" -templateFilePath $templateFilePathActual -bearerToken $bearerToken

Write-Host "Hash for templateFilePathExpected: $templateHashExpected"
Write-Host "Hash for templateFilePathActual: $templateHashActual"

if (($templateHashExpected -cne $templateHashActual) -or ($null -eq $templateHashExpected) -or ($null -eq $templateHashActual)) {
    Write-Host "`n`n************* ACTUAL CONTENTS ****************`n$templateContentsActual`n***************** END OF ACTUAL CONTENTS ***************"
    Write-Host "`n`n************* EXPECTED CONTENTS ****************`n$templateContentsExpected`n***************** END OF ACTUAL CONTENTS ***************"

    Write-Error "The templates do not match (testing by their hashes)"
    return $false
}
else {
    return $true
}
