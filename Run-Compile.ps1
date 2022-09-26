[CmdletBinding()]
param (
    #$bicep = "..\bicep\src\Bicep.Cli\Bin\Debug\net6.0\bicep.exe"
    $bicep = "call az bicep"
)

Get-ChildItem "*.bicep" -Recurse | ForEach-Object { 
    $fn = $_.FullName
    "echo $fn >> c.out"
    "$bicep build -f $fn 2>> c.out"
    #. $bicep build $fn
}
