<#

    Detect unwanted raw output from bicep decompile command

#>

param(
    $sampleFolder = $ENV:SAMPLE_FOLDER
)

Write-Host "Finding all bicep files in: $sampleFolder"
$bicepFiles = Get-ChildItem -Path "$sampleFolder\*.bicep" -Recurse

foreach ($f in $bicepFiles) {

    $bicepText = Get-Content -Path $f.FullName -Raw

    # check for use of _var, _resource, _param - raw output from decompile
    $bicepText | Select-String -Pattern "resource \w{1,}_resource | \w{1,}_var | \w{1,}_param | \w{1,}_id" -AllMatches |
    foreach-object { $_.Matches } | foreach-object {
        Write-Warning "$($f.Name) may contain raw output from decompile, please clean up: $($_.Value)"
        # write the environment var
        Write-Host "##vso[task.setvariable variable=label.decompile.clean-up.needed]$true"
    }
}
