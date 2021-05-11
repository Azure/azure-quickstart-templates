param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $CloudEnvironment = $ENV:ENVIRONMENT,
    [string] $BuildReason = $ENV:BUILD_REASON
)

#get the file content
Write-host "Validating metadata file: $SampleFolder\metadata.json"
$metadata = Get-Content -Path "$SampleFolder\metadata.json" -Raw 

#Check metadata.json against the schema
Write-host "Validating contents against JSON schema from https://aka.ms/azure-quickstart-templates-metadata-schema"
$schema = Invoke-WebRequest -Uri "https://aka.ms/azure-quickstart-templates-metadata-schema" -UseBasicParsing
$metadata | Test-Json -Schema $schema.content

#Make sure the date has been updated
$rawDate = ($metadata | convertfrom-json).dateUpdated
$dateUpdated = (Get-Date $rawDate)

if ($ENV:BUILD_REASON -eq "PullRequest") {
    #When running the scheduled tests, we don't want to check the date
    try {
        [DateTime]::ParseExact($rawDate, 'yyyy-MM-dd', $(Get-Culture))
    }
    Catch {
        Write-Error "dateUpdate is not in the correct format: $rawDate must be in yyyy-MM-dd format."
    }
    # Provide one day grace in the future since half the planet is ahead of UTC
    if ($dateUpdated -gt (Get-Date).AddDays(1)) {
        Write-Error "dateUpdated in metadata.json must not be in the future -- $dateUpdated is later than $((Get-Date).AddDays(1))"
    }
    $oldDate = (Get-Date).AddDays(-60)
    if ($dateUpdated -lt $oldDate) {
        Write-Error "dateUpdated in metadata.json needs to be updated -- $dateUpdated is older than $oldDate"
    }
}

# check to see which clouds are supported, if not specified, test all clouds
Write-Host $metadata
$environments = ($metadata | convertfrom-json).environments
Write-Host "environments: $environments"

if ($null -ne $environments) {
    Write-Host "Checking cloud..."
    $IsCloudSupported = ($environments -contains $CloudEnvironment)
    $supportedEnvironments = $environments
}
else {
    $IsCloudSupported = $true
    $supportedEnvironments = @("AzureCloud", "AzureUSGovernment") # Default is all clouds are supported
}

# if there is a docOwner, we need to notify that owner via a PR comment
$docOwner = ($metadata | convertfrom-json).docOwner
Write-Host "docOwner: $docOwner"
if ($null -ne $docOwner) {
    $msg = "@$docOwner - check this PR for updates that may be needed to documentation that references this sample.  [This is an automated message. You are receiving it because you are listed as the docOwner in metadata.json.]"
    Write-Host "##vso[task.setvariable variable=docOwner.message]$msg"
}

$s = $supportedEnvironments | ConvertTo-Json -Compress
Write-Host "##vso[task.setvariable variable=supported.environments]$s"
# Set-Item -path "env:supported_environments" -value "$s"

Write-Output "Is cloud supported: $IsCloudSupported"
# if the cloud is not supported, set the result var to "Not Supported", else leave the default of "False" 
# and then the result.deployment will indeed be the result of the test if supported
if (!$IsCloudSupported) {
    Write-Host "##vso[task.setvariable variable=result.deployment]Not Supported"
}

$validationType = ($metadata | convertfrom-json).validationType
Write-Output "Validation type from metadata.json: $validationType"

if ($validationType -eq "Manual") {
    Write-Host "##vso[task.setvariable variable=validation.type]$validationType"
    Write-Host "##vso[task.setvariable variable=result.deployment]Not Supported" # set this so the pipeline does not run deployment will be overridden in the test results step
}

# pipeline variable should default to FAIL
Write-Host "Count: $($error.count)"
if ($error.count -eq 0) {
    Write-Host "##vso[task.setvariable variable=result.metadata]PASS"
}
