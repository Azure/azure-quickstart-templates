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
        if ($PSCmdlet.ParameterSetName -eq 'FilePath') {
            $resolvedPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($FilePath)
        
            if (-not $resolvedPath) { return } 
        
            $templateText = [IO.File]::ReadAllText("$resolvedPath")
            $templateObject = $templateText | ConvertFrom-Json
            if (-not $templateObject) { return } 

            Format-AzureRMTemplate -TemplateObject $TemplateObject
            return
        }

        if ($PSCmdlet.ParameterSetName -eq 'TemplateObject') {
            $newObject = [PSObject]::new()
            foreach ($propName in $topLevelPropertyOrder) {
                if ($templateObject.$propName) {
                    $newProp = 
                        [Management.Automation.PSNoteProperty]::new($propName, $TemplateObject.$propName)                    
                    $TemplateObject.psobject.properties.remove($propName)                    
                    $newObject.psobject.properties.add($newProp)
                }
            }
            if (@($templateObject.psobject.properties).Count) {
                foreach ($prop in $templateObject.psobject.properties) {
                    $newProp = 
                        [Management.Automation.PSNoteProperty]::new($prop.Name, $TemplateObject.$prop.Name)                    
                    $newObject.psobject.properties.add($newProp)
                } 
            }
            return $newObject
        }
    }
}