#
# Copyright="� Microsoft Corporation. All rights reserved."
#

configuration ConfigureSharePointServer
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SharePointSetupUserAccountcreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SharePointFarmAccountcreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SharePointFarmPassphrasecreds,

        [parameter(Mandatory)]
        [String]$DatabaseName,

        [parameter(Mandatory)]
        [String]$AdministrationContentDatabaseName,

        [parameter(Mandatory)]
        [String]$DatabaseServer,

        [parameter(Mandatory)]
        [String]$Configuration,

        [Int]$RetryCount=30,
        [Int]$RetryIntervalSec=60
    )

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential ]$FarmCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($SharePointFarmAccountcreds.UserName)", $SharePointFarmAccountcreds.Password)
    [System.Management.Automation.PSCredential ]$SPsetupCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($SharePointSetupUserAccountcreds.UserName)", $SharePointSetupUserAccountcreds.Password)

    # Install Sharepoint Module
    $ModuleFilePath="$PSScriptRoot\SharePointServer.psm1"
    $ModuleName = "SharepointServer"
    $PSModulePath = $Env:PSModulePath -split ";" | Select -Index 1
    $ModuleFolder = "$PSModulePath\$ModuleName"
    if (-not (Test-Path  $ModuleFolder -PathType Container)) {
        mkdir $ModuleFolder
    }
    Copy-Item $ModuleFilePath $ModuleFolder -Force

    Import-DscResource -ModuleName xComputerManagement, xActiveDirectory
    Import-DSCResource -ModuleName SharePointDSC -ModuleVersion 3.1.0.0

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode  = "ApplyOnly"
            RebootNodeIfNeeded = $true
        }

        xWaitForADDomain DscForestWait
        {
            DomainName           = $DomainName
            DomainUserCredential = $DomainCreds
            RetryCount           = $RetryCount
            RetryIntervalSec     = $RetryIntervalSec
        }

        xComputer DomainJoin
        {
            Name       = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn  = "[xWaitForADDomain]DscForestWait"
        }

        xADUser CreateSetupAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName                    = $DomainName
            UserName                      = $SharePointSetupUserAccountcreds.UserName
            Password                      = $SharePointSetupUserAccountcreds
            Ensure                        = "Present"
            DependsOn                     = "[xComputer]DomainJoin"
        }

        Group AddSetupUserAccountToLocalAdminsGroup
        {
            GroupName        = "Administrators"
            Credential       = $DomainCreds
            MembersToInclude = "${DomainName}\$($SharePointSetupUserAccountcreds.UserName)"
            Ensure           = "Present"
            DependsOn        = "[xAdUser]CreateSetupAccount"
        }

        xADUser CreateFarmAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName                    = $DomainName
            UserName                      = $SharePointFarmAccountcreds.UserName
            Password                      = $FarmCreds
            Ensure                        = "Present"
            DependsOn                     = "[xComputer]DomainJoin"
        }

        SPFarm SharePointFarm
        {
            
            Ensure               = "Present"
            PsDscRunAsCredential = $SPsetupCreds
        }
        cConfigureSharepoint ConfigureSharepointServer
        {
            DomainName=$DomainName
            DomainAdministratorCredential=$DomainCreds
            DatabaseName=$DatabaseName
            AdministrationContentDatabaseName=$AdministrationContentDatabaseName
            DatabaseServer=$DatabaseServer
            SetupUserAccountCredential=$SPsetupCreds
            FarmAccountCredential=$SharePointFarmAccountcreds
            FarmPassphrase=$SharePointFarmPassphrasecreds
            Configuration=$Configuration
            DependsOn = "[xADUser]CreateFarmAccount","[xADUser]CreateSetupAccount", "[Group]AddSetupUserAccountToLocalAdminsGroup"
        }
    }
}

function Enable-CredSSPNTLM
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$DomainName
    )

    # This is needed for the case where NTLM authentication is used

    Write-Verbose 'STARTED:Setting up CredSSP for NTLM'

    Enable-WSManCredSSP -Role client -DelegateComputer localhost, *.$DomainName -Force -ErrorAction SilentlyContinue
    Enable-WSManCredSSP -Role server -Force -ErrorAction SilentlyContinue

    if(-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -ErrorAction SilentlyContinue))
    {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name '\CredentialsDelegation' -ErrorAction SilentlyContinue
    }

    if( -not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -value '1' -PropertyType dword -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -value '1' -PropertyType dword -ErrorAction SilentlyContinue
    }

    if(-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -ErrorAction SilentlyContinue))
    {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '1' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '1' -value "wsman/$env:COMPUTERNAME" -PropertyType string -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '2' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '2' -value "wsman/localhost" -PropertyType string -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '3' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '3' -value "wsman/*.$DomainName" -PropertyType string -ErrorAction SilentlyContinue
    }

    Write-Verbose "DONE:Setting up CredSSP for NTLM"
}