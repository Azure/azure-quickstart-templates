Configuration DscConfiguration {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $domainName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $domainCredentialName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $dcComputerName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $msComputerName
    )

    $domainCredentials = Get-AutomationPSCredential $domainCredentialName

    Import-DscResource -ModuleName ActiveDirectoryDsc    -ModuleVersion 6.2.0    -Name ADDomain,WaitForADDomain
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0    -Name Computer
    Import-DscResource -ModuleName PSDscResources        -ModuleVersion 2.12.0.0 -Name WindowsFeatureSet,WindowsFeature

    node $dcComputerName {
        Computer Name {
            Name = $dcComputerName
        }
        WindowsFeatureSet AD {
            Name   = @('AD-Domain-Services', 'RSAT-ADDS-Tools', 'DNS', 'RSAT-DNS-Server')
            Ensure = 'Present'
        }
        ADDomain $domainName {
            DomainName                    = $domainName
            Credential                    = $domainCredentials
            SafemodeAdministratorPassword = $domainCredentials
            ForestMode                    = 'WinThreshold'
            DependsOn                     = '[Computer]Name','[WindowsFeatureSet]AD'
        }
    }

    node $msComputerName {
        WaitForADDomain $domainName {
            DomainName  = $domainName
            Credential  = $domainCredentials
            WaitTimeout = 1800 # 30 minutes in order to allow a smooth deployment
        }
        Computer JoinDomain {
            Name       = $msComputerName
            DomainName = $domainName
            Credential = $domainCredentials
            DependsOn  = "[WaitForADDomain]$domainName"
        }
    }
}