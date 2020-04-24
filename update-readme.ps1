
#$searchString = '"$schema": "https://aka.ms/azure-quickstart-templates-metadata-schema#",'
$badges = @(
'<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/PublicLastTestDate.svg" />&nbsp;',
'<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/PublicDeployment.svg" />&nbsp;',
'<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/FairfaxLastTestDate.svg" />&nbsp;',
'<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/FairfaxDeployment.svg" />&nbsp;',
'<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/BestPracticeResult.svg" />&nbsp;',
'<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/CredScanResult.svg" />&nbsp;',
'<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F%sampleFolder%%2Fazuredeploy.json" target="_blank">',
'<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>',
"</a>",
'<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F%sampleFolder%%2Fazuredeploy.json" target="_blank">',
'<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>',
"</a>"
)

$newBadges = @(
'![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/PublicLastTestDate.svg)',
'![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/PublicDeployment.svg)',
'![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/FairfaxLastTestDate.svg)',
'![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/FairfaxDeployment.svg)',
'![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/BestPracticeResult.svg)',
'![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/%sampleFolder%/CredScanResult.svg)',
'[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)]("https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F%sampleFolder%%2Fazuredeploy.json")  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)]("http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F%sampleFolder%%2Fazuredeploy.json")',
'',
'',
'',
'',
''
)

$readmeFileName = "README.md"
$skippedFiles = ""

#$ArtifactFilePaths = Get-ChildItem .\*.json -Recurse -File | ForEach-Object -Process {$_.FullName}
$ArtifactFilePaths = Get-ChildItem .\$readmeFileName -Recurse -File | ForEach-Object -Process { $_.FullName }
Write-Host $ArtifactFilePaths.Length
foreach ($SourcePath in $ArtifactFilePaths) {
    
    write-host $SourcePath

    if ($SourcePath -like "*\test\*" -or 
        $SourcePath -like "*\1-contribution-guide\*" -or 
        $SourcePath -like "*\.github\*") {
            Write-host "Skipping..."
            continue        
    }

    $readme = Get-Content $SourcePath 

    if ($readme -like '*![Azure Public Test Date]*') {
        Write-Warning "$sourcePath - Already has MD badges..."
    }
    else {
        #$sampleFolder = Split-Path $SourcePath | Split-Path -Leaf #Get the parent folder
        $sampleFolder = $SourcePath.Replace("$PSScriptRoot\", '').Replace("\README.md", '').Replace('\','/')
        
        #$replaceString = $badges.Replace("%sampleFolder%", $sampleFolder)

        #$searchString = ""
        #Write-Host $searchString
        #Write-Host $replaceString

        foreach($b in $badges){
            $i = $badges.IndexOf($b)
            $searchString = $b.Replace("%sampleFolder%", $sampleFolder)
            #Write-Host "$i : $searchString"
            $replaceString = $newBadges[$i].Replace("%sampleFolder%", $sampleFolder)
            #Write-Host $replaceString
            $readme = $readme.Replace($searchString, $replaceString)

        }

        
            #$readme | Out-String
            write-host '-----'
            $readme | Set-Content $SourcePath  
    }
}

$skippedFiles | Set-Content -Path ".\skipped.txt"
