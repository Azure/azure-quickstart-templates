param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)

<#
This test should flag using runtime functions that list secrets or secure parameters in the outputs

    "sample-output": {
      "type": "string",
      "value": "[listKeys(parameters('storageAccountName'),'2017-10-01').keys[0].value]"
    }
    "sample-output-secure-param": {
      "type": "string",
      "value": "[concat('connectstring stuff', parameters('adminPassword'))]"
    }

#>

#look at each output value property
foreach ($output in $TemplateObject.outputs.psobject.properties) {

    $outputText = $output | ConvertTo-Json # search the entire output object to cover output copy scenarios

<#    regex:
      TODO - any number of non-alphanumeric chars (comma, space, paren, etc) (this ensures it's the start of a list* function and not a UDF with the name "list")
      DONE - literal match of "list"
      DONE - any number of alpha-numerica chars followed by 0 or more whitepace
      DONE - literal match of open paren "("
#>
    if ($outputText -match "\[.*?list\w+\s*\(") { 
        Write-Error -Message "Output contains secret: $($output.Name)" -ErrorId Output.Contains.Secret -TargetObject $output
    }

}
 

# find all secureString and secureObject parameters
foreach ($parameterProp in $templateObject.parameters.psobject.properties) {
    $parameter = $parameterProp.Value
    $name = $parameterProp.Name
    
    # If the parameter is a secureString or secureObject it shouldn't be in the outputs:
    if ($parameter.Type -eq 'securestring' -or $parameterProp.Type -eq 'secureobject') { 
        
        foreach ($output in $TemplateObject.outputs.psobject.properties) {

            $outputText = $output | ConvertTo-Json
        
        <#    regex:
              TODO - any number of non-alphanumeric chars (comma, space, paren, etc) (this ensures it's the start of a list* function and not a UDF with the name "list")
              DONE - literal match of "list"
              DONE - any number of alpha-numerica chars
              DONE - any whitepace chars
              DONE - literal match of open paren "("
              DONE - any whitepace chars
        #>
            if ($outputText -match "\[.*?parameters\s*\(\s*'$($name)'\s*\)") { 
                Write-Error -Message "Output contains $($parameterProp.Type) parameter: $($output.Name)" -ErrorId Output.Contains.SecureParameter -TargetObject $output
            }
        }        
    }
}

