# xActiveDirectory

[![Build status](https://ci.appveyor.com/api/projects/status/p4jejr60jrgb8ity/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xactivedirectory/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/xActiveDirectory/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/xActiveDirectory)

The **xActiveDirectory** DSC resources allow you to configure and manage Active Directory.
Note: these resources do not presently install the RSAT tools.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing

Please check out common DSC Resource [contributing guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

## Description

The **xActiveDirectory** module contains the **xADComputer, xADDomain, xADDomainController, xADUser, xWaitForDomain, xADDomainTrust, xADRecycleBin, xADGroup, xADOrganizationalUnit and xADDomainDefaultPasswordPolicy** DSC Resources.
These DSC Resources allow you to configure new domains, child domains, and high availability domain controllers, establish cross-domain trusts and manage users, groups and OUs.

## Resources

* **xADComputer** creates and manages Active Directory computer accounts.
* **xADDomain** creates new Active Directory forest configurations and new Active Directory domain configurations.
* **xADDomainController** installs and configures domain controllers in Active Directory.
* **xADDomainDefaultPasswordPolicy** manages an Active Directory domain's default password policy.
* **xADDomainTrust** establishes cross-domain trusts.
* **xADGroup** modifies and removes Active Directory groups.
* **xADOrganizationalUnit** creates and deletes Active Directory OUs.
* **xADUser** modifies and removes Active Directory Users.
* **xADServicePrincipalName** adds or removes the SPN to a user or computer account.
* **xWaitForDomain** waits for new, remote domain to setup.

(Note: the RSAT tools will not be installed when these resources are used to configure AD.)

### **xADDomain**

* **DomainName**: Name of the domain.
  * If no parent name is specified, this is the fully qualified domain name for the first domain in the forest.
* **ParentDomainName**: Fully qualified name of the parent domain (optional).
* **DomainAdministratorCredential**: Credentials used to query for domain existence.
  * _Note: These are NOT used during domain creation._

(AD sets the local admin credentials as new domain administrator credentials during setup.)

* **SafemodeAdministratorPassword**: Password for the administrator account when the computer is started in Safe Mode.
* **DnsDelegationCredential**: Credential used for creating DNS delegation (optional).
* **DomainNetBIOSName**: Specifies the NetBIOS name for the new domain (optional).
  * If not specified, then the default is automatically computed from the value of the DomainName parameter.
* **DatabasePath**: Specifies the fully qualified, non-Universal Naming Convention (UNC) path to a directory on a fixed disk of the local computer that contains the domain database (optional).
* **LogPath**: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the log file for this operation will be written (optional).
* **SysvolPath**: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the Sysvol file will be written. (optional)

### **xADDomainController**

* **DomainName**: The fully qualified domain name for the domain where the domain controller will be present.
* **DomainAdministratorCredential**: Specifies the credential for the account used to install the domain controller.
* **SafemodeAdministratorPassword**: Password for the administrator account when the computer is started in Safe Mode.
* **DatabasePath**: Specifies the fully qualified, non-Universal Naming Convention (UNC) path to a directory on a fixed disk of the local computer that contains the domain database (optional).
* **LogPath**: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the log file for this operation will be written (optional).
* **SysvolPath**: Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the Sysvol file will be written. (optional)
* **SiteName**: Specify the name of an existing site where new domain controller will be placed. (optional)

### **xADUser**

* **DomainName**: Name of the domain to which the user will be added.
  * The Active Directory domain's fully-qualified domain name must be specified, i.e. contoso.com.
  * This parameter is used to query and set the user's account password.
* **UserName**: Specifies the Security Account Manager (SAM) account name of the user.
  * To be compatible with older operating systems, create a SAM account name that is 20 characters or less.
  * Once created, the user's SamAccountName and CN cannot be changed.
* **Password**: Password value for the user account.
  * _If the account is enabled (default behaviour) you must specify a password._
  * _You must ensure that the password meets the domain's complexity requirements._
* **Ensure**: Specifies whether the given user is present or absent (optional).
  * If not specified, this value defaults to Present.
* **DomainController**: Specifies the Active Directory Domain Services instance to connect to (optional).
  * This is only required if not executing the task on a domain controller.
* **DomainAdministratorCredential**: User account credentials used to perform the task (optional).
  * This is only required if not executing the task on a domain controller or using the -DomainController parameter.
* **CommonName**: Specifies the user's CN of the user account (optional).
  * If not specified, this defaults to the ___UserName___ value.
* **UserPrincipalName**: Each user account has a user principal name (UPN) in the format [user]@[DNS-domain-name] &#40;optional&#41;.
* **DisplayName**: Specifies the display name of the user object (optional).
* **Path**: (optional).
* **GivenName**: Specifies the user's first or given name (optional).
* **Initials**: Specifies the initials that represent part of a user's name (optional).
* **Surname**: Specifies the user's last name or surname (optional).
* **Description**: Specifies a description of the user object (optional).
* **StreetAddress**: Specifies the user's street address (optional).
* **POBox**: Specifies the user's post office box number (optional).
* **City**: Specifies the user's town or city (optional).
* **State**: Specifies the user's state or province (optional).
* **PostalCode**: Specifies the user's postal code or zip code (optional).
* **Country**: Specifies the country or region code for the user's language of choice (optional).
  * This should be specified as the country's two character ISO-3166 code.
* **Department**: Specifies the user's department (optional).
* **Division**: Specifies the user's division (optional).
* **Company**: Specifies the user's company (optional).
* **Office**: Specifies the location of the user's office or place of business (optional).
* **JobTitle**: Specifies the user's job title (optional).
* **EmailAddress**: Specifies the user's e-mail address (optional).
* **EmployeeID**: Specifies the user's employee ID (optional).
* **EmployeeNumber**: Specifies the user's employee number (optional).
* **HomeDirectory**: Specifies a user's home directory path (optional).
* **HomeDrive**: Specifies a drive that is associated with the UNC path defined by the HomeDirectory property (optional).
  * The drive letter is specified as "[DriveLetter]:" where [DriveLetter] indicates the letter of the drive to associate.
  * The [DriveLetter] must be a single, uppercase letter and the colon is required.
* **HomePage**: Specifies the URL of the home page of the user object (optional).
* **ProfilePath**: Specifies a path to the user's profile (optional).
  * This value can be a local absolute path or a Universal Naming Convention (UNC) path.
* **LogonScript**: Specifies a path to the user's log on script (optional).
  * This value can be a local absolute path or a Universal Naming Convention (UNC) path.
* **Notes**: (optional).
* **OfficePhone**: Specifies the user's office telephone number (optional).
* **MobilePhone**: Specifies the user's mobile phone number (optional).
* **Fax**: Specifies the user's fax phone number (optional).
* **Pager**: Specifies the user's pager number (optional).
* **IPPhone**: Specifies the user's IP telephony number (optional).
* **HomePhone**: Specifies the user's home telephone number (optional).
* **Enabled**: Specifies if an account is enabled (optional).
  * An enabled account requires a password.
* **Manager**: Specifies the user's manager (optional).
  * This value can be specified as a DN, ObjectGUID, SID or SamAccountName.
* **PasswordNeverExpires**: Specifies whether the password of an account can expire (optional).
  * If not specified, this value defaults to False.
* **CannotChangePassword**: Specifies whether the account password can be changed (optional).
  * If not specified, this value defaults to False.
* **PasswordAuthentication**: Specifies the authentication context used when testing users' passwords (optional).
  * The 'Negotiate' option supports NTLM authentication - which may be required when testing users' passwords when Active Directory Certificate Services (ADCS) is deployed.

### **xWaitForADDomain**

* **DomainName**: Name of the remote domain.
* **RetryIntervalSec**: Interval to check for the domain's existence.
* **RetryCount**: Maximum number of retries to check for the domain's existence.

### **xADDomainTrust**

* **Ensure**: Specifies whether the domain trust is present or absent
* **TargetDomainAdministratorCredential**: Credentials to authenticate to the target domain
* **TargetDomainName**: Name of the AD domain that is being trusted
* **TrustType**: Type of trust
* **TrustDirection**: Direction of trust, the values for which may be Bidirectional,Inbound, or Outbound
* **SourceDomainName**: Name of the AD domain that is requesting the trust

### **xADRecycleBin**

The xADRecycleBin DSC resource will enable the Active Directory Recycle Bin feature for the target forest.
This resource first verifies that the forest mode is Windows Server 2008 R2 or greater.  If the forest mode
is insufficient, then the resource will exit with an error message.  The change is executed against the
Domain Naming Master FSMO of the forest.
(Note: This resource is compatible with a Windows 2008 R2 or above target node.)

* **ForestFQDN**:  Fully qualified domain name of forest to enable Active Directory Recycle Bin.
* **EnterpriseAdministratorCredential**:  Credential with Enterprise Administrator rights to the forest.
* **RecycleBinEnabled**:  Read-only. Returned by Get.
* **ForestMode**:  Read-only. Returned by Get.

### **xADGroup**

The xADGroup DSC resource will manage groups within Active Directory.

* **GroupName**: Name of the Active Directory group to manage.
* **Category**: This parameter sets the GroupCategory property of the group.
  * Valid values are 'Security' and 'Distribution'.
  * If not specified, it defaults to 'Security'.
* **GroupScope**: Specifies the group scope of the group.
  * Valid values are 'DomainLocal', 'Global' and 'Universal'.
  * If not specified, it defaults to 'Global'.
* **Path**: Path in Active Directory to place the group, specified as a Distinguished Name (DN).
* **Description**: Specifies a description of the group object (optional).
* **DisplayName**: Specifies the display name of the group object (optional).
* **Members**: Specifies the explicit AD objects that should comprise the group membership (optional).
  * If not specified, no group membership changes are made.
  * If specified, all undefined group members will be removed the AD group.
  * This property cannot be specified with either 'MembersToInclude' or 'MembersToExclude'.
* **MembersToInclude**: Specifies AD objects that must be in the group (optional).
  * If not specified, no group membership changes are made.
  * If specified, only the specified members are added to the group.
  * If specified, no users are removed from the group using this parameter.
  * This property cannot be specified with the 'Members' parameter.
* **MembersToExclude**: Specifies AD objects that _must not_ be in the group (optional).
  * If not specified, no group membership changes are made.
  * If specified, only those specified are removed from the group.
  * If specified, no users are added to the group using this parameter.
  * This property cannot be specified with the 'Members' parameter.
* **MembershipAttribute**: Defines the AD object attribute that is used to determine group membership (optional).
  * Valid values are 'SamAccountName', 'DistinguishedName', 'ObjectGUID' and 'SID'.
  * If not specified, it defaults to 'SamAccountName'.
  * You cannot mix multiple attribute types.
* **ManagedBy**: Specifies the user or group that manages the group object (optional).
  * Valid values are the user's or group's DistinguishedName, ObjectGUID, SID or SamAccountName.
* **Notes**: The group's info attribute (optional).
* **Ensure**: Specifies whether the group is present or absent.
  * Valid values are 'Present' and 'Absent'.
  * It not specified, it defaults to 'Present'.
* **DomainController**: An existing Active Directory domain controller used to perform the operation (optional).
  * If not running on a domain controller, this is required.
* **Credential**: User account credentials used to perform the operation (optional).
  * If not running on a domain controller, this is required.

### **xADOrganizationalUnit**

The xADOrganizational Unit DSC resource will manage OUs within Active Directory.

* **Name**: Name of the Active Directory organizational unit to manage.
* **Path**: Specified the X500 (DN) path of the organizational unit's parent object.
* **Description**: The OU description property (optional).
* **ProtectedFromAccidentalDeletion**: Valid values are $true and $false. If not specified, it defaults to $true.
* **Ensure**: Specifies whether the OU is present or absent. Valid values are 'Present' and 'Absent'. It not specified, it defaults to 'Present'.
* **Credential**: User account credentials used to perform the operation (optional). Note: _if not running on a domain controller, this is required_.

### **xADDomainDefaultPasswordPolicy**

The xADDomainDefaultPasswordPolicy DSC resource will manage an Active Directory domain's default password policy.

* **DomainName**: Name of the domain to which the password policy will be applied.
* **ComplexityEnabled**: Whether password complexity is enabled for the default password policy.
* **LockoutDuration**: Length of time that an account is locked after the number of failed login attempts (minutes).
* **LockoutObservationWindow**: Maximum time between two unsuccessful login attempts before the counter is reset to 0 (minutes).
* **LockoutThreshold**: Number of unsuccessful login attempts that are permitted before an account is locked out.
* **MinPasswordAge**: Minimum length of time that you can have the same password (minutes).
* **MaxPasswordAge**: Maximum length of time that you can have the same password (minutes).
* **MinPasswordLength**: Minimum number of characters that a password must contain.
* **PasswordHistoryCount**: Number of previous passwords to remember.
* **ReversibleEncryptionEnabled**: Whether the directory must store passwords using reversible encryption.
* **DomainController**: An existing Active Directory domain controller used to perform the operation (optional).
* **Credential**: User account credentials used to perform the operation (optional).

### **xADServicePrincipalName**

The xADServicePrincipalName DSC resource will manage service principal names.

* **Ensure**: Specifies if the service principal name should be added or remove. Default value is 'Present'. { *Present* | Absent }.
* **ServicePrincipalName**: The full SPN to add or remove, e.g. HOST/LON-DC1.
* **Account**: The user or computer account to add or remove the SPN, e.b. User1 or LON-DC1$. Default value is ''. If Ensure is set to Present, a value must be specified.

### **xADComputer**

The xADComputer DSC resource will manage computer accounts within Active Directory.

* **ComputerName**: Specifies the name of the computer to manage.
* **Location**: Specifies the location of the computer, such as an office number (optional).
* **DnsHostName**: Specifies the fully qualified domain name (FQDN) of the computer (optional).
* **ServicePrincipalNames**: Specifies the service principal names for the computer account (optional).
* **UserPrincipalName** :Specifies the UPN assigned to the computer account (optional).
* **DisplayName**: "Specifies the display name of the computer (optional).
* **Path**: Specifies the X.500 path of the container where the computer is located (optional).
* **Description**: Specifies a description of the computer object (optional).
* **Enabled**: Specifies if the computer account is enabled (optional).
* **Manager**: Specifies the user or group Distinguished Name that manages the computer object (optional).
  * Valid values are the user's or group's DistinguishedName, ObjectGUID, SID or SamAccountName.
* **DomainController**: Specifies the Active Directory Domain Services instance to connect to perform the task (optional).
* **DomainAdministratorCredential**: Specifies the user account credentials to use to perform the task (optional).
* **RequestFile**: Specifies the full path to the Offline Domain Join Request file to create (optional).
* **Ensure**: Specifies whether the computer account is present or absent.
  * Valid values are 'Present' and 'Absent'.
  * It not specified, it defaults to 'Present'.
* **DistinguishedName**: Returns the X.500 path of the computer object (read-only).
* **SID**: Returns the security identifier of the computer object (read-only).

Note: An ODJ Request file will only be created when a computer account is first created in the domain.
Setting an ODJ Request file path for a configuration that creates a computer account that already exists will not cause the file to be created.

## Versions

### Unreleased

### 2.17.0.0

* Converted AppVeyor.yml to use DSCResource.tests shared code.
* Opted-In to markdown rule validation.
* Readme.md modified resolve markdown rule violations.
* Added CodeCov.io support.
* Added xADServicePrincipalName resource.

### 2.16.0.0

* xAdDomainController: Update to complete fix for SiteName being required field.
* xADDomain: Added retry logic to prevent FaultException to crash in Get-TargetResource on subsequent reboots after a domain is created because the service is not yet running. This error is mostly occur when the resource is used with the DSCExtension on Azure.

### 2.15.0.0

* xAdDomainController: Fixes SiteName being required field.

### 2.14.0.0

* xADDomainController: Adds Site option.
* xADDomainController: Populate values for DatabasePath, LogPath and SysvolPath during Get-TargetResource.

### 2.13.0.0

* Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey
* xADUser: Adds 'PasswordAuthentication' option when testing user passwords to support NTLM authentication with Active Directory Certificate Services deployments
* xADUser: Adds descriptions to user properties within the schema file.
* xADGroup: Fixes bug when updating groups when alternate Credentials are specified.

### 2.12.0.0

* xADDomainController: Customer identified two cases of incorrect variables being called in Verbose output messages. Corrected.
* xADComputer: New resource added.
* xADComputer: Added RequestFile support.
* Fixed PSScriptAnalyzer Errors with v1.6.0.

### 2.11.0.0

* xWaitForADDomain: Made explicit credentials optional and other various updates

### 2.10.0.0

* xADDomainDefaultPasswordPolicy: New resource added.
* xWaitForADDomain: Updated to make it compatible with systems that don't have the ActiveDirectory module installed, and to allow it to function with domains/forests that don't have a domain controller with Active Directory Web Services running.
* xADGroup: Fixed bug where specified credentials were not used to retrieve existing group membership.
* xADDomain: Added check for Active Directory cmdlets.
* xADDomain: Added additional error trapping, verbose and diagnostic information.
* xADDomain: Added unit test coverage.
* Fixes CredentialAttribute and other PSScriptAnalyzer tests in xADCommon, xADDomin, xADGroup, xADOrganizationalUnit and xADUser resources.

### 2.9.0.0

* xADOrganizationalUnit: Merges xADOrganizationalUnit resource from the PowerShell gallery
* xADGroup: Added Members, MembersToInclude, MembersToExclude and MembershipAttribute properties.
* xADGroup: Added ManagedBy property.
* xADGroup: Added Notes property.
* xADUser: Adds additional property settings.
* xADUser: Adds unit test coverage.

### 2.8.0.0

* Added new resource: xADGroup
* Fixed issue with NewDomainNetbiosName parameter.

### 2.7.0.0

* Added DNS flush in retry loop
* Bug fixes in xADDomain resource

### 2.6.0.0

* Removed xDscResourceDesigner tests (moved to common tests)

### 2.5.0.0

* Updated xADDomainTrust and xADRecycleBin tests

### 2.4.0.0

* Added xADRecycleBin resource
* Minor fixes for xADUser resource

### 2.3

* Added xADRecycleBin.
* Modified xADUser to include a write-verbose after user is removed when Absent.
* Corrected xADUser to successfully create a disabled user without a password.

### 2.2

* Modified xAdDomain and xAdDomainController to support Ensure as Present / Absent, rather than True/False.
  Note: this may cause issues for existing scripts.
* Corrected return value to be a hashtable in both resources.

### 2.1.0.0

* Minor update: Get-TargetResource to use domain name instead of name.

### 2.0.0.0

* Updated release, which added the resource:
  * xADDomainTrust

### 1.0.0.0

* Initial release with the following resources:
  * xADDomain, xADDomainController, xADUser, and xWaitForDomain

## Examples

### Create a highly available Domain using multiple domain controllers

In the following example configuration, a highly available domain is created by adding a domain controller to an existing domain.
This example uses the xWaitForDomain resource to ensure that the domain is present before the second domain controller is added.

```powershell
# A configuration to Create High Availability Domain Controller
Configuration AssertHADC
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred,
        [Parameter(Mandatory)]
        [pscredential]$DNSDelegationCred,
        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
    )
    Import-DscResource -ModuleName xActiveDirectory
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }
        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $DNSDelegationCred
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }
        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName = "dummy"
            Password = $NewADUserCred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
    Node $AllNodes.Where{$_.Role -eq "Replica DC"}.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $DNSDelegationCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}
# Configuration Data for AD
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "dsc-testNode1"
            Role = "Primary DC"
            DomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 20
            RetryIntervalSec = 30
        },
        @{
            Nodename = "dsc-testNode2"
            Role = "Replica DC"
            DomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 20
            RetryIntervalSec = 30
        }
    )
}
AssertHADC -configurationData $ConfigData `
-safemodeAdministratorCred (Get-Credential -Message "New Domain Safe Mode Admin Credentials") `
-domainCred (Get-Credential -Message "New Domain Admin Credentials") `
-DNSDelegationCred (Get-Credential -Message "Credentials to Setup DNS Delegation") `
-NewADUserCred (Get-Credential -Message "New AD User Credentials")
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode1" -Path $PSScriptRoot\AssertHADC `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode2" -Path $PSScriptRoot\AssertHADC `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
# A configuration to Create High Availability Domain Controller

Configuration AssertHADC
{

   param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,

        [Parameter(Mandatory)]
        [pscredential]$domainCred,

        [Parameter(Mandatory)]
        [pscredential]$DNSDelegationCred,

        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
    )

    Import-DscResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $DNSDelegationCred
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName = "dummy"
            Password = $NewADUserCred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

    }

    Node $AllNodes.Where{$_.Role -eq "Replica DC"}.Nodename
    {
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $DNSDelegationCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}

# Configuration Data for AD

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "dsc-testNode1"
            Role = "Primary DC"
            DomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 20
            RetryIntervalSec = 30
        },

        @{
            Nodename = "dsc-testNode2"
            Role = "Replica DC"
            DomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 20
            RetryIntervalSec = 30
        }
    )
}

