function Format-AzureRMTemplate
{
    <#
    .Synopsis
        Formats a resource manager template in the desired order.
    .Description
        Sorts the content in a resource manager template.        
    .Link
        https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/best-practices.md
    #>
    param(
    # The path to a file
    [Parameter(Mandatory=$true,ParameterSetName='FilePath',ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname')]
    [string]$FilePath,

    # The path to a file
    [Parameter(Mandatory=$true,ParameterSetName='TemplateObject',ValueFromPipelineByPropertyName=$true)]
    [PSObject]$TemplateObject)

    begin {
        $topLevelPropertyOrder = 
            '$schema','contentVersion', 'apiProfile', 
            'parameters','functions','variables',
            'resources', 'outputs'
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FilePath') { # If we're provided the path to a file
            $resolvedPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($FilePath) # resolve it.
        
            if (-not $resolvedPath) { return } # If we couldn't, return.
        
            $templateText = [IO.File]::ReadAllText("$resolvedPath") # Read the file contents
            $templateObject = $templateText | ConvertFrom-Json # convert them from JSON.
            if (-not $templateObject) { return } # If it was null, return.

            Format-AzureRMTemplate -TemplateObject $TemplateObject # Call ourself, passing in the contents of the file. 
            return
        }

        if ($PSCmdlet.ParameterSetName -eq 'TemplateObject') { # If we're provided a template object
            $newObject = [PSObject]::new() # create a new object to output.
            foreach ($propName in $topLevelPropertyOrder) { # Walk thru the properties in the preferred order.
                if ($templateObject.$propName) { # If the template object had that property
                    $newProp = 
                        [Management.Automation.PSNoteProperty]::new($propName, $TemplateObject.$propName)                    
                    $newObject.psobject.properties.add($newProp) # add it to the new object 
                    $TemplateObject.psobject.properties.remove($propName) # and remove it from the template object.
                    
                }
            }
            if (@($templateObject.psobject.properties).Count) { # If the template object had any properties left
                foreach ($prop in $templateObject.psobject.properties) { # add them to the new object in the order they were found.
                    $newProp = 
                        [Management.Automation.PSNoteProperty]::new($prop.Name, $TemplateObject.$prop.Name)                    
                    $newObject.psobject.properties.add($newProp)
                } 
            }
            return $newObject # then return the newly formatted object.
        }
    }
}