param(
[Parameter(Mandatory=$true,Position=0)]
[string]
$TemplateObject
)

$resourcesJson = $TemplateObject.resources  | ConvertTo-Json -Depth 10  

if ($resourcesJson -match 'ManagedIdentityExtension') {
    Write-Error "Managed Identity Extension must not be used" -ErrorId ManagedIdentityExtension.Was.Used
}