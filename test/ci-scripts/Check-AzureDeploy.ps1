# this script looks for samples that have main.bicep but no azuredeploy.json
# for when CI fails to build it (or the pipeline fails to run)

$bicep = Get-ChildItem -Path "main.bicep" -Recurse

foreach($b in $bicep){
    $path = $b.FullName | Split-Path -Parent
    #Write-Host "Checking $($b.FullName)..."
    if(!(Test-Path "$path\azuredeploy.json")){
        if($($b.fullname) -notlike "*ci-tests*"){
            Write-Error "$($b.FullName) is missing azuredeploy.json"
        }
    }
}
