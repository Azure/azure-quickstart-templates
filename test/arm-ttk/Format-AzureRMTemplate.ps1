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

        $resourceOrder = 'comments', 'condition', 'type', 'apiVersion', 'name', 
            'location', 'sku', 'kind', 'dependsOn', 'tags', 'copy'

        $sortProperties = {
            param([Parameter(ValueFromPipeline=$true)]$in, [string[]]$order,[string[]]$LastOrder, [switch]$Recurse) 

            process {
                $newObject = [PSObject]::new() # create a new object to output.
                if (-not $in) { return $null }
                if ([string], [int], [float], [bool] -contains $in.GetType()) { return $in } 
                if ($Recurse) {
                    $recurseSplat = @{} + $PSBoundParameters
                    $recurseSplat.Remove('In')
                }
                foreach ($propName in $order) { # Walk thru the properties in the preferred order.
                    if ($in.$propName) { # If the object had that property
                        $newPropValue =
                            if ($Recurse -and $in.$propName -is [Array]) { 
                                $in.$propName | & $MyInvocation.MyCommand.ScriptBlock @recurseSplat
                            } else {
                                $in.$propName
                            }
                        $newProp = [Management.Automation.PSNoteProperty]::new($propName, $newPropValue)
                        $newObject.psobject.properties.add($newProp) # add it to the new object 
                        $in.psobject.properties.remove($propName) # and remove it from the original object.
                        
                    }
                }
                if (@($in.psobject.properties).Count) { # If the template object had any properties left
                    foreach ($prop in $in.psobject.properties) { # add them to the new object in the order they were found.
                        if ($LastOrder -contains $prop.Name) { continue } 
                        $newProp = 
                            [Management.Automation.PSNoteProperty]::new($prop.Name, $in.($prop.Name))                    
                        $newObject.psobject.properties.add($newProp)
                    } 
                }
                if ($LastOrder) {
                    foreach ($propName in $LastOrder) {
                        if ($in.$propName) { # If the object had that property
                            $newPropValue =
                                if ($Recurse -and $in.$propName -is [Array]) { 
                                    $in.$propName | & $MyInvocation.MyCommand.ScriptBlock @recurseSplat
                                } else {
                                    $in.$propName
                                }
                            $newProp = 
                                [Management.Automation.PSNoteProperty]::new($propName, $newPropValue)                    
                            $newObject.psobject.properties.add($newProp) # add it to the new object 
                            $in.psobject.properties.remove($propName) # and remove it from the original object.
                            
                        }
                    }
                }
                $newObject
            }
        }
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
            
            $newTemplate = $TemplateObject | & $sortProperties -Order $topLevelPropertyOrder # sort the top-level properties.
            
            
            if ($newTemplate.resources) { # If the template had resources, sort them 
                $newTemplate.resources =@(
                    $newTemplate.resources | & $sortProperties -Order $resourceOrder -LastOrder 'properties', 'resources' -Recurse
                )
            }
            return $newObject # then return the newly formatted object.
        }
    }
}