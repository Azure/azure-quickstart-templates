param(
  [bool] $myBool,
  [int] $myInt,
  [string] $myString,
  [Object[]]$myArray,
  [Object]$myObject
)

Write-Output "myBool: $myBool"
Write-Output "myInt: $myInt"
Write-Output "myString: $myString"
Write-Output "myArray: $myArray"
Write-Output "myObject: $myObject"

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['myBool'] = $myBool
$DeploymentScriptOutputs['myInt'] = $myInt
$DeploymentScriptOutputs['myString'] = $myString
$DeploymentScriptOutputs['myArray'] = $myArray
$DeploymentScriptOutputs['myObject'] = $myObject