param(
[Parameter(Mandatory=$true,Position=0)]
[string]
$TemplateText
)
if ($templateText -match 'managedidentityextension') {
    Write-Error "Managed Identity Extension must not be used" -ErrorId ManagedIdentityExtension.Was.Used
}



