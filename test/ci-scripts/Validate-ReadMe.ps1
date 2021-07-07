param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string] $SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string] $StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME,
    [string] $ReadMeFileName = "README.md",
    [string] $supportedEnvironmentsJson = $ENV:SUPPORTED_ENVIRONMENTS, # the minified json array from metadata.json
    [switch] $bicepSupported = ($ENV:BICEP_SUPPORTED -eq "true"),
    [switch] $Fix # If true, README will be fixed if possible
)

Write-Host "StorageAccountName: $StorageAccountName"
Write-Host "bicepSupported: $bicepSupported"

$s = $sampleName.Replace("\", "/")
$sEncoded = $sampleName.Replace("\", "%2F").Replace("/", "%2F")

$PublicLinkMarkDown = @(
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"
    "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$sEncoded%2Fazuredeploy.json"
)
$GovLinkMarkDown = @(
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true"
    "https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$sEncoded%2Fazuredeploy.json"
)
$ARMVizMarkDown = @(
    "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"
    "http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F$sEncoded%2Fazuredeploy.json"
)
# $BicepLogoLink = 
# "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/bicepLogoSmall.svg?sanitize=true"
$badgeLinks = @(
    "https://$StorageAccountName.blob.core.windows.net/badges/$s/PublicLastTestDate.svg",
    "https://$StorageAccountName.blob.core.windows.net/badges/$s/PublicDeployment.svg",
    "https://$StorageAccountName.blob.core.windows.net/badges/$s/FairfaxLastTestDate.svg",
    "https://$StorageAccountName.blob.core.windows.net/badges/$s/FairfaxDeployment.svg",
    "https://$StorageAccountName.blob.core.windows.net/badges/$s/BestPracticeResult.svg",
    "https://$StorageAccountName.blob.core.windows.net/badges/$s/CredScanResult.svg"
)
if ($bicepSupported) {
    $BadgeLinks += "https://$StorageAccountName.blob.core.windows.net/badges/$s/BicepVersion.svg"
}

# Determine which "Deploy to Azure" buttons we need for each cloud
$PublicLinks = @()
$PublicButton = $null
$GovLinks = @()
$GovButton = $null
# $BicepImage = $null

Write-Host "Supported Environments Found: $supportedEnvironmentsJson"
$supportedEnvironments = ($supportedEnvironmentsJson | ConvertFrom-JSON -AsHashTable)
#$supportedEnvironments | Out-string
#Write-Host $supportedEnvironments.GetType()

if ($supportedEnvironments.Contains("AzureCloud")) {
    $PublicLinks = $PublicLinkMarkDown
    $PublicButton = "[![Deploy To Azure]($($PublicLinks[0]))]($($PublicLinks[1]))"
}

if ($supportedEnvironments.Contains("AzureUSGovernment")) {
    $GovLinks = $GovLinkMarkDown
    $GovButton = "[![Deploy To Azure US Gov]($($GovLinks[0]))]($($GovLinks[1]))"
}

$ARMVizLinks = $ARMVizMarkDown
$ARMVizButton = "[![Visualize]($($ARMVizLinks[0]))]($($ARMVizLinks[1]))"

# Determine whether bicep logo should appear
# if ($bicepSupported) {
#     $BicepImage = "![Bicep Logo]($($BicepLogoLink))"   
# }

$links = $ARMVizLinks + $PublicLinks + $GovLinks

Write-Output "Testing file: $SampleFolder/$ReadMeFileName"

# Confirm the filename is README.md (with that exact casing)
$readmeFile = (Get-Item $SampleFolder).GetFiles($ReadMeFileName)
if ($readmeFile.Name -cne 'README.md') {
    Write-Error "Readme file must be named README.md (with that exact casing)."
}

$readmePath = "$SampleFolder/$ReadMeFileName"
$readme = Get-Content $readmePath -Raw

$badgesError = $false

function Note-FixableError([string] $error) {
    if ($Fix) {
        Write-Warning  $error
        Write-Warning "Fix will be attempted"
    }
    else {
        $helpMessage = @"
`n**** SEE BELOW FOR EXPECTED MARKUP TO COPY AND PASTE INTO THE README ****
"Pass in -Fix flag to attempt fix"
"@
        Write-Error "$error`n$helpMessage"
    }

    $script:badgesError = $true
}

# EXPECTED: header on first line
if (-not ($readme.StartsWith("# "))) {
    Write-Error "Readme must start with # header, not: $($readme[0])"
}

#proper src attribute for badges
foreach ($badge in $badgeLinks) {
    if (-not ($readme -clike "*$badge*")) {        
        Note-FixableError "Readme is missing badge: $badge"
    }
}

#Proper href and src attribute for buttons
foreach ($link in $links) {
    #Write-Host $link
    if (-not ($readme -clike "*$link*")) {
        Note-FixableError "Readme must have a button with the link: $link"
    }
}

#Proper bicep logo image
# if ($bicepSupported) {
#     if (-not ($readme.Contains($BicepImage))) {
#         Note-FixableError "Readme must have the following image markdown: $BicepImage"
#     }
# }

#Now make sure the readme does not contain buttons for unsupported clouds/features - search the readme case insensitively
if (!$supportedEnvironments.Contains("AzureUSGovernment") -and $readme -like "*$($GovLinkMarkDown[1])*") {
    Note-FixableError "Readme contains link to $($GovLinkMarkDown[1]) but sample is not supported in AzureUSGovernment"
}
if (!$supportedEnvironments.Contains("AzureCloud") -and $readme -like "*$($PublicLinkMarkDown[1])*") {
    Note-FixableError "Readme contains link to $($PublicLinkMarkDown[1]) but sample is not supported in AzureCloud"
}
# if (!$bicepSupported -and $readme -like "*$($BicepLogoLink)*") {
#     Note-FixableError "Readme contains link to $($BicepLogoLink) but sample does not include a bicep template"
# }

if ( $badgesError ) {
  
    if ($bicepSupported) {
        $bicepBadge = "`n![Bicep Version]($($BadgeLinks[6]))`n"
    }

    # Create a string with what the metadata should look like
    $md = @"
![Azure Public Test Date]($($BadgeLinks[0]))
![Azure Public Test Result]($($BadgeLinks[1]))

![Azure US Gov Last Test Date]($($BadgeLinks[2]))
![Azure US Gov Last Test Result]($($BadgeLinks[3]))

![Best Practice Check]($($BadgeLinks[4]))
![Cred Scan Check]($($BadgeLinks[5]))
$bicepBadge
$PublicButton
$GovButton
$ARMVizButton   
"@

    if ($Fix) {
        $fixed = & $PSScriptRoot/Get-FixedReadMe.ps1 `
            -ReadmeContents $readme `
            -ExpectedMarkdown $md

        # Back up existing
        $backup = New-TemporaryFile
        mv $readmePath $backup

        # Write new readme
        Set-Content $readmePath $fixed

        Write-Warning "***************************************************************************************"
        Write-Warning "Fixes have been made to $readmePath"
        Write-Warning "Previous file was written to $backup"
        Write-Warning "***************************************************************************************"
        Write-Host "##vso[task.setvariable variable=fixed.readme]TRUE"
    }
    else {
        Write-Host ""
        Write-Host "***************************************************************************************"
        Write-Host "Copy and paste the following markdown to the README just under the top line's heading:"
        Write-Host "***************************************************************************************"
        Write-Host $md
        Write-Host ""
        Write-Host "***************************************************************************************"
        Write-Host "End of copy and paste for README"
        Write-Host "***************************************************************************************"
        Write-Host ""
    }
}

# pipeline variable should default to FAIL
Write-Host "Count: $($error.count)"
if ($error.count -eq 0) {
    Write-Host "##vso[task.setvariable variable=result.readme]PASS"
}