AssertHADC -configurationData $ConfigData `
-safemodeAdministratorCred (Get-Credential -Message "New Domain Safe Mode Admin Credentials") `
-domainCred (Get-Credential -Message "New Domain Admin Credentials") `
-DNSDelegationCred (Get-Credential -Message "Credentials to Setup DNS Delegation") `
-NewADUserCred (Get-Credential -Message "New AD User Credentials")

Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode1" -Path $PSScriptRoot\AssertHADC `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")

Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode2" -Path $PSScriptRoot\AssertHADC `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
```

### Create a child domain under a parent domain

In this example, we create a domain, and then create a child domain on another node.

```powershell
# Configuration to Setup Parent Child Domains

Configuration AssertParentChildDomains
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,

        [Parameter(Mandatory)]
        [pscredential]$domainCred,

        [Parameter(Mandatory)]
        [pscredential]$DNSDelegationCred,

        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
    )

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
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $DNSDelegationCred
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            UserName = "dummy"
            Password = $NewADUserCred
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
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomain ChildDS
        {
            DomainName = $Node.DomainName
            ParentDomainName = $Node.ParentDomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}

$ConfigData = @{

    AllNodes = @(
        @{
            Nodename = "dsc-testNode1"
            Role = "Parent DC"
            DomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 50
            RetryIntervalSec = 30
        },

        @{
            Nodename = "dsc-testNode2"
            Role = "Child DC"
            DomainName = "dsc-child"
            ParentDomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 50
            RetryIntervalSec = 30
        }
    )
}

