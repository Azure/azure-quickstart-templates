param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)


function findTextBoxes {
    param([Parameter(ValueFromPipelineByPropertyName=$true,Position=0)][PSObject]$value)
    process {
        if (-not $value) { return } 
        if ($value -is [string] -or $value -is [int] -or $value -is [bool] -or $value -is [double]) {
            return
        }
        
        if ($value.type -eq 'microsoft.common.textbox') {
            return $value
        }
        if ($value -is [Object[]]) {
            $value |
                & $findTextBoxes -value { $_ } 
        } else {
            $value.psobject.properties |
                findTextBoxes
        }
    
    }
} 

$allTextBoxes = findTextBoxes $CreateUIDefinitionObject
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
    }    
}


