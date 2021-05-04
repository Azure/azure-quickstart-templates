<#

Determines the deployment file to use.
For JSON samples, this is the JSON file included.
For bicep samples:
  Build the JSON to deploy, since bicep might have changed since the JSON included
  in the sample was built.
  For PRs, verify that the JSON included in the sample has the same hash as the JSON we build

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
    Write-host "BUILDING: $BicepPath build $MainTemplatePathBicep --outfile $CompiledJsonPath"
    & $BicepPath build $MainTemplatePathBicep --outfile $CompiledJsonPath
    if (!(Test-Path $CompiledJsonPath)) {
        Write-Error "Bicep build produced no output file. Check above for build errors."
        return
    }
    
    # If this is a PR, compare it against the JSON file included in the sample
    if ($isPR) {
        $hashesMatch = & $PSScriptRoot/Validate-TemplateHash.ps1 `
            -TemplateFilePathExpected $CompiledJsonPath `
            -TemplateFilePathActual $MainTemplatePathJson `
            -ErrorAction Ignore # Ignore so we can write the following error message
        if (!$hashesMatch) {
            Write-Error ("The JSON in the sample does not match the JSON built from bicep`n" `
                    + "Either copy the expected output from the log into $MainTemplateFilenameJson or run the command ``bicep build $mainTemplateFilenameBicep --outfile $MainTemplateFilenameJson`` in your sample folder using bicep version $BicepVersion")
        }
    }
    
    # Deploy the compiled JSON file, not the one included in the sample (we might be using a different version of bicep now)
    $fileToDeploy = $CompiledJsonFilename
    Write-Host "##vso[task.setvariable variable=compiled.json.filename]$CompiledJsonFilename"
}
else {
    # Just deploy the JSON file included in the sample
    Write-Host "Bicep not supported in this sample, deploying to $MainTemplateFilenameJson"
    $fileToDeploy = $MainTemplateFilenameJson
}

Write-Host "Deploying the file $fileToDeploy"
Write-Host "##vso[task.setvariable variable=mainTemplate.deployment.filename]$fileToDeploy"
