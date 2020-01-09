param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER,
    [string] $CloudEnvironment = $ENV:ENVIRONMENT,
    [switch] $SkipDateCheck
)

#get the file content
Write-Output "Testing file: $SampleFolder\metadata.json"
$metadata = Get-Content -Path "$SampleFolder\metadata.json" -Raw 

#Check metadata.json against the schema
$schema = Invoke-WebRequest -Uri "https://aka.ms/azure-quickstart-templates-metadata-schema#" -UseBasicParsing
$metadata | Test-Json -Schema $schema.content 

#Make sure the date has been updated
$rawDate = ($metadata | convertfrom-json).dateUpdated
$dateUpdated = (Get-Date $rawDate)

if (!$SkipDateCheck) {
    #When running the scheduled tests, we don't want to check the date
    try {
        [DateTime]::ParseExact($rawDate, 'yyyy-MM-dd', $(Get-Culture))
    }
    Catch {
        Write-Error "dateUpdate is not in the correct format: $rawDate must be in yyyy-MM-dd format."
    }
    if ($dateUpdated -gt (Get-Date)) {
        Write-Error "dateUpdated in metadata.json must not be in the future -- $dateUpdated is later than $(Get-Date)"
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
}
else {
    $IsCloudSupported = $true
}

Write-Output "Is cloud supported: $IsCloudSupported"
# if the cloud is not supported, set the result var to "Not Supported", else leave the default of "False" 
# and then the result.deployment will indeed be the result of the test if supported
if (!$IsCloudSupported) {
    Write-Host "##vso[task.setvariable variable=result.deployment]Not Supported"
}

