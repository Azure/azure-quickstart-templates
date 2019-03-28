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
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [string]
    $Key,
    
    # The value we're trying to find. 
    [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
    [PSObject]
    $Value,
    
    # If set, will find values like the wildcard.
    [switch]
    $Like,
    
    # If set, will find values that match the regular expression.
    [switch]
    $Match,
    
    # If set, will find values that are not like a wildcard.
    [switch]
    $NotLike,
    
    # If set, will find values that do not match a regular expression.
    [switch]
    $NotMatch,
    
    # A list of parent objects.  This parameter will be passed recursively.
    [PSObject[]]
    $Parent    
    )

    process {
        $mySplat = @{} + $PSBoundParameters
        $mySplat.Remove('InputObject')
        if (-not $InputObject) { return } 
        if ($InputObject -is [string] -or $InputObject -is [int] -or $InputObject -is [bool] -or $InputObject -is [double]) {
            return
        }
        
        if ($InputObject.psobject.properties.item($key)) {
            if (($like -and $InputObject.$key -like $Value) -or 
                ($Match -and $InputObject.$key -match $Value) -or
                ($NotLike -and $InputObject.$key -notlike $Value) -or 
                ($NotMatch -and $InputObject.$key -notmatch $Value) -or 
                $InputObject.$key -eq $Value) {

                $OutObject = [PSObject]::new()
                foreach ($prop in $InputObject.psobject.properties) {
                    $OutObject.psobject.properties.Add(
                        [Management.Automation.PSNoteProperty]::new($prop.Name, $prop.Value))
                }
                

                return ($OutObject |
                    Add-Member NoteProperty ParentObject -Value $Parent -Force -PassThru)
            }
        }
        $mySplat.Parent = @($InputObject) + $Parent
        
        if ($InputObject -is [Object[]]) {
            $InputObject |
                Find-JsonContent @mySplat
        } else {
            $InputObject.psobject.properties |
                Where-Object { @('parentObject', 'parentResources') -notcontains $_.Name } |
                Select-Object -ExpandProperty Value |
                Find-JsonContent @mySplat
        }
    }
} 
