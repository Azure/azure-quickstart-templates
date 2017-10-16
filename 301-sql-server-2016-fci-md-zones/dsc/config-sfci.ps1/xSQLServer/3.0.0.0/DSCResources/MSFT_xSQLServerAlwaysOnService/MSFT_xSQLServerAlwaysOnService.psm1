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
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,
        
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName= "MSSQLSERVER"
    )
    $vConfigured = Test-TargetResource -Ensure $Ensure -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName 
    
    $returnValue = @{
    Ensure = $vConfigured
    SQLServer = $SQLServer
    SQLInstanceName = $SQLInstanceName
    }

    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName= "MSSQLSERVER"
    )

    if ($Ensure ="Present")
    {
        
        if($SQLInstanceName -eq "MSSQLSERVER")
        {
            Try
                {
                 Enable-SqlAlwaysOn -ServerInstance $SQLServer -Force
                 New-VerboseMessage -Message "Enabled AlwaysOn on $SQLServer"
                }
            Catch 
                {
                 Throw "Unable to enable AlwaysOn on $SQLServer"
                 Exit
                }
        }
        else
        {
            Try
                {
                 Enable-SqlAlwaysOn -ServerInstance $SQLServer\$SQLInstanceName -Force
                 New-VerboseMessage -Message "Enabled AlwaysOn on $SQLServer\$SQLInstanceName"
                }
            Catch 
                {
                 Throw "Unable to disable AlwaysOn on $SQLServer\$SQLInstanceName"
                 Exit
                }
        }


    }
    else
    {
        if($SQLInstanceName -eq "MSSQLSERVER")
        {
            Try
                {
                 Disable-SqlAlwaysOn -ServerInstance $SQLServer -Force
                 New-VerboseMessage -Message "Disabled AlwaysOn on $SQLServer"
                }
            Catch 
                {
                 Throw "Unable to disable AlwaysOn on $SQLServer"
                 Exit
                }
        }
        else
        {
            Try
                {
                 Disable-SqlAlwaysOn -ServerInstance $SQLServer\$SQLInstanceName -Force
                 New-VerboseMessage -Message "Disabled AlwaysOn on $SQLServer\$SQLInstanceName"
                }
            Catch 
                {
                 Throw "Unable to disable AlwaysOn on $SQLServer\$SQLInstanceName"
                 Exit
                }
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName= "MSSQLSERVER"
    )

    
    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }

    $result = $sql.IsHadrEnabled
    New-VerboseMessage -Message "AlwaysOn status of $SQLServer\$SQLInstanceName is $result" 

    $result
}


Export-ModuleMember -Function *-TargetResource

