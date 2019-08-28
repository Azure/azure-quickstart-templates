function Find-JsonContent
{
    <#
    .Synopsis
        Finds content within a json object
    .Description
        Recursively finds content within a json object 
    #>
    param(
    # The input object
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [PSObject]
    $InputObject,
    
    # The key (the name of the property) we're finding.
    [Parameter(Mandatory=$true,ParameterSetName='Key',Position=0,ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true,ParameterSetName='KeyValue',Position=0,ValueFromPipelineByPropertyName=$true)]
    [string]
    $Key,
    
    # The value we're trying to find. 
    [Parameter(Mandatory=$true,ParameterSetName='KeyValue',Position=1,ValueFromPipelineByPropertyName=$true)]
    [PSObject]
    $Value,
    
    # If set, will find values like the wildcard.
    [Parameter(ParameterSetName='Key',ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='KeyValue',ValueFromPipelineByPropertyName=$true)]
    [switch]
    $Like,
    
    # If set, will find values that match the regular expression.
    [Parameter(ParameterSetName='Key',ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='KeyValue',ValueFromPipelineByPropertyName=$true)]
    [switch]
    $Match,
    
    # If set, will find values that are not like a wildcard.
    [Parameter(ParameterSetName='Key',ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='KeyValue',ValueFromPipelineByPropertyName=$true)]
    [switch]
    $NotLike,
    
    # If set, will find values that do not match a regular expression.
    [Parameter(ParameterSetName='Key',ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='KeyValue',ValueFromPipelineByPropertyName=$true)]
    [switch]
    $NotMatch,
    
    # A list of parent objects.  This parameter will be passed recursively.
    [PSObject[]]
    $Parent,

    # The maximum depth to search
    [Uint32]
    $Depth,

    # The name of the current property.  This parameter will be passed recursively.
    [string]
    $Property)

    process {
        $mySplat = @{} + $PSBoundParameters
        $mySplat.Remove('InputObject')
        if (-not $InputObject) { return }
            

        foreach ($in in $InputObject) {
            if (-not $in) { continue } 
            if ($in -is [string] -or $in -is [int] -or $in -is [bool] -or 
                $in -is [double] -or $in -is [long] -or $in -is [float]) {
                continue
            }

            if ($PSCmdlet.ParameterSetName -eq 'KeyValue') {
                if ($in.psobject.properties.item($key)) {
                    if (($like -and $in.$key -like $Value) -or 
                        ($Match -and $in.$key -match $Value) -or
                        ($NotLike -and $in.$key -notlike $Value) -or 
                        ($NotMatch -and $in.$key -notmatch $Value) -or 
                        ($in.$key -eq $Value -and -not ($NotLike -or $NotMatch))) {
                        $OutObject = [Ordered]@{}
                        foreach ($prop in $in.psobject.properties) {
                            $OutObject[$prop.Name] = $prop.Value
                        }
                        $OutObject['ParentObject'] = $parent
                        $OutObject['PropertyName'] = $Property
                        [PSCustomObject]$OutObject
                    }
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'Key') {
                $propertyNames = @(foreach ($_ in $in.psobject.properties) { $_.Name })
                if (
                    ($NotMatch -and $propertyNames -notmatch $Key) -or 
                    ($NotLike -and $propertyNames -notlike $Key) -or 
                    ($Like -and $propertyNames -like $key) -or
                    ($Match -and $propertyNames -match $key) -or 
                    ($propertyNames -eq $key -and -not ($NotLike -or $NotMatch))
                ) {
                    $OutObject = [Ordered]@{}
                    foreach ($prop in $in.psobject.properties) {
                        $OutObject[$prop.Name] = $prop.Value
                    }
                    $OutObject['ParentObject'] = $parent
                    $OutObject['PropertyName'] = $Property
                    [PSCustomObject]$OutObject
                }
            }

                

            $mySplat.Parent = @($in) + $Parent

            if ($depth -and $mySplat.Parent.Length -ge $Depth) {
                continue 
            }
        
            if ($in -is [Object[]]) {
                Find-JsonContent @mySplat -InputObject $in
            } else {
                foreach ($prop in $in.psobject.properties) {
                    if (-not $prop.Value) { continue } 
                    if ($prop.Name -like 'parent*') { continue }
                    $mySplat.Property = $prop.Name 
                    Find-JsonContent @mySplat -InputObject $prop.Value 
                }
            }
        }
    }
} 
