
<#

    Check for bicep support in metadata.json or the bicep file itself.  They must agree, when running the bicep pipeline which is determined by the
    TEMPLATE_FULLPATH build variable.

    Pipeline Type | Files Found in Sample | Metadata Language Type | Action
    --------------|-----------------------|------------------------|----------
    1)  Bicep     |        Bicep          |        Bicep           | Continue
    2)  Bicep     |        Bicep          |        JSON            | Fail since metadata needs to be updated, we'll test after that
    3)  Bicep     |        JSON           |        Bicep           | Fail, no bicep file to test
    4)  Bicep     |        JSON           |        JSON            | Silently exit so the PR results are clean, this isn't a bicep sample
        JSON      |        Bicep          |        Bicep           | Continue (there should always be JSON)
        JSON      |        Bicep          |        JSON            | Continue (there should always be JSON)
        JSON      |        JSON           |        Bicep           | Continue (there should always be JSON)
        JSON      |        JSON           |        JSON            | Continue (there should always be JSON)

    Note: for the JSON pipeline, there should always be a json file (for now) so we continue, any bicep file/metadata mismatches
    will be caught in the bicep pipeline

#>

param(
    $sampleFolder = $ENV:SAMPLE_FOLDER,
    $templateFile = $ENV:TEMPLATE_FILE, # this will indicate the pipeline type if the filename endswith .bicep
    $isBicepInMetadata = $ENV:IS_BICEP_IN_METADATA # determines whether the bicep lang was in the metadata file
)

$templateFullPath = "$sampleFolder\$templateFile"
$isBicepPipeline = $templateFullPath.Endswith('.bicep')
$isBicepFileFound = Test-Path $templateFullPath

# if this isn't a bicep pipeline, there's nothing to do, all the defaults should work
if ($isBicepPipeline) {
    if ($isBicepFileFound) {
        if ($isBicepInMetadata) {
            # (1) this is the way
            Write-Host "##vso[task.setvariable variable=run.deployment]$true"
        }
        else {
            # (2) file was found but metadata was not correct
            Write-Error "A bicep file was found in the sample ($templateFullPath) but the bicep language was not specified in metadata.json"
        }
    }
    elseif ($isBicepInMetadata) {
        # (3) metadata indicates this is a bicep sample, but the file was not found
        Write-Error "bicep language is specified in metadata.json but ($templateFullPath) was not found."
    }
    else { # this is the bicep pipeline but there's no bicep file or metadata set, so just skip the rest of the pipeline and update the badge & metadata table
        # (4) abort the pipeline but don't fail it (we want a green checkmark)
        Write-Host "##vso[task.setvariable variable=run.deployment]$false"
        # for the readme we need to say that deployment is not supported (or available?)
        Write-Host "##vso[task.setvariable variable=result.deployment]Not Supported" 
    }
} else {
    # if it's not a bicep pipeline, run deployment since JSON is always supported (for now)
    Write-Host "##vso[task.setvariable variable=run.deployment]$true"
}