AssertParentChildDomains -configurationData $ConfigData `
-safemodeAdministratorCred (Get-Credential -Message "New Domain Safe Mode Admin Credentials") `
-domainCred (Get-Credential -Message "New Domain Admin Credentials") `
-DNSDelegationCred (Get-Credential -Message "Credentials to Setup DNS Delegation") `
-NewADUserCred (Get-Credential -Message "New AD User Credentials")


Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode1" -Path $PSScriptRoot\AssertParentChildDomains `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode2" -Path $PSScriptRoot\AssertParentChildDomains `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
```

### Create a cross-domain trust

In this example, we setup one-way trust between two domains.

```powershell
Configuration Sample_xADDomainTrust_OneWayTrust
{
    param
    (
        [Parameter(Mandatory)]
        [String]$SourceDomain,
        [Parameter(Mandatory)]
        [String]$TargetDomain,

        [Parameter(Mandatory)]
        [PSCredential]$TargetDomainAdminCred,
        [Parameter(Mandatory)]
        [String]$TrustDirection
    )
    Import-DscResource -module xActiveDirectory
    Node $AllNodes.Where{$_.Role -eq 'DomainController'}.NodeName
    {
        xADDomainTrust trust
        {
            Ensure                              = 'Present'
            SourceDomainName                    = $SourceDomain
            TargetDomainName                    = $TargetDomain
            TargetDomainAdministratorCredential = $TargetDomainAdminCred
            TrustDirection                      = $TrustDirection
            TrustType                           = 'External'
        }
    }
}
$config = @{
    AllNodes = @(
        @{
            NodeName      = 'localhost'
            Role          = 'DomainController'
            # Certificate Thumbprint that is used to encrypt/decrypt the credential
            CertificateID = 'B9192121495A307A492A19F6344E8752B51AC4A6'
        }
    )
}
Sample_xADDomainTrust_OneWayTrust -configurationdata $config `
                                  -SourceDomain safeharbor.contoso.com `
                                  -TargetDomain corporate.contoso.com `
                                  -TargetDomainAdminCred (get-credential) `
                                  -TrustDirection 'Inbound'
# Configuration to Setup Parent Child Domains
```

