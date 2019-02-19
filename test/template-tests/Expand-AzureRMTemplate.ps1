function Expand-AzureRMTemplate
{
    <#
    .Synopsis
        Expands the contents of an Azure Resource Manager template.
    .Description
        Expands an Azure Resource Manager template and related files into a set of well-known parameters

    #>
    param(
    # The path to an Azure resource manager template
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true,ParameterSetName='SpecificTemplate')]
    [Alias('Fullname','Path')]
    [string]
    $TemplatePath
    )

    begin {
        function Expand-Resource (
            [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
            [Alias('Resources')]
            [PSObject[]]
            $Resource,

            [PSObject[]]
            $Parent
        ) {
            process { 
                foreach ($r in $Resource) {
                    $r |
                        Add-Member NoteProperty ParentResources $parent -Force -PassThru

                    if ($r.resources) {
                        $r | Expand-Resource -Parent (@($r) + @(if ($parent) { $parent }))
                    }
                }
            }   
        }
    }

    process {
        # Now let's try to resolve the template path.
        $resolvedTemplatePath = 
            # If the template path doesn't appear to be a path to a json file,
            if ($TemplatePath -notlike '*.json') { 
                # see if it looks like a file
                if (($templatePath | Split-Path -Leaf) -like '*.*') {
                    $TemplatePath = $TemplatePath | Split-Path # if it does, reassign template path to it's directory.
                }
                # Then, go looking beneath that template path
                $preferredJsonFile = $TemplatePath | 
                    Get-ChildItem -Filter *.json |
                    # for a file named azureDeploy.json or mainTemplate.json
                    Where-Object { 'azureDeploy.json', 'mainTemplate.json' -contains $_.Name } |
                    Select-Object -First 1 -ExpandProperty Fullname
                # If no file was found, write an error and return.
                if (-not $preferredJsonFile) {
                    Write-Error "No azureDeploy.json or mainTemplate.json found beneath $TemplatePath"
                    return
                }
                $preferredJsonFile
            } else { 
                $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($templatePath)
            }

        # If we couldn't find a template file, return (an error should have already been written).
        if (-not $resolvedTemplatePath) {  return }


        # Next, we want to pre-populate a number of well-known variables.
        # These variables will be available to every test case.   They are:
        $WellKnownVariables = 'TemplateFullPath','TemplateText','TemplateObject',
            'CreateUIDefinitionFullPath','createUIDefintionText','CreateUIDefinitionObject',
            'FolderName', 'HasCreateUIDefinition', 'IsMainTemplate','FolderFiles', 
            'MainTemplatePath', 'MainTemplateObject', 'MainTemplateText'
        foreach ($_ in $WellKnownVariables) {
            $ExecutionContext.SessionState.PSVariable.Set($_, $null)
        }
            
        #*$templateFullPath (the full path to the .json file)
        $TemplateFullPath = "$resolvedTemplatePath"
        #*$TemplateFileName (the name of the azure template file)
        $templateFileName = $TemplatePath | Split-Path -Leaf
        #*$IsMainTemplate (if the TemplateFileName is named mainTemplate.json)
        $isMainTemplate = 'mainTemplate.json', 'azureDeploy.json' -contains $templateFileName
        $templateFile = Get-Item -LiteralPath $resolvedTemplatePath
        $templateFolder = $templateFile.Directory
        #*$FolderName (the name of the root folder containing the template)
        $TemplateName = $templateFolder.Name
        #*$TemplateText (the text contents of the template file)
        $TemplateText = [IO.File]::ReadAllText($resolvedTemplatePath)
        #*$TemplateObject (the template text, converted from JSON)
        $TemplateObject = $TemplateText | ConvertFrom-Json    
        #*$CreateUIDefinitionFullPath (the path to CreateUIDefinition.json)
        $createUiDefinitionFullPath = Join-Path -childPath 'createUiDefinition.json' -Path $templateFolder
        if (Test-Path $createUiDefinitionFullPath) {
            #*$CreateUIDefinitionText (the text contents of CreateUIDefinition.json)
            $createUIDefintionText = [IO.File]::ReadAllText($createUiDefinitionFullPath)
            #*$CreateUIDefinitionObject (the createuidefinition text, converted from json)
            $createUIDefinitionObject =  $createUIDefintionText | ConvertFrom-Json
            #*$HasCreateUIDefinition (indicates if a CreateUIDefinition.json file exists)
            $HasCreateUIDefinition = $true            
        } else {                
            $HasCreateUIDefinition = $false
            $createUiDefinitionFullPath = $null 
        }
        

        #*$FolderFiles (a list of objects of each file in the directory)
        $FolderFiles = 
            @(Get-ChildItem -Path $templateFolder.FullName -Recurse |
                Where-Object { -not $_.PSIsContainer } |
                ForEach-Object {

                    # All FolderFile objects will have the following properties:
                    $fileInfo = $_
                    $fileObject = [Ordered]@{
                        Name = $fileInfo.Name #*Name (the name of the file)
                        Extension = $fileInfo.Extension #*Extension (the file extension) 
                        Bytes = [IO.File]::ReadAllBytes($fileInfo.FullName)#*Bytes (the file content as a byte array)
                        Text = [IO.File]::ReadAllText($fileInfo.FullName)#*Text (the file content as text)
                        FullPath = $fileInfo.Fullname#*FullPath (the full path to the file)
                    }
                    if ($fileInfo.Extension -eq '.json') { 
                        # If the file is JSON, two additional properties may be present:
                        #*Object (the file's text, converted from JSON)
                        $fileObject.Object = $fileObject.Text | ConvertFrom-Json
                        #*Schema (the value of the $schema property of the JSON object, if present)
                        $fileObject.schema = $fileObject.Object.'$schema'                        
                    }
                    $fileObject    
                })

        if ($isMainTemplate) { # If the file was a main template,
            # we set a few more variables:
            #*MainTemplatePath (the path to the main template file)
            $MainTemplatePath = "$TemplateFullPath"
            #*MainTemplateText (the text of the main template file)
            $MainTemplateText = [IO.File]::ReadAllText($MainTemplatePath)
            #*MainTemplateObject (the main template, converted from JSON)
            $MainTemplateObject = $MainTemplateText | ConvertFrom-Json
            #*MainTemplateResources (the resources and child resources in the main template)
            $MainTemplateResources = Expand-Resource -Resource $MainTemplateObject.resources
            #*MainTemplateParameters (a hashtable of parameters in the main template)
            $MainTemplateParameters = [Ordered]@{}
            foreach ($prop in $MainTemplateObject.parameters.psobject.properties) {
                $MainTemplateParameters[$prop.Name] = $prop.Value
            }
            #*MainTemplateVariables (a hashtable of variables in the main template)
            $MainTemplateVariables = [Ordered]@{}
            foreach ($prop in $MainTemplateObject.variables.psobject.properties) {
                $MainTemplateVariables[$prop.Name] = $prop.Value
            }
            #*MainTemplateOutputs (a hashtable of outputs in the main template)
            $MainTemplateOutputs = [Ordered]@{}
            foreach ($prop in $MainTemplateObject.outputs.psobject.properties) {
                $MainTemplateOutputs[$prop.Name] = $prop.Value
            }
        }
        
        # If we've found a CreateUIDefinition, we'll want to process it first.                
        if ($HasCreateUIDefinition) { 
            # Loop over the folder files and get every file that isn't createUIDefinition
            $otherFolderFiles = @(foreach ($_ in $FolderFiles) {
                if ($_.Name -ne 'CreateUIDefinition.json') {
                    $_
                } else {
                    $createUIDefFile = $_
                }
            })
            # Then recreate the list with createUIDefinition that the front.
            $FolderFiles = @(@($createUIDefFile) + @($otherFolderFiles) -ne $null)
        }


        $out = [Ordered]@{}
        foreach ($v in $WellKnownVariables) {
            $out[$v] = $ExecutionContext.SessionState.PSVariable.Get($v).Value
        }
        $out
    }
}