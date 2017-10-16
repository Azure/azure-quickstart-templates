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
        [ValidateSet("Full","Simple","BulkLogged")]
        [System.String]
        $RecoveryModel = "Full",

        [parameter(Mandatory = $true)]
        [System.String]
        $SqlServerInstance,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName
    )
    
    $SqlServerInstance = $SqlServerInstance.Replace('\MSSQLSERVER','')  
    New-VerboseMessage -Message "Checking Database $DatabaseName recovery mode for $RecoveryModel"

    $db = Get-SqlDatabase -ServerInstance $SqlServerInstance -Name $DatabaseName
    $value = ($db.RecoveryModel -eq $RecoveryModel)
    New-VerboseMessage -Message "Database $DatabaseName recovery mode comparison $value."
    
    $returnValue = @{
        RecoveryModel = $db.RecoveryModel
        SqlServerInstance = $SqlServerInstance
        DatabaseName = $DatabaseName
    }
    
    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Full","Simple","BulkLogged")]
        [System.String]
        $RecoveryModel = "Full",

        [parameter(Mandatory = $true)]
        [System.String]
        $SqlServerInstance,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName
    )  
 
    $SqlServerInstance = $SqlServerInstance.Replace('\MSSQLSERVER','')  
    $db = Get-SqlDatabase -ServerInstance $SqlServerInstance -Name $DatabaseName    
    New-VerboseMessage -Message "Database $DatabaseName recovery mode is $db.RecoveryModel."
    
    if($db.RecoveryModel -ne $RecoveryModel)
    {
        $db.RecoveryModel = $RecoveryModel;
        $db.Alter();
        New-VerboseMessage -Message "DB $DatabaseName recovery mode is changed to $RecoveryModel."
    }
    
    if(!(Test-TargetResource @PSBoundParameters))
    {
        throw New-TerminatingError -ErrorType TestFailedAfterSet -ErrorCategory InvalidResult
    }    
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Full","Simple","BulkLogged")]
        [System.String]
        $RecoveryModel = "Full",

        [parameter(Mandatory = $true)]
        [System.String]
        $SqlServerInstance,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName
    )   
    $SqlServerInstance = $SqlServerInstance.Replace('\MSSQLSERVER','')  
    $result = ((Get-TargetResource @PSBoundParameters).RecoveryModel -eq $RecoveryModel)
    
    $result
}


Export-ModuleMember -Function *-TargetResource