```powershell
configuration AssertParentChildDomains
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,

        [Parameter(Mandatory)]
        [pscredential]$domainCred,

        [Parameter(Mandatory)]
        [pscredential]$DNSDelegationCred,

        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
    )

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
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DnsDelegationCredential = $DNSDelegationCred
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            UserName = "dummy"
            Password = $NewADUserCred
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
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomain ChildDS
        {
            DomainName = $Node.DomainName
            ParentDomainName = $Node.ParentDomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}

$ConfigData = @{

    AllNodes = @(
        @{
            Nodename = "dsc-testNode1"
            Role = "Parent DC"
            DomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 50
            RetryIntervalSec = 30
        },

        @{
            Nodename = "dsc-testNode2"
            Role = "Child DC"
            DomainName = "dsc-child"
            ParentDomainName = "dsc-test.contoso.com"
            CertificateFile = "C:\publicKeys\targetNode.cer"
            Thumbprint = "AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8"
            RetryCount = 50
            RetryIntervalSec = 30
        }
    )
}

AssertParentChildDomains -configurationData $ConfigData `
-safemodeAdministratorCred (Get-Credential -Message "New Domain Safe Mode Admin Credentials") `
-domainCred (Get-Credential -Message "New Domain Admin Credentials") `
-DNSDelegationCred (Get-Credential -Message "Credentials to Setup DNS Delegation") `
-NewADUserCred (Get-Credential -Message "New AD User Credentials")


Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode1" -Path $PSScriptRoot\AssertParentChildDomains `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "dsc-testNode2" -Path $PSScriptRoot\AssertParentChildDomains `
-Credential (Get-Credential -Message "Local Admin Credentials on Remote Machine")
```

