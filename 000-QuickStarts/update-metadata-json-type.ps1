
$searchString = '"$schema": "https://aka.ms/azure-quickstart-templates-metadata-schema#",'
$replaceString = @'
"$schema": "https://aka.ms/azure-quickstart-templates-metadata-schema#",
  "type": "QuickStart",
'@


#$ArtifactFilePaths = Get-ChildItem .\*.json -Recurse -File | ForEach-Object -Process {$_.FullName}
$ArtifactFilePaths = Get-ChildItem .\metadata.json -Recurse -File | ForEach-Object -Process {$_.FullName}
foreach ($SourcePath in $ArtifactFilePaths) {
    
    write-host $SourcePath

    if ($SourcePath -like "*\test\*"){
        Write-host "Skipping..."
        continue
    }

    $Json = Get-Content $SourcePath -Raw #| ConvertFrom-Json

    if ($json -like '*"type":*'){
       Write-Host "$sourcePath - Already has type property..."
    }
    Else {

        $json = $json.replace($searchString, $replaceString)
    #replace

    }

    write-host $json
    write-host '---'
    $json | Set-Content $SourcePath 
}
