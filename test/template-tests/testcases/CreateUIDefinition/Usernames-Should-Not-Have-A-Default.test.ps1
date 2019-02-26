param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject
)

$userNameTextBoxes =
    $CreateUIDefinitionObject | 
        Find-AzureRMTemplate -Key type -Value Microsoft.Compute.UserNameTextBox

foreach ($tb in $userNameTextBoxes) {
    if ($tb.defaultValue) {
        Write-Error "Username textbox $($tb.Name) should not have a default value" -TargetObject $tb
    }
}