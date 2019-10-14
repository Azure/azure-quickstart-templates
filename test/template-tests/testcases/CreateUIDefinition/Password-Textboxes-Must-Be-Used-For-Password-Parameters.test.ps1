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
    $stepName = $pwb.ParentObject[0].name
    $lookingFor= if ($stepName) { "*steps(*$stepName*).$controlName*"} else {"*basics(*$($controlName)*"} 
    $theOutput = foreach ($out in $CreateUIDefinitionObject.parameters.outputs.psobject.properties) {
        if ($out.Value -like $lookingFor) { 
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

    # If the main template parameter type is not a Secure String
    if ($MainTemplateParam.type -ne 'SecureString') {
        # write an error.
        Write-Error "Password boxes must be used for secure string parameters.  The Main template parameter $($pwb.Name) is a $($MainTemplateParam.type)" -TargetObject @($pwb, $MainTemplateParam)
    }
}