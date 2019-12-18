param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true)]
[Collections.IDictionary]
$MainTemplateParameters
)

# First, find all password boxes.
$passwordBoxes = $CreateUIDefinitionObject | 
    Find-JsonContent -Key type -Value Microsoft.Common.PasswordBox
    
foreach ($pwb in $passwordBoxes) { # Loop over each password box
    $controlName = $pwb.Name # and find the output it maps to.
    $theOutput = foreach ($out in $CreateUIDefinitionObject.parameters.outputs.psobject.properties) {
        if (($out.Value -like "*steps(*$controlName*") -or ($out.Value -like "*basics(*$controlName*")) { 
            $out; break
        }
    }

    if (-not $theOutput) { # If we couldn't find the output,
        Write-Error "Could not find $($pwb.Name) in outputs" -TargetObject $pwb # write and error
        continue # and move onto the next
    }

    $MainTemplateParam = $MainTemplateParameters[$theOutput.Name] # Find it in the main template.

    # If we couldn't find it, write an error.
    if (-not $MainTemplateParam) {
        Write-Error "Password box $($pwb.Name) is missing from main template parameters "-TargetObject $pwb
        continue
    }

    # If the main template parameter type is neither a Secure String nor a Secure Object
    if (($MainTemplateParam.type -ne 'SecureString') -and ($MainTemplateParam.type -ne 'SecureObject')) {
        # write an error.
        Write-Error "PasswordBox controls must use secureString or secureObject parameter types.  The Main template parameter '$($pwb.Name)' is a '$($MainTemplateParam.type)'" -TargetObject @($pwb, $MainTemplateParam)
    }
}