### Enable the Active Directory Recycle Bin

In this example, we enable the Active Directory Recycle Bin.

```powershell
Configuration Example_xADRecycleBin
{
Param(
    [parameter(Mandatory = $true)]
    [System.String]
    $ForestFQDN,

    [parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $EACredential
)

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADRecycleBin RecycleBin
        {
           EnterpriseAdministratorCredential = $EACredential
           ForestFQDN = $ForestFQDN
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = '2012r2-dc'
        }
    )
}

Example_xADRecycleBin -EACredential (Get-Credential contoso\administrator) -ForestFQDN 'contoso.com' -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADRecycleBin -Wait -Verbose
```

### Create an Active Directory group

In this example, we add an Active Directory group to the default container (normally the Users OU).

```powershell
configuration Example_xADGroup
{
Param(
    [parameter(Mandatory = $true)]
    [System.String]
    $GroupName,

    [ValidateSet('DomainLocal','Global','Universal')]
    [System.String]
    $Scope = 'Global',

    [ValidateSet('Security','Distribution')]
    [System.String]
    $Category = 'Security',

    [ValidateNotNullOrEmpty()]
    [System.String]
    $Description
)

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADGroup ExampleGroup
        {
           GroupName = $GroupName
           GroupScope = $Scope
           Category = $Category
           Description = $Description
           Ensure = 'Present'
        }
    }
}

Example_xADGroup -GroupName 'TestGroup' -Scope 'DomainLocal' -Description 'Example test domain local security group' -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADGroup -Wait -Verbose
```

