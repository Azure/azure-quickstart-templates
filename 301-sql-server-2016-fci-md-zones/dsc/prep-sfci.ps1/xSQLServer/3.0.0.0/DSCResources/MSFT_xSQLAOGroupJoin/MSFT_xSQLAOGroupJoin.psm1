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

        [parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupName,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName= "MSSQLSERVER",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }
    
    $vConfigured = Test-TargetResource -Ensure $Ensure -AvailabilityGroupName $AvailabilityGroupName -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName 


    $returnValue = @{
    Ensure = $vConfigured
    AvailabilityGroupName = $sql.AvailabilityGroups[$AvailabilityGroupName]
    AvailabilityGroupNameListener = $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.name
    AvailabilityGroupNameIP = $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.availabilitygrouplisteneripaddresses.IPAddress
    AvailabilityGroupSubMask =  $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.availabilitygrouplisteneripaddresses.SubnetMask
    AvailabilityGroupPort =  $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.portnumber
    AvailabilityGroupNameDatabase = $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityDatabases.name
    BackupDirectory = ""
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

        [parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupName,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName= "MSSQLSERVER",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )



        $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
        $null = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended")

        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential
        Grant-ServerPerms -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -AuthorizedUser "NT AUTHORITY\SYSTEM" -SetupCredential $SetupCredential
        

        Try
            {$SQL.JoinAvailabilityGroup($AvailabilityGroupName)
             New-VerboseMessage -Message "Joined $SQLServer\$SQLInstanceName to $AvailabilityGroupName"       
            }
        Catch
            {Throw "Unable to Join $AvailabilityGroup on $SQLServer\$SQLInstanceName"
             Exit
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

        [parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupName,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName= "MSSQLSERVER",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }

    Switch ($Ensure)
    {
        "Present"
            {

                $AGPresent=$sql.AvailabilityGroups.Contains($AvailabilityGroupName)
    
                if ($AGPresent)
                    {$Return = $true}
                else
                    {$Return = $false}
            }
        "Absent"
        {
            if(!$sql.AvailabilityGroups[$AvailabilityGroupName])
            {$Return = $true}
            else{$Return = $false}
        }
    }
    $Return

}


Export-ModuleMember -Function *-TargetResource

