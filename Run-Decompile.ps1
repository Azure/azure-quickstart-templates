[CmdletBinding()]
param (
    #$bicep = "..\bicep\src\Bicep.Cli\Bin\Debug\net6.0\bicep.exe"
    $bicep = "bicep",
    $bicepArgs = "decompile"
)

Get-ChildItem "*azuredeploy.json" -Recurse | ForEach-Object { 
    $fn = $_.FullName
    Write-Host $fn
    & $bicep $bicepArgs $fn --force *> a.out
    cat a.out >> .\log.txt
    echo "" >> .\log.txt
    del a.out
}
