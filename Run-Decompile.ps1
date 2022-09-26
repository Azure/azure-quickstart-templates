[CmdletBinding()]
param (
    #$bicep = "..\bicep\src\Bicep.Cli\Bin\Debug\net6.0\bicep.exe"
    $bicep = "bicep",
    $bicepArgs = "decompile"
)

Get-ChildItem "*.bicep" -Recurse | ForEach-Object { 
    $fn = $_.FullName
    Write-Host $fn
    & $bicep $bicepArgs $fn 2>> c.out
}
