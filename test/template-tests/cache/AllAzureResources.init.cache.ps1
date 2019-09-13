$MyFile= $MyInvocation.MyCommand.ScriptBlock.File  
$myName = $MyFile | Split-Path -Leaf 
$myName = $myName -replace '\.init\.cache\.ps1'
$myRoot = $MyFile | Split-Path
$MyOutputFile = Join-Path $myRoot "$myName.cache.json"


$providers = az provider list -o json | ConvertFrom-Json
if (-not $providers) {
    Write-Error "Could not list providers.  You may not be logged in."
    return
}

$allResources =foreach ($provider in $providers) {
    $provider.psobject.properties.remove('ID')
    $provider.psobject.properties.remove('RegistrationState')
    $provider.psobject.properties.remove('Authorizations')

    foreach ($resourceInfo in $provider.resourceTypes) {
        $resourceInfo.ResourceType = "$($provider.namespace)/$($resourceInfo.ResourceType)"
        $resourceInfo
    }
}

$allResourcesByType = $allResources | Group-Object ResourceType -AsHashTable
$allResourcesByType | ConvertTo-Json -Depth 10 -Compress  | Set-Content $MyOutputFile 
