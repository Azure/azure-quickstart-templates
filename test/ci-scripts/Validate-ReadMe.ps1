param(
    [string]$SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string]$SampleName = $ENV:SAMPLE_NAME,  # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string] $ReadMeFileName = "README.md"
)

$ErrorView = "NormalView" # this is working around a bug in Azure DevOps with PS Core and inline scripts https://github.com/microsoft/azure-pipelines-agent/issues/2853

<#
TODO linting - is there a pipeline tool for this ?
#>

$s = $sampleName.Replace("\", "/")

$badges = @(
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/PublicLastTestDate.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/PublicDeployment.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/FairfaxLastTestDate.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/FairfaxDeployment.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/BestPracticeResult.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/CredScanResult.svg"
)
#$badges.Replace("#sampleName#", $sampleName.Replace("\", "/"))

$buttons = @(
    "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$s%2Fazuredeploy.json"
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"
    "http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$s%2Fazuredeploy.json"
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"
)
#$buttons.Replace("#sampleName#", $sampleName.Replace("\", "/"))

Write-Output "Testing file: $SampleFolder/$ReadMeFileName"
$readme = Get-Content "$SampleFolder/$ReadMeFileName" -Raw

$dumpHelp = $false
# header on first line
if(-not ($readme.StartsWith("# "))){
    Write-Error "Readme must start with # header, not: $($readme[0])"
}

#proper src attribute for badges
foreach($badge in $badges){
    if(-not ($readme -clike "*$badge*")){
        $dumpHelp = $true
        Write-Error "Readme is missing badge: $badge"
    }
}

#Proper href and src attribute for buttons
foreach($button in $buttons){
    if(-not ($readme -clike "*$button*")){
        $dumpHelp = $true
        Write-Error "Readme button incorrect HREF or SRC attribute: $button"
    }
}

if( $dumpHelp ){
    $md = @"

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/$s/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/$s/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/$s/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/$s/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/$s/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/$s/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)]("https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$s%2Fazuredeploy.json")
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]("https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$s%2Fazuredeploy.json")
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)]("http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$s%2Fazuredeploy.json")
    
"@

    Write-Output "Ensure the following markdown is at the top of the README under the heading:`n"
    Write-Output $md

}
