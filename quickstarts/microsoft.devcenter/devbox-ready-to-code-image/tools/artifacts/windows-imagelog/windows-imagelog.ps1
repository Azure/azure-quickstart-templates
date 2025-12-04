<#
.DESCRIPTION
     Gathers various image build details and writes them to a .json file in the .tool directory and a customer .txt version to the desktop (useful for for image customizations troubleshooting).
.PARAMETER BicepInfo
    String of parameter details from Bicep in base64 string format.
.PARAMETER UsefulTagsList
    List of tags to include in the report.
.EXAMPLE
    Sample Bicep snippet for using the artifact:

    {
      name: 'windows-imagelog'
      parameters: {
        BicepInfo: base64(string(allParamsForLogging))
      }
    }
#>

param(
    [Parameter(Mandatory = $true)][String] $BicepInfo,
    [Parameter(Mandatory = $false)][String] $UsefulTagsList = "correlationId,createdBy,imageTemplateName,imageTemplateResourceGroupName"
)

function Add-VarForLogging ($varName, $varValue) {
    <#
  .DESCRIPTION
  Add a row to the logging array but only if the value is not null or whitespace, or if an object then count is gt 0.
  .PARAMETER varName
  Name of the variable  
  .PARAMETER varValue
  Value of the variable
  #>

    if ((!([string]::IsNullOrWhiteSpace($varValue))) -or $varValue.Count -gt 0) {
        $global:varLogArray | Add-Member -MemberType NoteProperty -Name $varName -Value $varValue
    }
}

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Write-Host "Starting log file write to desktop and DRI report location"

# Set variables
$global:varLogArray = New-Object -TypeName "PSCustomObject"
$newLine = [Environment]::NewLine
$logBreak = $newLine + '=============================================================================' + $newLine
$currentTime = Get-Date
$usefulTags = $UsefulTagsList.Split(",")
$imageInfoJsonDir = "C:\.tools\Setup"
$imageInfoJsonFile = "$imageInfoJsonDir\ImageInfo.json"
$imageInfoTextFile = [Environment]::GetFolderPath('CommonDesktopDirectory') + "\ImageBuildReport.txt"
$repoLogFilePath = 'c:\.tools\RepoLogs'
$reportHeader = "Image Build Report at " + $currentTime.ToUniversalTime() + $newLine + "More details can be found at $imageInfoJsonFile"

try {
    # Create JSON log file location
    mkdir "$imageInfoJsonDir" -Force

    # Build json data to be output to file
    Write-Host "Building " $imageInfoJsonFile
    $bicepData = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($BicepInfo)) | ConvertFrom-Json
    Add-VarForLogging -varName "BicepParameters" -varValue $bicepData

    Write-Host "Calling compute API to get image tags."
    $vmTags = (Invoke-RestMethod -Headers @{"Metadata" = "true" } -Uri "http://169.254.169.254/metadata/instance/compute?api-version=2021-02-01").tags
    Write-Host "VM Tags : " $vmTags
    Write-Host "Process image tags."
    $vmTagsList = $vmTags.Split(";")
    $tagOut = New-Object -TypeName "PSCustomObject"
    foreach ($tag in $vmTagsList) {
        if (($tag.Split(":", 2))[0] -in $usefulTags) {
            $tagOut | Add-Member -MemberType NoteProperty -Name ($tag.Split(":", 2))[0] -Value ($tag.Split(":", 2))[1]
        }
    }
    Add-VarForLogging -varName "VMTags" -varValue $tagOut

    # Get Repo data
    $repoOut = @()
    $repoFiles = Get-ChildItem -File $repoLogFilePath -Recurse -Include "*.json"  -ErrorAction SilentlyContinue
    foreach ($row in $repoFiles) {
        $repoData = get-content -Path $row.FullName | ConvertFrom-Json
        $repoData | Add-Member -MemberType NoteProperty -Name "RepoName" -Value $row.BaseName
        $repoOut += $repoData 
    }
    Add-VarForLogging -varName "Repos" -varValue $repoOut

    # Write JSON file
    Write-Host "Write json output file to " $imageInfoJsonFile
    $global:varLogArray | ConvertTo-Json -Depth 10 | Out-File -FilePath $imageInfoJsonFile
    Get-Content $imageInfoJsonFile

    # Build and write customer image info text file
    Write-Host "Write text output file to " $imageInfoTextFile
    $repoDetail = ""
    $tagsDetail = ""
    if ([bool]($global:varLogArray.PSobject.Properties.name -match "Repos")) {
        $repoDetail = $global:varLogArray.Repos | ConvertTo-Json
    }
    if ([bool]($global:varLogArray.PSobject.Properties.name -match "VMTags")) {
        $tagsDetail = $global:varLogArray.VMTags 
    }
    $reportHeader, $logBreak, "Bicep Parameters : ", $($global:varLogArray.BicepParameters | ConvertTo-Json -Depth 10), $logBreak, "VM Image Tags : ", $tagsDetail, $logBreak, "Repos : ", $repoDetail | Out-File -FilePath $imageInfoTextFile
    Get-Content $imageInfoTextFile

    Write-Host "Delete RepoLog directory now that it is no longer needed."
    Remove-Item $repoLogFilePath -Recurse -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}