param(
    [string]$SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string]$SampleName = $ENV:SAMPLE_NAME,  # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string] $ReadMeFileName = "README.md"
)

<#
TODO linting - is there a pipeline tool for this ?
#>

$badges = @(
    "https://azurequickstartsservice.blob.core.windows.net/badges/#sampleName#/PublicLastTestDate.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/#sampleName#/PublicDeployment.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/#sampleName#/FairfaxLastTestDate.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/#sampleName#/FairfaxDeployment.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/#sampleName#/BestPracticeResult.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/#sampleName#/CredScanResult.svg"
)

$buttons = @(
    "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F#sampleName#%2Fazuredeploy.json"
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"
    "http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F#sampleName#%2Fazuredeploy.json"
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"
)

    Write-Output "Testing file: $SampleFolder/$ReadMeFileName"
    $readme = Get-Content "$SampleFolder/$ReadMeFileName" -Raw

    # header on first line
    if(-not ($readme.StartsWith("# "))){
        Write-Error "Readme must start with # header, not: $($readme[0])"
    }

    #proper src attribute for badges
    foreach($badge in $badges){
        $searchString = $badge.Replace("#sampleName#", $sampleName.Replace("\", "/")) #change \ to / due to windows path to url
        if(-not ($readme -like "*$searchString*")){
            Write-Error "Readme is missing badge: $searchString"
        }
    }

    #Proper href and src attribute for buttons
    foreach($button in $buttons){
        $searchString = $button.Replace("#sampleName#", $sampleName.Replace("\", "/")) #change \ to / due to windows path to url
        if(-not ($readme -like "*$searchString*")){
            Write-Error "Readme button incorrect HREF or SRC attribute: $searchString"
        }
    }
