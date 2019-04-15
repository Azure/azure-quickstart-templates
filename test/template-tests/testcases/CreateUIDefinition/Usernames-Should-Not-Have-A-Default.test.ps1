param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject
)

# First, find al user name text boxes.
$userNameTextBoxes =
    $CreateUIDefinitionObject | 
        Find-JsonContent -Key type -Value Microsoft.Compute.UserNameTextBox

foreach ($tb in $userNameTextBoxes) { # Then walk thru each text box, 
    if ($tb.defaultValue) { # if it contained a default value,
        # write an error.
        Write-Error "Username textbox $($tb.Name) should not have a default value" -TargetObject $tb
    }
}