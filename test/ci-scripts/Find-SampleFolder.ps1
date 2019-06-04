param (
    [Parameter(Mandatory = $true)][string]$folder
)

$files = Get-ChildItem -Path $folder -Recurse

foreach($file in $files){

    #Write-Host $file.fullname

    if(($file.name -eq 'azuredeploy.json') -or ($file.name -eq 'mainTemplate.json')){
        Write-Host "Bingo!" 
        Write-Host $file.fullname
        Write-Host $file.Directory  
        exit
        #(Get-ChildItem).
       }
}