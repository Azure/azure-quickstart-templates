$MyFile= $MyInvocation.MyCommand.ScriptBlock.File  
$myName = $MyFile | Split-Path -Leaf 
$myName = $myName -replace '\.init\.cache\.ps1'
$myRoot = $MyFile | Split-Path
$MyOutputFile = Join-Path $myRoot "$myName.cache.json"


$images = az vm image list --all -o json  | ConvertFrom-Json
if (-not $images) {
    Write-Error "Could not list providers.  You may not be logged in."
    return
}

$images | ConvertTo-Json -Depth 10 -Compress  | Set-Content $MyOutputFile 
