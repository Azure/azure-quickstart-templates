$MyFile= $MyInvocation.MyCommand.ScriptBlock.File  
$myName = $MyFile | Split-Path -Leaf 
$myName = $myName -replace '\.init\.cache\.ps1'
$myRoot = $MyFile | Split-Path
$MyOutputFile = Join-Path $myRoot "$myName.cache.json"


$azEnv = Get-AzureRmEnvironment
if (-not $azEnv) {
    Write-Error "Could not list providers.  You may not be logged in."
    return
}

$azEnv | ConvertTo-Json -Depth 10 -Compress  | Set-Content $MyOutputFile 
