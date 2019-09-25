param(
    [string][Parameter(Mandatory = $true)]$SampleFolder, #this is the path to the sample, relative to BuildSourcesDirectory
    [string][Parameter(Mandatory = $true)]$BuildSourcesDirectory, #this is the path to the root of the repo on disk
    [string] $ReadMeFileName = "README.md"
)

$SampleFolder = $SampleFolder.TrimEnd("/").TrimEnd("\")
$BuildSourcesDirectory = $BuildSourcesDirectory.TrimEnd("/").TrimEnd("\")

<#
TODO linting - is there a pipeline tool for this ?
#>

$badges = @(
    "https://azbotstorage.blob.core.windows.net/badges/#sampleFolder#/PublicLastTestDate.svg",
    "https://azbotstorage.blob.core.windows.net/badges/#sampleFolder#/PublicDeployment.svg",
    "https://azbotstorage.blob.core.windows.net/badges/#sampleFolder#/FairfaxLastTestDate.svg",
    "https://azbotstorage.blob.core.windows.net/badges/#sampleFolder#/FairfaxDeployment.svg",
    "https://azbotstorage.blob.core.windows.net/badges/#sampleFolder#/BestPracticeResult.svg",
    "https://azbotstorage.blob.core.windows.net/badges/#sampleFolder#/CredScanResult.svg"
)

$buttons = @(
    "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F#sampleFolder#%2Fazuredeploy.json"
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"
    "http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F#sampleFolder#%2Fazuredeploy.json"
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"
)

    $readme = Get-Content "$BuildSourcesDirectory/$SampleFolder/$ReadMeFileName" -Raw

    # header on first line
    if(-not ($readme.StartsWith("# "))){
        Write-Error "Readme must start with # header, not: $($readme[0])"
    }

    #proper src attribute for badges
    foreach($badge in $badges){
        $searchString = $badge.Replace("#sampleFolder#", $sampleFolder.Replace("\", "/"))
        if(-not ($readme -like "*$searchString*")){
            Write-Error "Readme is missing badge: $searchString"
        }
    }

    #Proper href and src attribute for buttons
    foreach($button in $buttons){
        $searchString = $button.Replace("#sampleFolder#", $sampleFolder.Replace("\", "/"))
        if(-not ($readme -like "*$searchString*")){
            Write-Error "Readme button incorrect HREF or SRC attribute: $searchString"
        }
    }
