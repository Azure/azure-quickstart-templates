<#

Determines the deployment file to use.
For JSON samples, this is the JSON file included.
For bicep samples:
  Build the bicep file to check for errors.
  For PRs, verify that the JSON included in the sample has the same hash as the JSON we build.
  Remove the built file.

#>

[CmdletBinding()] # Cmdlet binding needed to enable using -ErrorAction, -ErrorVariable etc from testing
param (
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $MainTemplateFilenameBicep = $ENV:MAINTEMPLATE_FILENAME,
    [string] $MainTemplateFilenameJson = $ENV:MAINTEMPLATE_FILENAME_JSON,
    [string] $BuildReason = $ENV:BUILD_REASON,
    [string] $BicepPath = $ENV:BICEP_PATH,
    [string] $BicepVersion = $ENV:BICEP_VERSION,
    [switch] $bicepSupported = ($ENV:BICEP_SUPPORTED -eq "true")
)

$Error.Clear()
$isPR = $BuildReason -eq "PullRequest"

Write-Host "##vso[task.setvariable variable=label.bicep.warnings]false"

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
    
    $warnings = 0
    $errors = 0
    foreach ($item in $errorOutput) {
        if ($item -imatch ": Warning ") {
            $warnings += 1
            Write-Warning $item
        }
        elseif ($item -imatch ": Error BCP") {
            $errors += 1
            Write-Error $item
        }
        else {
            # Build succeeded: 0 Warning(s), 0 Error(s) [possibly localized]
            if ($item -match " 0 .* 0 ") {
                # Succeeded
            }
            else {
                # This should only occur on the last line (the error/warnings summary line)
                if ($item -ne $errorOutput[-1]) {
                    throw "Only the last error output line should not be a warning or error"
                }
            }
        }
    }

    if (($errors -gt 0) -or !(Test-Path $CompiledJsonPath)) {
        # Can't continue, fail pipeline
        Write-Error "Bicep build failed."
        return
    }    

    if ($warnings -gt 0) {
        # Can't continue, fail pipeline
        Write-Warning "Bicep build had warnings."
        Write-Host "##vso[task.setvariable variable=label.bicep.warnings]true"
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

Write-Host "File to deploy: $fileToDeploy"
Write-Host "##vso[task.setvariable variable=mainTemplate.deployment.filename]$fileToDeploy"
