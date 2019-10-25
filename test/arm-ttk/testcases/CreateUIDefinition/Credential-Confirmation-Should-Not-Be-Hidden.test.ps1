param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject
)

# First, find all password boxes.
$passwordBoxes = $CreateUIDefinitionObject | 
    Find-JsonContent -Key type -Value Microsoft.Common.PasswordBox
 
# Then find all CredentialsCombos.
$credentialComboBoxes = $CreateUIDefinitionObject | 
    Find-JsonContent -Key type -Value Microsoft.Compute.CredentialsCombo

# Put them together into one list.
$allCredentialBoxes =  @() + $passwordBoxes + $credentialComboBoxes


foreach ($credBox in $allCredentialBoxes) { # Walk thru the list 
   
    if ($credBox.options.hideConfirmation -eq $true) { # If the options has hideConfirmation set to true
        # write an error
        Write-Error "`"hideConfirmation`" must not be true for credentials" -TargetObject $credBox -ErrorId Confirmation.Should.Not.Be.Hidden
    }
}
 
