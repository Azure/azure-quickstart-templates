param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string] $SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string] $ReadMeFileName = "README.md"
)

#Write-Host "StorageAccountName: $StorageAccountName"
$bicepSupported = (Test-Path "$SampleFolder/main.bicep")
Write-Host "bicepSupported: $bicepSupported"

$readmePath = "$SampleFolder/$ReadMeFileName"
Write-Output "Testing file: $readmePath"

Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output $readme

$readme = Get-Content $readmePath -Raw
Write-Output $readme

# Now automatically add the header needed for doc samples
# get metadata
$metadata = Get-Content -Path "$SampleFolder\metadata.json" -Raw | ConvertFrom-Json 
$H1 = "# $($metadata.itemDisplayName)"
$metadataDescription = $metadata.description # note this will be truncated to 150 chars but the summary is usually the same as the itemDisplayName

# find H1
# we need to read the readme as an array to find the line and not some random # tag - though every readme should have this at the top by now
[string[]]$readmeArray = Get-Content $readmePath

$currentH1 = ""
for ($i = 0; $i -lt $readmeArray.Length; $i++) {
    if ($readmeArray[$i].StartsWith("# ")) {
        # Get the current H1
        $currentH1 = $readmeArray[$i]
        break
    }
}

if ($currentH1 -eq "") {
    # we didn't find a header in the readme - throw and don't try to write the file
    Write-Error "Couldn't find H1 in the current readme file."
}
else {
    # we found H1 and can update the readme
    # replace # H1 with our new $H1
    $readme = $readme.Replace($currentH1, $H1)

    # remove everything before H1 so we can insert clean YAML (i.e. remove he previous YAML or any junk user submitted)
    $readme = $readme.Substring($readme.IndexOf($H1))

    <#
    This YAML is case sensitive in places
    ---
    description: // replace with description property from metadata.json
    page_type: sample // must always be 'sample'
    languages:
    - bicep // only if there is a bicep file
    - json
    products:
    - azure // eventually this needs to be azure-quickstart-templates (or whatever our product is)
    ---
    #>

$YAML = 
@"
---
description: %description%
page_type: sample
products:
- azure
languages:
- json
"@

        # add bicep to the list of languages as appropriate
        if ($bicepSupported) {
            $YAML = $YAML + "`n- bicep"
        }

        # close the YAML block
        $YAML = $YAML + "`n---`n"

        # update the description
        $YAML = $YAML.Replace('%description%', $metadataDescription)

        # prepend the YAML
        # TODO - comment out for now until the issues are addressed
        # $readme = "$YAML$readme"

        # commit the change
        #Write-Output $readme
        $readme | Set-Content $readmePath -NoNewline

}

Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output $readme
