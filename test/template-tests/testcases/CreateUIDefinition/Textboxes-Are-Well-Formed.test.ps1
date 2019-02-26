param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)


$allTextBoxes = $CreateUiDefinitionObject | Find-AzureRMTemplate -Key type -value microsoft.commmon.textbox
foreach ($textbox in $allTextBoxes) {
    if (-not $textbox.constraints) {
        Write-Error "Textbox $($textbox.Name) is missing constraints"
    } else {
        if (-not $textbox.constraints.regex) {
            Write-Error "Textbox $($textbox.Name) is missing constraints.regex"
        }
        if (-not $textbox.constraints.validationMessage) {
            Write-Error "Textbox $($textbox.Name) is missing constraints.validationMessage"
        }
        if (-not $textbox.constraints.maxLength) {
            Write-Error "Textbox $($textbox.Name) is missing constraints.maxLength"
        }
    }    
}