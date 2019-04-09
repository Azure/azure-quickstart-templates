param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true)]
[Collections.IDictionary]
$MainTemplateParameters
)

# Find any item property in CreateUIDefinition that uses allowedValues
$allowedValues = $CreateUIDefinitionObject | 
    Find-JsonContent -Key allowedValues -Value * -Like

foreach ($av in $allowedValues) { # Walk thru each thing we find.
    
    # First we need to find the control's associated output.
    $parent = $av.ParentObject[0] 
    $controlName = $parent.Name 
    $stepName = $av.ParentObject[1].name # If the grandparent object has a name field, we're in steps
    $lookingFor= if ($stepName) { "*steps(*$stepName*).$controlName*"} else {"*basics(*$($controlName)*"} 
    $theOutput = foreach ($out in $CreateUIDefinitionObject.parameters.outputs.psobject.properties) {
        if ($out.Value -like $lookingFor) { 
            $out; break
        }
    }

    # If we couldn't find the step, 
    if (-not $theOutput) {
        # write an error and move onto the next item.
        Write-Error "Could not find $($parent.Name) in outputs" -TargetObject $parent
        continue
    }


    $MainTemplateParam = $MainTemplateParameters[$theOutput.Name] 

    # If it didn't exist in the mainTemplate
    if (-not $MainTemplateParam) {
        # write an error and move onto the next item
        Write-Error "CreateUIDefinition has parameter $($parent.Name), but it is missing from main template parameters "-TargetObject $parent
        continue
    }

    # Now create a list of all allowed values
    $reallyAllowedValues = @(foreach ($v in $av.allowedValues) {
        if ($v.value) { # they can either be in a 'value' property
            $v.value
        } else { # or just there as a string
            $v
        }
    })

    if ($MainTemplateParam.defaultValue -and # If the main template has a default value
        $reallyAllowedValues -notcontains $MainTemplateParam.defaultValue) { # and the allowedValues list doesn't contain it
        # then write an error.
        Write-Error "CreateUIDefinition paremter $($parent.Name) does not allow for the default value $($MainTemplateParam.defaultValue) used in the main template" 
    }
}
