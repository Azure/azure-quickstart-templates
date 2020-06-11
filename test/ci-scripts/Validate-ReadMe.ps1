param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string] $SampleName = $ENV:SAMPLE_NAME,  # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string] $ReadMeFileName = "README.md",
    [string] $supportedEnvironmentsJson = $ENV:SUPPORTED_ENVIRONMENTS # the minified json array from metadata.json
)

$ErrorView = "NormalView" # this is working around a bug in Azure DevOps with PS Core and inline scripts https://github.com/microsoft/azure-pipelines-agent/issues/2853

<#
TODO linting - is there a pipeline tool for this ?
#>

$s = $sampleName.Replace("\", "/")
$sEncoded = $sampleName.Replace("\", "%2F")

$PublicLinkMarkDown=@(
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"
    "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$sEncoded%2Fazuredeploy.json"
)
$GovLinkMarkDown=@(
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true"
    "https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$sEncoded%2Fazuredeploy.json"
)
$ARMVizMarkDown=@(
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"
    "http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$sEncoded%2Fazuredeploy.json"
)
$badgeLinks = @(
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/PublicLastTestDate.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/PublicDeployment.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/FairfaxLastTestDate.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/FairfaxDeployment.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/BestPracticeResult.svg",
    "https://azurequickstartsservice.blob.core.windows.net/badges/$s/CredScanResult.svg"
)

# Determine which "Deploy to Azure" buttons we need for each cloud
$PublicLinks = @()
$PublicButton = $null
$GovLinks = @()
$GovButton = $null

Write-Host "Supported Environments Found: $supportedEnvironmentsJson"
$supportedEnvironments = ($supportedEnvironmentsJson | ConvertFrom-JSON -AsHashTable)
#$supportedEnvironments | Out-string
#Write-Host $supportedEnvironments.GetType()

if($supportedEnvironments.Contains("AzureCloud")){
    $PublicLinks = $PublicLinkMarkDown
    $PublicButton = "[![Deploy To Azure]($($PublicLinks[0]))]($($PublicLinks[1]))"
}

if($supportedEnvironments.Contains("AzureUSGovernment")){
    $GovLinks = $GovLinkMarkDown
    $GovButton = "[![Deploy To Azure US Gov]($($GovLinks[0]))]($($GovLinks[1]))"
}

$ARMVizLinks = $ARMVizMarkDown
$ARMVizButton = "[![Visualize]($($ARMVizLinks[0]))]($($ARMVizLinks[1]))"

$links = $ARMVizLinks + $PublicLinks + $GovLinks


Write-Output "Testing file: $SampleFolder/$ReadMeFileName"
$readme = Get-Content "$SampleFolder/$ReadMeFileName" -Raw

$dumpHelp = $false
# header on first line
if(-not ($readme.StartsWith("# "))){
    Write-Error "Readme must start with # header, not: $($readme[0])"
}

#proper src attribute for badges
foreach($badge in $badgeLinks){
    if(-not ($readme -clike "*$badge*")){
        $dumpHelp = $true
        Write-Error "Readme is missing badge: $badge"
    }
}

#Proper href and src attribute for buttons
foreach($link in $links){
        #Write-Host $link
    if(-not ($readme -clike "*$link*")){
        $dumpHelp = $true
        Write-Error "Readme must have a button with the link: $link"
    }
}

#Now make sure the readme does not contain buttons for unsupported clouds - search the readme case insensitively
if(!$supportedEnvironments.Contains("AzureUSGovernment") -and $readme -like "*$($GovLinkMarkDown[1])*"){
    $dumpHelp = $true
    Write-Error "$($GovLinkMarkDown[1])"
    Write-Error "Readme contains link to $($GovLinkMarkDown[1]) and sample is not supported in AzureUSGovernment"
}
if(!$supportedEnvironments.Contains("AzureCloud") -and $readme -like "*$($PublicLinkMarkDown[1])*"){
    $dumpHelp = $true
    Write-Error "Readme contains link to $($PublicLinkMarkDown[1]) and sample is not supported in AzureCloud"
}

if( $dumpHelp ){
    
    $md = @"

![Azure Public Test Date]($($BadgeLinks[0]))
![Azure Public Test Result]($($BadgeLinks[1]))

![Azure US Gov Last Test Date]($($BadgeLinks[2]))
![Azure US Gov Last Test Result]($($BadgeLinks[3]))

![Best Practice Check]($($BadgeLinks[4]))
![Cred Scan Check]($($BadgeLinks[5]))

$PublicButton
$GovButton
$ARMVizButton    
"@

    Write-Output "Ensure the following markdown is at the top of the README under the heading:`n"
    Write-Output $md

}
