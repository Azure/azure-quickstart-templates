function Get-TargetResource 
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [parameter(Mandatory)]
        [PSCredential]$SetupUserAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmPassphrase,

        [Parameter(Mandatory)]
        [String]$DatabaseName,

        [parameter(Mandatory)]
        [String]$AdministrationContentDatabaseName,

        [parameter(Mandatory)]
        [String]$DatabaseServer,

        [parameter(Mandatory)]
        [String]$Configuration
    )


    $returnValue= @{
        Configured = $false
    }


    try {
        # check if snapin installed

        if (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) {
        
            # check if farm exists and this server is joined

            if ( CheckIfJoinedFarm -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -AdministrationContentDatabaseName $AdministrationContentDatabaseName -FarmCredentials $FarmAccountCredential -Passphrase $FarmPassphrase) {
        
                # Check if this is the first server

                ScanFarmServers -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer
                if (-not ($Script:IsFirstServer)) {
                    LoadConfiguration -Configuration $Configuration
                    if ($Script:ApplicationServerConfig) {
                        # Check for Central Web Application.
                        $Fqdn = $Script:ApplicationServerConfig.properties.fqdn
                        $Port = $Script:ApplicationServerConfig.properties.port
                        
                        if (TestCentralAdministrationWebApp @params) {
                            $returnValue.Configured = $true
                        }
                    }
                    if ($Script:WebServerConfig) {
                        $URL = $Script:WebServerConfig.properties.site.url
                        if (Get-SPSite -Limit ALL | Where-Object { $_.Url -eq $URL }) {
                            Write-Verbose -Message "Site collection exists."
                            $returnValue.Configured = $true
                        }
                    }
                }
            }
        }
    }
    catch {
        if ($error[0]) {Write-Verbose $error[0].Exception}
        Write-Verbose "Error Testing if SP is configured"
    }
    $returnValue

}

#  Expectation is a hashtable with properties of the DSC Extension, if it exists.

function Set-TargetResource 
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [parameter(Mandatory)]
        [PSCredential]$SetupUserAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmPassphrase,

        [Parameter(Mandatory)]
        [String]$DatabaseName,

        [parameter(Mandatory)]
        [String]$AdministrationContentDatabaseName,

        [parameter(Mandatory)]
        [String]$DatabaseServer,

        [parameter(Mandatory)]
        [String]$Configuration
    )

    try
    {
        $script=${Function:Configure-Sharepoint}
        $session = New-PSSession  -Credential $SetupUserAccountCredential -Authentication Credssp
        
        Invoke-Command -Session $session -ScriptBlock $script `
         -ArgumentList $DomainName,$DomainAdministratorCredential,$SetupUserAccountCredential,$FarmAccountCredential,$FarmPassphrase,`
                        $DatabaseName,$AdministrationContentDatabaseName,$DatabaseServer,$Configuration
    }
    catch
    {
        Write-Warning ("ConfigureSharePointServer failed. Error:" + $_)
    }
    finally
    {
        Remove-PSSession -Session $session
    }
}
#  Expectation is the DSC script will be executed on the target VM

function Test-TargetResource 
{
    [CmdletBinding()]
    [OutputType([Boolean])]
     param(
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [parameter(Mandatory)]
        [PSCredential]$SetupUserAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmPassphrase,

        [Parameter(Mandatory)]
        [String]$DatabaseName,

        [parameter(Mandatory)]
        [String]$AdministrationContentDatabaseName,

        [parameter(Mandatory)]
        [String]$DatabaseServer,

        [parameter(Mandatory)]
        [String]$Configuration
    )

    try
    {
        $parameters = $PSBoundParameters.Remove("Debug");
        $existingResource = Get-TargetResource @PSBoundParameters
        $existingResource.Configured
    }
    catch
    {
        if ($error[0]) {Write-Verbose $error[0].Exception}
        Write-Verbose -Message "Sharepoint is NOT correctly configurred on the current node."
        $false
    }

}

function Configure-Sharepoint 
{
    [CmdletBinding()]

    param(
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [parameter(Mandatory)]
        [PSCredential]$SetupUserAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmAccountCredential,

        [parameter(Mandatory)]
        [PSCredential]$FarmPassphrase,

        [Parameter(Mandatory)]
        [String]$DatabaseName,

        [parameter(Mandatory)]
        [String]$AdministrationContentDatabaseName,

        [parameter(Mandatory)]
        [String]$DatabaseServer,

        [parameter(Mandatory)]
        [String]$Configuration
    )


    $VerbosePreference = "Continue"

    Import-Module 'SharePointServer' -Force

    DisableLoopbackCheck

    AddSharePointPsSnapin

    LoadConfiguration -Configuration $Configuration

        
    CreateNewOrJoinExistingFarm -DatabaseName $DatabaseName `
                                -DatabaseServer $DatabaseServer `
                                -AdministrationContentDatabaseName $AdministrationContentDatabaseName `
                                -FarmCredentials $FarmAccountCredential `
                                -Passphrase $FarmPassphrase

    ScanFarmServers -DatabaseName $DatabaseName `
                    -DatabaseServer $DatabaseServer

    ConfigureFarm
}

Export-ModuleMember -function *-TargetResource