### Create an Active Directory OU

In this example, we add an Active Directory organizational unit to the 'example.com' domain root.

```powershell
configuration Example_xADOrganizationalUnit
{
Param(
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [System.String]
    $Path,

    [System.Boolean]
    $ProtectedFromAccidentalDeletion = $true,

    [ValidateNotNull()]
    [System.String]
    $Description = ''
)

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADOrganizationalUnit ExampleOU
        {
           Name = $Name
           Path = $Path
           ProtectedFromAccidentalDeletion = $ProtectedFromAccidentalDeletion
           Description = $Description
           Ensure = 'Present'
        }
    }
}

Example_xADOrganizationalUnit -Name 'Example OU' -Path 'dc=example,dc=com' -Description 'Example test organizational unit' -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADOrganizationalUnit -Wait -Verbose

```

### Configure Active Directory Domain Default Password Policy

In this example, we configure an Active Directory domain's default password policy to set the minimum password length and complexity.

```powershell
configuration Example_xADDomainDefaultPasswordPolicy
{
    Param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainName,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $ComplexityEnabled,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $MinPasswordLength,
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADDomainDefaultPasswordPolicy 'DefaultPasswordPolicy'
        {
           DomainName = $DomainName
           ComplexityEnabled = $ComplexityEnabled
           MinPasswordLength = $MinPasswordLength
        }
    }
}

Example_xADDomainDefaultPasswordPolicy -DomainName 'contoso.com' -ComplexityEnabled $true -MinPasswordLength 8

Start-DscConfiguration -Path .\Example_xADDomainDefaultPasswordPolicy -Wait -Verbose
```

