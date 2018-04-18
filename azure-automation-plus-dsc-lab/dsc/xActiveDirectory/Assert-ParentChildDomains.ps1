[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingComputerNameHardcoded', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$secpasswd = ConvertTo-SecureString "Adrumble@6" -AsPlainText -Force
$domainCred = New-Object System.Management.Automation.PSCredential ("sva-dscdom\Administrator", $secpasswd)
$safemodeAdministratorCred = New-Object System.Management.Automation.PSCredential ("sva-dscdom\Administrator", $secpasswd)
$localcred = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)
$redmondCred = Get-Credential -Message "Enter Credentials for DNS Delegation: "
$newpasswd = ConvertTo-SecureString "Adrumble@7" -AsPlainText -Force
$userCred = New-Object System.Management.Automation.PSCredential ("sva-dscdom\Administrator", $newpasswd)

configuration AssertParentChildDomains
{

    Import-DscResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{$_.Role -eq "Parent DC"}.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $redmondCred
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domaincred
        RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            UserName = "dummy"
            Password = $userCred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

    }

    Node $AllNodes.Where{$_.Role -eq "Child DC"}.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.ParentDomainName
            DomainUserCredential = $domaincred
        RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomain ChildDS
        {
            DomainName = $Node.DomainName
            ParentDomainName = $Node.ParentDomainName
            DomainAdministratorCredential = $domaincred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}

$config = Invoke-Expression (Get-content $PSScriptRoot\ParentChildconfig.psd1 -Raw)
AssertParentChildDomains -configurationData $config

$computerName1 = "sva-dsc1"
$computerName2 = "sva-dsc2"

Start-DscConfiguration -Wait -Force -Verbose -ComputerName $computerName1 -Path $PSScriptRoot\AssertParentChildDomains -Credential $localcred
Start-DscConfiguration -Wait -Force -Verbose -ComputerName $computerName2 -Path $PSScriptRoot\AssertParentChildDomains -Credential $localcred

