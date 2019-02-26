param(
[Parameter(Mandatory=$true,Position=0)]
$MainTemplateObject
)

$ids = $MainTemplateObject  | Find-AzureRMTemplate -Key id -Value * -Like 

foreach ($id in $ids) {
    $myId = "$($id.id)".Trim()
    if ($myId -notmatch '\[resourceId\(') {
        Write-Error "Identifier appears hardcoded: $($id.id)" -TargetObject $id 
    }
}