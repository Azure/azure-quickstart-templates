param(
    [string][Parameter(mandatory=$true)] $path
)

#get the file content
#$metadata = Get-Content -Path "$(sample.folder)\metadata.json" -Raw 
$metadata = Get-Content -Path $path -Raw 

#Check metadata.json against the schema
$schema = Invoke-WebRequest -Uri "https://aka.ms/azure-quickstart-templates-metadata-schema#" -UseBasicParsing
$metadata | Test-Json -Schema $schema.content 

#Make sure the date has been updated
$dateUpdated = (Get-Date ($metadata | convertfrom-json).dateUpdated)

if($dateUpdated -gt (Get-Date)){
    Write-Error "dateUpdated in metadata.json must not be in the future"
    Write-Error "$dateUpdated is later than $(Get-Date)"
}

$oldDate = (Get-Date).AddDays(-60)
if($dateUpdated -lt $oldDate){
    Write-Error "dateUpdated in metadata.json needs to be updated"
    Write-Error "$dateUpdated is older than $oldDate"
}
