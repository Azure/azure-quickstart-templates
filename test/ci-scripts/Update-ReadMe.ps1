param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string] $SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string] $ReadMeFileName = "README.md",
    [string] $ttkFolder = $ENV:TTK_FOLDER,
    [string]$mainTemplateFilename = $ENV:MAINTEMPLATE_FILENAME_JSON,
    [string]$prereqTemplateFileName = $ENV:PREREQ_TEMPLATE_FILENAME_JSON
)

# Need this for Find-JsonContent
Import-Module "$($ttkFolder)/arm-ttk/arm-ttk.psd1"

#Write-Host "StorageAccountName: $StorageAccountName"
$bicepSupported = (Test-Path "$SampleFolder/main.bicep")
Write-Host "bicepSupported: $bicepSupported"

$readmePath = "$SampleFolder/$ReadMeFileName"
Write-Output "Testing file: $readmePath"

Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'


$readme = Get-Content $readmePath -Raw
Write-Output $readme

# Now automatically add the header needed for doc samples
# get metadata
$metadata = Get-Content -Path "$SampleFolder\metadata.json" -Raw | ConvertFrom-Json 
$H1 = "# $($metadata.itemDisplayName)" # this cannot be duplicated in the repo, doc samples index this for some strange reason
$metadataDescription = $metadata.description # note this will be truncated to 150 chars but the summary is usually the same as the itemDisplayName

# update the data in metadata.json
$metadata.dateUpdated = (Get-Date).ToString("yyyy-MM-dd")
$metadata | ConvertTo-Json | Set-Content "$SampleFolder\metadata.json" -NoNewline


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
- azure-resource-manager
urlFragment: %urlFragment%
languages:
"@

    # add bicep to the list of languages as appropriate - it needs to be first in the list since doc samples only shows one at the moment
    if ($bicepSupported) {
        $YAML = $YAML + "`n- bicep"
    }

    # add JSON unconditionally, after bicep
    $YAML = $YAML + "`n- json"

    # close the YAML block
    $YAML = $YAML + "`n---`n"

    # update the description
    # replace disallowed chars
    $metadataDescription = $metadataDescription.Replace(":", "&#58;")

    # set an urlFragment to the path to minimize dupes - we use the last segment of the path, which may not be unique, but it's a friendlier url
    $YAML = $YAML.Replace('%description%', $metadataDescription)
    if($SampleName.StartsWith('modules')){
        $fragment = $SampleName.Replace('\', '-') # for modules we use version numbers, e.g. 0.9 so will have dupes
    }else{
        $fragment = $SampleName.Split('\')[-1]
    }
    $YAML = $YAML.Replace('%urlFragment%', $fragment)

    # prepend the YAML
    $readme = "$YAML$readme"

    # add tags
    $allResources = @()

    $allJsonFiles = Get-ChildItem "$sampleFolder\*.json" -Recurse | ForEach-Object -Process { $_.FullName }
    foreach ($file in $allJsonFiles) {
        if ($(split-path $file -leaf) -ne "metadata.json" -and
            !($(split-path $file -leaf).EndsWith("parameters.json"))) {
            $templateObject = Get-Content -Path $file -Raw | ConvertFrom-Json -Depth 100 -AsHashtable
            if ($templateObject.'$schema' -like "*deploymentTemplate.json#") {
                $templateResources = @{}
                $templateResources = Find-JsonContent -InputObject $templateObject.resources -Key type -Value "*" -Like # this will get every type property, even those in a properties body, we can filter below
                $allResources = $allResources + $templateResources
            }
        }
    }

    # Find Current Tags
    $currentTags = ""
    for ($i = 0; $i -lt $readmeArray.Length; $i++) {
        if ($readmeArray[$i].StartsWith('`Tags:')) {
            # Get the current Tags
            $currentTags = $readmeArray[$i]
            break
        }
    }

    $tagsArray = @($($currentTags -replace '`', '' -replace "Tags:", "").Split(",").Trim())

    Write-Host "CurrentTags Array: *$tagsArray*"
    foreach ($r in $allResources) {
        $t = $r.Type
        Write-Host "Checking for: $t at path $($r.jsonPath)"
        if (!($tagsArray -contains $t) -and $t.length -ne 0 -and !($r.jsonPath -like "*parameters*") -and !($r.jsonPath -like "*outputs*")) {
            Write-Host "Adding: $t, $($t.length)"
            $tagsArray += $r.Type
        }
    }
    
    $newTags = '`Tags: ' + $($tagsArray -join ", ") + '`' -replace "Tags:,", "Tags:" # empty tags seem to add an empty element at the beginning

    Write-Host "New Tags string:`n$newTags"

    # replace the current Tags in the file if any
    if ($currentTags -eq "") {
        # Add to the end of the file
        $readme = $readme += "$newTags" # if tags were not in the file then make sure we have line breaks
    }
    else {
        #replace
        $readme = $readme -replace $currentTags, $newTags
    }
        
    #Write-Output $readme
    $readme | Set-Content $readmePath -NoNewline

}


Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output '*****************************************************************************************'
Write-Output $readme