### Create an Active Directory Computer Account

In this example, we create a 'NANO-001' computer account in the 'Server' OU of the 'example.com' Active Directory domain.

```powershell
configuration Example_xADComputerAccount
{
    Param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainController,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADComputer "$ComputerName"
        {
           DomainController = $DomainController
           DomainAdministratorCredential = $DomainCredential
           ComputerName = $ComputerName
           Path = $Path
        }
    }
}

Example_xADComputerAccount -DomainController 'DC01' `
    -DomainCredential (Get-Credential -Message "Domain Credentials") `
    -ComputerName 'NANO-001' `
    -Path 'ou=Servers,dc=example,dc=com' `
    -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADComputerAccount -Wait -Verbose
```

### Create an Active Directory Computer Account and an ODJ Request File

In this example, we create a 'NANO-200' computer account in the 'Nano' OU of the 'example.com' Active Directory domain as well as creating an Offline Domain Join Request file.

```powershell
configuration Example_xADComputerAccountODJ
{
    Param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $DomainController,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [parameter(Mandatory = $true)]
        [System.String]
        $RequestFile
    )

    Import-DscResource -Module xActiveDirectory

    Node $AllNodes.NodeName
    {
        xADComputer "$ComputerName"
        {
           DomainController = $DomainController
           DomainAdministratorCredential = $DomainCredential
           ComputerName = $ComputerName
           Path = $Path
           RequestFile = $RequestFile
        }
    }
}

Example_xADComputerAccountODJ -DomainController 'DC01' `
    -DomainCredential (Get-Credential -Message "Domain Credentials") `
    -ComputerName 'NANO-200' `
    -Path 'ou=Nano,dc=example,dc=com' `
    -RequestFile 'd:\ODJFiles\NANO-200.txt' `
    -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path .\Example_xADComputerAccount -Wait -Verbose
```
