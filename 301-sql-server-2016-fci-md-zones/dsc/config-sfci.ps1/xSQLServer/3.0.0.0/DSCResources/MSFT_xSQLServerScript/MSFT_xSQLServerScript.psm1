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
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TestFilePath,

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $Variable
    )   

    $result = Invoke-SqlScript -ServerInstance $ServerInstance -SqlScriptPath $GetFilePath `
                -Credential $Credential -Variable $Variable -ErrorAction Stop

    $getResult = Out-String -InputObject $result
        
    $returnValue = @{
        ServerInstance = [System.String] $ServerInstance
        SetFilePath = [System.String] $SetFilePath
        GetFilePath = [System.String] $GetFilePath
        TestFilePath = [System.String] $TestFilePath
        Username = [System.Management.Automation.PSCredential] $Credential
        Variable = [System.String[]] $Variable
        GetResult = [System.String[]] $getresult
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TestFilePath,

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $Variable
    )

    Invoke-SqlScript -ServerInstance $ServerInstance -SqlScriptPath $SetFilePath `
                -Credential $Credential -Variable $Variable -ErrorAction Stop
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TestFilePath,

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $Variable
    )

    try
    {   
        $result = Invoke-SqlScript -ServerInstance $ServerInstance -SqlScriptPath $TestFilePath `
                -Credential $Credential -Variable $Variable -ErrorAction Stop

        if($result -eq $null)
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Verbose $_
        return $false
    }
}

function Invoke-SqlScript
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SqlScriptPath,

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $Variable
    )

    Import-SQLPSModule

    if($null -ne $Credential)
    {
        $null = $PSBoundParameters.Add("Username", $Credential.UserName)
        $null = $PSBoundParameters.Add("Password", $Credential.GetNetworkCredential().password)   
    }

    $null = $PSBoundParameters.Remove("Credential")
    $null = $PSBoundParameters.Remove("SqlScriptPath")

    Invoke-Sqlcmd -InputFile $SqlScriptPath @PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource

