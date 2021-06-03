
<# 

Verifies that two JSON template files have the same hash (after removing generator metadata)

#>
param(
    [string][Parameter(mandatory = $true)] $TemplateFilePathExpected,
    [string][Parameter(mandatory = $true)] $TemplateFilePathActual,
    [switch] $RemoveGeneratorMetadata,
    [switch] $WriteToHost
)

Import-Module "$PSScriptRoot/Local.psm1" -Force

if ($WriteToHost) {
    Write-Host "Comparing $TemplateFilePathExpected and $TemplateFilePathActual"
}

$templateContentsExpectedRaw = Get-Content $TemplateFilePathExpected -Raw
$templateContentsActualRaw = Get-Content $TemplateFilePathActual -Raw

if ($RemoveGeneratorMetadata) {
    $templateContentsExpectedRaw = Remove-GeneratorMetadata $templateContentsExpectedRaw
    $templateContentsActualRaw = Remove-GeneratorMetadata $templateContentsActualRaw
}

$templateContentsExpected = Convert-StringToLines $templateContentsExpectedRaw
$templateContentsActual = Convert-StringToLines $templateContentsActualRaw

# Assert-IsTrue ($templateContentsExpected -is [string[]])
# Assert-IsTrue ($templateContentsActual -is [string[]])

$diffs = Compare-Object $templateContentsExpected $templateContentsActual

if ($diffs) {
    if ($WriteToHost) {
        Write-Warning "The templates do not match"
        Write-Verbose "`n`n************* ACTUAL CONTENTS ****************"
        Write-Verbose $templateContentsActualRaw
        Write-Verbose "***************** END OF ACTUAL CONTENTS ***************"
        Write-Host "`n`n************* EXPECTED CONTENTS ****************"
        Write-Host $templateContentsExpectedRaw
        Write-host "***************** END OF EXPECTED CONTENTS ***************"

        Write-Host "`n`n************* DIFFERENCES (IGNORING METADATA) ****************`n"
        $diffs | Out-String | Write-Host
        Write-Host "`n***************** END OF DIFFERENCES ***************"
    }
    
    return $false
}
else {
    if($WriteToHost) {
        Write-Host "Files are identical (not counting metadata)"
    }
    return $true
}
