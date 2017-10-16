$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $DynamicAlloc,

        [System.Int32]
        $MinMemory = -1,

        [System.Int32]
        $MaxMemory,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLInstanceName
    )

        if(!$SQL)
        {
            $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
        }

        if($SQL)
        {
            $GetMinMemory = $sql.Configuration.MinServerMemory.ConfigValue
            $GetMaxMemory = $sql.Configuration.MaxServerMemory.ConfigValue
        }

        if ($GetMaxMemory -eq 2147483647)
        {
            $Ensure = "Absent"
        }
        else
        {
            $Ensure = "Present"
        }

        $returnValue = @{
                DynamicAlloc = $DynamicAlloc
                MinMemory = $MinMemory
                MaxMemory = $MaxMemory
                Ensure = $Ensure
                }
        $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $DynamicAlloc,

        [System.Int32]
        $MinMemory = -1,

        [System.Int32]
        $MaxMemory,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLInstanceName
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }

    If($SQL)
    {
        $serverMem = $sql.PhysicalMemory
        switch($Ensure)
        {
            "Absent"
            {
                   $MaxMemory = 2147483647
                   $MinMemory = 128
            }
            "Present"
            {       
                if ($DynamicAlloc)
                {
                    if ($serverMem -ge 128000) 
                    {
                        #Server mem - 10GB
                        $MaxMemory = $serverMem - 10000 
                    }
                    elseif ($serverMem -ge 32000 -and $serverMem -lt 128000) 
                    {
                        #Server mem - 4GB 
                        $MaxMemory = $serverMem - 4000
                    }
                    elseif ($serverMem -ge 16000)
                    {
                        #Server mem - 2GB 
                        $MaxMemory = $serverMem - 2000
                    }
                    else
                    {
                        #Server mem - 1GB 
                        $MaxMemory = $serverMem - 1000
                    }
                }
                else
                {
                    if  (-not $MaxMemory -or $MinMemory -lt 0) {
                        throw "Dynamic Allocation is not set. Valid values were not supplied for MaxMemory or MinMemory."
                    }

                    if ($MinMemory -gt $MaxMemory) {
                        throw "Provided MinMemory value is greater than MaxMemory."
                    }
                }
            }
        }
        try
        {            
            $sql.Configuration.MaxServerMemory.ConfigValue = $MaxMemory
            if($MinMemory -ge 0)
            {
                Write-Verbose -message "MinMem will be set to $MinMemory."
                $sql.Configuration.MinServerMemory.ConfigValue = $MinMemory
            }
            $sql.alter()
            New-VerboseMessage -Message "SQL Server Memory has been capped to $MaxMemory."
        }
        catch
        {
            New-VerboseMessage -Message "Failed setting Min and Max SQL Memory"
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $DynamicAlloc,

        [System.Int32]
        $MinMemory = -1,

        [System.Int32]
        $MaxMemory,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $SQLInstanceName
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }

    if($SQL)
    {
        $GetMinMemory = $sql.Configuration.MinServerMemory.ConfigValue
        $GetMaxMemory = $sql.Configuration.MaxServerMemory.ConfigValue
    }

    switch($Ensure)
    {
        "Absent"
        {
            if ($GetMaxMemory  -eq 2147483647)
            {
                New-VerboseMessage -Message "Current Max Memory is $GetMaxMemory. Min Memory is $GetMinMemory"
                return $true
            }
            else 
            {
                New-VerboseMessage -Message "Current Max Memory is $GetMaxMemory. Min Memory is $GetMinMemory"
                return $false
            }
        }
        "Present"
        {      
       
             If ($DynamicAlloc)
             {
                 if ($GetMaxMemory  -eq 2147483647)
                 {
                     New-VerboseMessage -Message "Current Max Memory is $GetMaxMemory. Min Memory is $GetMinMemory"
                     return $false
                 }
                 else 
                 {
                     New-VerboseMessage -Message "Current Max Memory is $GetMaxMemory. Min Memory is $GetMinMemory"
                     return $true
                 }
             }
             else
             {
                 If(($MinMemory -ge 0 -and $MinMemory -ne $GetMinMemory) -or $MaxMemory -ne $GetMaxMemory)
                 {
                    New-VerboseMessage -Message "Current Max Memory is $GetMaxMemory. Min Memory is $GetMinMemory"
                    return $false
                 }
                 else
                 {
                    New-VerboseMessage -Message "Current Max Memory is $GetMaxMemory. Min Memory is $GetMinMemory"
                    return $true
                 }
             }
        }
    }
}


Export-ModuleMember -Function *-TargetResource

