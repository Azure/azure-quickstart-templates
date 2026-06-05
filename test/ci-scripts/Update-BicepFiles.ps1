$bicepSamples = Get-ChildItem -Path main.bicep -Recurse

ForEach($s in $bicepSamples){
    # skip files in the test folder
    if($s.FullName -notlike "*\azure-quickstart-templates\test\*"){
        bicep build $s.FullName --outfile "$($s.DirectoryName)/azuredeploy.json"
    }
}
