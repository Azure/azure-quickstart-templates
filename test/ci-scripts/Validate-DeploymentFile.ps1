<#

Determines the deployment file to use.
For JSON samples, this is the JSON file included.
For bicep samples:
  Build the bicep file to check for errors.
  For PRs, verify that the JSON included in the sample has the same hash as the JSON we build.
  Remove the built file.

#>

param (
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $MainTemplateFilenameBicep = $ENV:MAINTEMPLATE_FILENAME,
    [string] $MainTemplateFilenameJson = $ENV:MAINTEMPLATE_FILENAME_JSON,
    [string] $BuildReason = $ENV:BUILD_REASON,
    [string] $BicepPath = $ENV:BICEP_PATH,
    [string] $BicepVersion = $ENV:BICEP_VERSION,
    [switch] $bicepSupported = ($ENV:BICEP_SUPPORTED -eq "true")
)

$isPR = $BuildReason -eq "PullRequest"

if ($bicepSupported) {
    $MainTemplatePathBicep = "$($SampleFolder)/$($MainTemplateFilenameBicep)"
    $MainTemplatePathJson = "$($SampleFolder)/$($MainTemplateFilenameJson)"
    
    # Build a JSON version of the bicep file
    $CompiledJsonFilename = "$($MainTemplateFilenameBicep).temp.json"
    $CompiledJsonPath = "$($SampleFolder)/$($CompiledJsonFilename)"
    $errorFile = Join-Path $SampleFolder "errors.txt"
    Write-host "BUILDING: $BicepPath build $MainTemplatePathBicep --outfile $CompiledJsonPath"
    Start-Process $BicepPath -ArgumentList @('build', $MainTemplatePathBicep, '--outfile', $CompiledJsonPath) -RedirectStandardError $errorFile -Wait
    $errorOutput = [string[]](Get-Content $errorFile)
    Remove-Item $errorFile
    
    if (!(Test-Path $CompiledJsonPath)) {
        Write-Error "Bicep build produced no output file. Check above for build errors."
        return
    }

    $errors = @()
    foreach ($item in $errorOutput) {
        if ($item -imatch " Warning BCP") {
            Write-Warning $item
        }
        else {
            $errors += $item
        }
    }
    if ($errors) {
        Write-Error ($errors -join "`n")
    }

    # If this is a PR, compare it against the JSON file included in the sample
    if ($isPR) {
        $templatesMatch = & $PSScriptRoot/Compare-Templates.ps1 `
            -TemplateFilePathExpected $CompiledJsonPath `
            -TemplateFilePathActual $MainTemplatePathJson `
            -RemoveGeneratorMetadata `
            -WriteToHost `
            -ErrorAction Ignore # Ignore so we can write the following error message instead
        if (!$templatesMatch) {
            Write-Error ("The JSON in the sample does not match the JSON built from bicep.`n" `
                    + "Either copy the expected output from the log into $MainTemplateFilenameJson or run the command ``bicep build $mainTemplateFilenameBicep --outfile $MainTemplateFilenameJson`` in your sample folder using bicep version $BicepVersion")
        }
    }
    
    # Deploy the JSON file included in the sample, not the one we temporarily built
    $fileToDeploy = $MainTemplateFilenameJson

    # Delete the temporary built JSON file
    Remove-Item $CompiledJsonPath
}
else {
    # Just deploy the JSON file included in the sample
    Write-Host "Bicep not supported in this sample, deploying to $MainTemplateFilenameJson"
    $fileToDeploy = $MainTemplateFilenameJson
}

Write-Host "Deploying the file $fileToDeploy"
Write-Host "##vso[task.setvariable variable=mainTemplate.deployment.filename]$fileToDeploy"
