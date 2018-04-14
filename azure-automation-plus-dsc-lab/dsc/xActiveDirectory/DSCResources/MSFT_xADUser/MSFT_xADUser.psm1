[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
param()

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        RoleNotFoundError              = Please ensure that the PowerShell module for role '{0}' is installed.
        RetrievingADUserError          = Error looking up Active Directory user '{0}' ({0}@{1}).
        PasswordParameterConflictError = Parameter '{0}' cannot be set to '{1}' when the '{2}' parameter is specified.

        RetrievingADUser               = Retrieving Active Directory user '{0}' ({0}@{1}) ...
        CreatingADDomainConnection     = Creating connection to Active Directory domain '{0}' ...
        CheckingADUserPassword         = Checking Active Directory user '{0}' password ...
        ADUserIsPresent                = Active Directory user '{0}' ({0}@{1}) is present.
        ADUserNotPresent               = Active Directory user '{0}' ({0}@{1}) was NOT present.
        ADUserNotDesiredPropertyState  = User '{0}' property is NOT in the desired state. Expected '{1}', actual '{2}'.

        AddingADUser                   = Adding Active Directory user '{0}'.
        RemovingADUser                 = Removing Active Directory user '{0}'.
        UpdatingADUser                 = Updating Active Directory user '{0}'.
        SettingADUserPassword          = Setting Active Directory user password.
        UpdatingADUserProperty         = Updating user property '{0}' with/to '{1}'.
        RemovingADUserProperty         = Removing user property '{0}' with '{1}'.
        MovingADUser                   = Moving user from '{0}' to '{1}'.
        RenamingADUser                 = Renaming user from '{0}' to '{1}'.
'@
}

## Create a property map that maps the DSC resource parameters to the
## Active Directory user attributes.
$adPropertyMap = @(
    @{ Parameter = 'CommonName'; ADProperty = 'cn'; }
    @{ Parameter = 'UserPrincipalName'; }
    @{ Parameter = 'DisplayName'; }
    @{ Parameter = 'Path'; ADProperty = 'distinguishedName'; }
    @{ Parameter = 'GivenName'; }
    @{ Parameter = 'Initials'; }
    @{ Parameter = 'Surname'; ADProperty = 'sn'; }
    @{ Parameter = 'Description'; }
    @{ Parameter = 'StreetAddress'; }
    @{ Parameter = 'POBox'; }
    @{ Parameter = 'City'; ADProperty = 'l'; }
    @{ Parameter = 'State'; ADProperty = 'st'; }
    @{ Parameter = 'PostalCode'; }
    @{ Parameter = 'Country'; ADProperty = 'c'; }
    @{ Parameter = 'Department'; }
    @{ Parameter = 'Division'; }
    @{ Parameter = 'Company'; }
    @{ Parameter = 'Office'; ADProperty = 'physicalDeliveryOfficeName'; }
    @{ Parameter = 'JobTitle'; ADProperty = 'title'; }
    @{ Parameter = 'EmailAddress'; ADProperty = 'mail'; }
    @{ Parameter = 'EmployeeID'; }
    @{ Parameter = 'EmployeeNumber'; }
    @{ Parameter = 'HomeDirectory'; }
    @{ Parameter = 'HomeDrive'; }
    @{ Parameter = 'HomePage'; ADProperty = 'wWWHomePage'; }
    @{ Parameter = 'ProfilePath'; }
    @{ Parameter = 'LogonScript'; ADProperty = 'scriptPath'; }
    @{ Parameter = 'Notes'; ADProperty = 'info'; }
    @{ Parameter = 'OfficePhone'; ADProperty = 'telephoneNumber'; }
    @{ Parameter = 'MobilePhone'; ADProperty = 'mobile'; }
    @{ Parameter = 'Fax'; ADProperty = 'facsimileTelephoneNumber'; }
    @{ Parameter = 'Pager'; }
    @{ Parameter = 'IPPhone'; }
    @{ Parameter = 'HomePhone'; }
    @{ Parameter = 'Enabled'; }
    @{ Parameter = 'Manager'; }
    @{ Parameter = 'PasswordNeverExpires'; UseCmdletParameter = $true; }
    @{ Parameter = 'CannotChangePassword'; UseCmdletParameter = $true; }
)

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        ## Name of the domain where the user account is located (only used if password is managed)
        [Parameter(Mandatory)]
        [System.String] $DomainName,

        # Specifies the Security Account Manager (SAM) account name of the user (ldapDisplayName 'sAMAccountName')
        [Parameter(Mandatory)]
        [System.String] $UserName,

        ## Specifies a new password value for an account
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        ## Specifies whether the user account is created or deleted
        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present',

        ## Specifies the common nane assigned to the user account (ldapDisplayName 'cn')
        [ValidateNotNull()]
        [System.String] $CommonName = $UserName,

        ## Specifies the UPN assigned to the user account (ldapDisplayName 'userPrincipalName')
        [ValidateNotNull()]
        [System.String] $UserPrincipalName,

        ## Specifies the display name of the object (ldapDisplayName 'displayName')
        [ValidateNotNull()]
        [System.String] $DisplayName,

        ## Specifies the X.500 path of the Organizational Unit (OU) or container where the new object is created
        [ValidateNotNull()]
        [System.String] $Path,

        ## Specifies the user's given name (ldapDisplayName 'givenName')
        [ValidateNotNull()]
        [System.String] $GivenName,

        ## Specifies the initials that represent part of a user's name (ldapDisplayName 'initials')
        [ValidateNotNull()]
        [System.String] $Initials,

        ## Specifies the user's last name or surname (ldapDisplayName 'sn')
        [ValidateNotNull()]
        [System.String] $Surname,

        ## Specifies a description of the object (ldapDisplayName 'description')
        [ValidateNotNull()]
        [System.String] $Description,

        ## Specifies the user's street address (ldapDisplayName 'streetAddress')
        [ValidateNotNull()]
        [System.String] $StreetAddress,

        ## Specifies the user's post office box number (ldapDisplayName 'postOfficeBox')
        [ValidateNotNull()]
        [System.String] $POBox,

        ## Specifies the user's town or city (ldapDisplayName 'l')
        [ValidateNotNull()]
        [System.String] $City,

        ## Specifies the user's or Organizational Unit's state or province (ldapDisplayName 'st')
        [ValidateNotNull()]
        [System.String] $State,

        ## Specifies the user's postal code or zip code (ldapDisplayName 'postalCode')
        [ValidateNotNull()]
        [System.String] $PostalCode,

        ## Specifies the country or region code for the user's language of choice (ldapDisplayName 'c')
        [ValidateNotNull()]
        [System.String] $Country,

        ## Specifies the user's department (ldapDisplayName 'department')
        [ValidateNotNull()]
        [System.String] $Department,

        ## Specifies the user's division (ldapDisplayName 'division')
        [ValidateNotNull()]
        [System.String] $Division,

        ## Specifies the user's company (ldapDisplayName 'company')
        [ValidateNotNull()]
        [System.String] $Company,

        ## Specifies the location of the user's office or place of business (ldapDisplayName 'physicalDeliveryOfficeName')
        [ValidateNotNull()]
        [System.String] $Office,

        ## Specifies the user's title (ldapDisplayName 'title')
        [ValidateNotNull()]
        [System.String] $JobTitle,

        ## Specifies the user's e-mail address (ldapDisplayName 'mail')
        [ValidateNotNull()]
        [System.String] $EmailAddress,

        ## Specifies the user's employee ID (ldapDisplayName 'employeeID')
        [ValidateNotNull()]
        [System.String] $EmployeeID,

        ## Specifies the user's employee number (ldapDisplayName 'employeeNumber')
        [ValidateNotNull()]
        [System.String] $EmployeeNumber,

        ## Specifies a user's home directory path (ldapDisplayName 'homeDirectory')
        [ValidateNotNull()]
        [System.String] $HomeDirectory,

        ## Specifies a drive that is associated with the UNC path defined by the HomeDirectory property (ldapDisplayName 'homeDrive')
        [ValidateNotNull()]
        [System.String] $HomeDrive,

        ## Specifies the URL of the home page of the object (ldapDisplayName 'wWWHomePage')
        [ValidateNotNull()]
        [System.String] $HomePage,

        ## Specifies a path to the user's profile (ldapDisplayName 'profilePath')
        [ValidateNotNull()]
        [System.String] $ProfilePath,

        ## Specifies a path to the user's log on script (ldapDisplayName 'scriptPath')
        [ValidateNotNull()]
        [System.String] $LogonScript,

        ## Specifies the notes attached to the user's accoutn (ldapDisplayName 'info')
        [ValidateNotNull()]
        [System.String] $Notes,

        ## Specifies the user's office telephone number (ldapDisplayName 'telephoneNumber')
        [ValidateNotNull()]
        [System.String] $OfficePhone,

        ## Specifies the user's mobile phone number (ldapDisplayName 'mobile')
        [ValidateNotNull()]
        [System.String] $MobilePhone,

        ## Specifies the user's fax phone number (ldapDisplayName 'facsimileTelephoneNumber')
        [ValidateNotNull()]
        [System.String] $Fax,

        ## Specifies the user's home telephone number (ldapDisplayName 'homePhone')
        [ValidateNotNull()]
        [System.String] $HomePhone,

         ## Specifies the user's pager number (ldapDisplayName 'pager')
        [ValidateNotNull()]
        [System.String] $Pager,

        ## Specifies the user's IP telephony phone number (ldapDisplayName 'ipPhone')
        [ValidateNotNull()]
        [System.String] $IPPhone,

        ## Specifies the user's manager specified as a Distinguished Name (ldapDisplayName 'manager')
        [ValidateNotNull()]
        [System.String] $Manager,

        ## Specifies if the account is enabled (default True)
        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        ## Specifies whether the account password can be changed
        [ValidateNotNull()]
        [System.Boolean] $CannotChangePassword,

        ## Specifies whether the password of an account can expire
        [ValidateNotNull()]
        [System.Boolean] $PasswordNeverExpires,

        ## Specifies the Active Directory Domain Services instance to use to perform the task.
        [ValidateNotNull()]
        [System.String] $DomainController,

        ## Specifies the user account credentials to use to perform this task. Ideally this should just be called 'Credential' but is here for backwards compatibility
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential,

        ## Specifies the authentication context type when testing user passwords #61
        [ValidateSet('Default','Negotiate')]
        [System.String] $PasswordAuthentication = 'Default'
    )

    Assert-Module -ModuleName 'ActiveDirectory';

    try
    {
        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;

        $adProperties = @();
        ## Create an array of the AD propertie names to retrieve from the property map
        foreach ($property in $adPropertyMap)
        {
            if ($property.ADProperty)
            {
                $adProperties += $property.ADProperty;
            }
            else
            {
                $adProperties += $property.Parameter;
            }
        }

        Write-Verbose -Message ($LocalizedData.RetrievingADUser -f $UserName, $DomainName);
        $adUser = Get-ADUser @adCommonParameters -Properties $adProperties;
        Write-Verbose -Message ($LocalizedData.ADUserIsPresent -f $UserName, $DomainName);
        $Ensure = 'Present';
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message ($LocalizedData.ADUserNotPresent -f $UserName, $DomainName);
        $Ensure = 'Absent';
    }
    catch
    {
        Write-Error -Message ($LocalizedData.RetrievingADUserError -f $UserName, $DomainName);
        throw $_;
    }

    $targetResource = @{
        DomainName        = $DomainName;
        Password          = $Password;
        UserName          = $UserName;
        DistinguishedName = $adUser.DistinguishedName; ## Read-only property
        Ensure            = $Ensure;
        DomainController  = $DomainController;
    }

    ## Retrieve each property from the ADPropertyMap and add to the hashtable
    foreach ($property in $adPropertyMap)
    {
        if ($property.Parameter -eq 'Path') {
            ## The path returned is not the parent container
            if (-not [System.String]::IsNullOrEmpty($adUser.DistinguishedName))
            {
                $targetResource['Path'] = Get-ADObjectParentDN -DN $adUser.DistinguishedName;
            }
        }
        elseif ($property.ADProperty)
        {
            ## The AD property name is different to the function parameter to use this
            $targetResource[$property.Parameter] = $adUser.($property.ADProperty);
        }
        else
        {
            ## The AD property name matches the function parameter
            $targetResource[$property.Parameter] = $adUser.($property.Parameter);
        }
    }
    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        ## Name of the domain where the user account is located (only used if password is managed)
        [Parameter(Mandatory)]
        [System.String] $DomainName,

        # Specifies the Security Account Manager (SAM) account name of the user (ldapDisplayName 'sAMAccountName')
        [Parameter(Mandatory)]
        [System.String] $UserName,

        ## Specifies a new password value for an account
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        ## Specifies whether the user account is created or deleted
        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present',

        ## Specifies the common nane assigned to the user account (ldapDisplayName 'cn')
        [ValidateNotNull()]
        [System.String] $CommonName = $UserName,

        ## Specifies the UPN assigned to the user account (ldapDisplayName 'userPrincipalName')
        [ValidateNotNull()]
        [System.String] $UserPrincipalName,

        ## Specifies the display name of the object (ldapDisplayName 'displayName')
        [ValidateNotNull()]
        [System.String] $DisplayName,

        ## Specifies the X.500 path of the Organizational Unit (OU) or container where the new object is created
        [ValidateNotNull()]
        [System.String] $Path,

        ## Specifies the user's given name (ldapDisplayName 'givenName')
        [ValidateNotNull()]
        [System.String] $GivenName,

        ## Specifies the initials that represent part of a user's name (ldapDisplayName 'initials')
        [ValidateNotNull()]
        [System.String] $Initials,

        ## Specifies the user's last name or surname (ldapDisplayName 'sn')
        [ValidateNotNull()]
        [System.String] $Surname,

        ## Specifies a description of the object (ldapDisplayName 'description')
        [ValidateNotNull()]
        [System.String] $Description,

        ## Specifies the user's street address (ldapDisplayName 'streetAddress')
        [ValidateNotNull()]
        [System.String] $StreetAddress,

        ## Specifies the user's post office box number (ldapDisplayName 'postOfficeBox')
        [ValidateNotNull()]
        [System.String] $POBox,

        ## Specifies the user's town or city (ldapDisplayName 'l')
        [ValidateNotNull()]
        [System.String] $City,

        ## Specifies the user's or Organizational Unit's state or province (ldapDisplayName 'st')
        [ValidateNotNull()]
        [System.String] $State,

        ## Specifies the user's postal code or zip code (ldapDisplayName 'postalCode')
        [ValidateNotNull()]
        [System.String] $PostalCode,

        ## Specifies the country or region code for the user's language of choice (ldapDisplayName 'c')
        [ValidateNotNull()]
        [System.String] $Country,

        ## Specifies the user's department (ldapDisplayName 'department')
        [ValidateNotNull()]
        [System.String] $Department,

        ## Specifies the user's division (ldapDisplayName 'division')
        [ValidateNotNull()]
        [System.String] $Division,

        ## Specifies the user's company (ldapDisplayName 'company')
        [ValidateNotNull()]
        [System.String] $Company,

        ## Specifies the location of the user's office or place of business (ldapDisplayName 'physicalDeliveryOfficeName')
        [ValidateNotNull()]
        [System.String] $Office,

        ## Specifies the user's title (ldapDisplayName 'title')
        [ValidateNotNull()]
        [System.String] $JobTitle,

        ## Specifies the user's e-mail address (ldapDisplayName 'mail')
        [ValidateNotNull()]
        [System.String] $EmailAddress,

        ## Specifies the user's employee ID (ldapDisplayName 'employeeID')
        [ValidateNotNull()]
        [System.String] $EmployeeID,

        ## Specifies the user's employee number (ldapDisplayName 'employeeNumber')
        [ValidateNotNull()]
        [System.String] $EmployeeNumber,

        ## Specifies a user's home directory path (ldapDisplayName 'homeDirectory')
        [ValidateNotNull()]
        [System.String] $HomeDirectory,

        ## Specifies a drive that is associated with the UNC path defined by the HomeDirectory property (ldapDisplayName 'homeDrive')
        [ValidateNotNull()]
        [System.String] $HomeDrive,

        ## Specifies the URL of the home page of the object (ldapDisplayName 'wWWHomePage')
        [ValidateNotNull()]
        [System.String] $HomePage,

        ## Specifies a path to the user's profile (ldapDisplayName 'profilePath')
        [ValidateNotNull()]
        [System.String] $ProfilePath,

        ## Specifies a path to the user's log on script (ldapDisplayName 'scriptPath')
        [ValidateNotNull()]
        [System.String] $LogonScript,

        ## Specifies the notes attached to the user's accoutn (ldapDisplayName 'info')
        [ValidateNotNull()]
        [System.String] $Notes,

        ## Specifies the user's office telephone number (ldapDisplayName 'telephoneNumber')
        [ValidateNotNull()]
        [System.String] $OfficePhone,

        ## Specifies the user's mobile phone number (ldapDisplayName 'mobile')
        [ValidateNotNull()]
        [System.String] $MobilePhone,

        ## Specifies the user's fax phone number (ldapDisplayName 'facsimileTelephoneNumber')
        [ValidateNotNull()]
        [System.String] $Fax,

        ## Specifies the user's home telephone number (ldapDisplayName 'homePhone')
        [ValidateNotNull()]
        [System.String] $HomePhone,

         ## Specifies the user's pager number (ldapDisplayName 'pager')
        [ValidateNotNull()]
        [System.String] $Pager,

        ## Specifies the user's IP telephony phone number (ldapDisplayName 'ipPhone')
        [ValidateNotNull()]
        [System.String] $IPPhone,

        ## Specifies the user's manager specified as a Distinguished Name (ldapDisplayName 'manager')
        [ValidateNotNull()]
        [System.String] $Manager,

        ## Specifies if the account is enabled (default True)
        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        ## Specifies whether the account password can be changed
        [ValidateNotNull()]
        [System.Boolean] $CannotChangePassword,

        ## Specifies whether the password of an account can expire
        [ValidateNotNull()]
        [System.Boolean] $PasswordNeverExpires,

        ## Specifies the Active Directory Domain Services instance to use to perform the task.
        [ValidateNotNull()]
        [System.String] $DomainController,

        ## Specifies the user account credentials to use to perform this task. Ideally this should just be called 'Credential' but is here for backwards compatibility
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential,

        ## Specifies the authentication context type when testing user passwords #61
        [ValidateSet('Default','Negotiate')]
        [System.String] $PasswordAuthentication = 'Default'
    )

    Assert-Parameters @PSBoundParameters;
    $targetResource = Get-TargetResource @PSBoundParameters;
    $isCompliant = $true;

    if ($Ensure -eq 'Absent')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            Write-Verbose -Message ($LocalizedData.ADUserNotDesiredPropertyState -f 'Ensure', $PSBoundParameters.Ensure, $targetResource.Ensure);
            $isCompliant = $false;
        }
    }
    else
    {
        ## Add common name, ensure and enabled as they may not be explicitly passed and we want to enumerate them
        $PSBoundParameters['Ensure'] = $Ensure;
        $PSBoundParameters['Enabled'] = $Enabled;

        foreach ($parameter in $PSBoundParameters.Keys)
        {
            if ($parameter -eq 'Password')
            {
                $testPasswordParams = @{
                    Username = $UserName;
                    Password = $Password;
                    DomainName = $DomainName;
                    PasswordAuthentication = $PasswordAuthentication;
                }
                if ($DomainAdministratorCredential)
                {
                    $testPasswordParams['DomainAdministratorCredential'] = $DomainAdministratorCredential;
                }
                if (-not (Test-Password @testPasswordParams))
                {
                    Write-Verbose -Message ($LocalizedData.ADUserNotDesiredPropertyState -f 'Password', '<Password>', '<Password>');
                    $isCompliant = $false;
                }
            }
            # Only check properties that are returned by Get-TargetResource
            elseif ($targetResource.ContainsKey($parameter))
            {
                ## This check is required to be able to explicitly remove values with an empty string, if required
                if (([System.String]::IsNullOrEmpty($PSBoundParameters.$parameter)) -and ([System.String]::IsNullOrEmpty($targetResource.$parameter)))
                {
                    # Both values are null/empty and therefore we are compliant
                }
                elseif ($PSBoundParameters.$parameter -ne $targetResource.$parameter)
                {
                    Write-Verbose -Message ($LocalizedData.ADUserNotDesiredPropertyState -f $parameter, $PSBoundParameters.$parameter, $targetResource.$parameter);
                    $isCompliant = $false;
                }
            }
        } #end foreach PSBoundParameter
    }

    return $isCompliant;

} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        ## Name of the domain where the user account is located (only used if password is managed)
        [Parameter(Mandatory)]
        [System.String] $DomainName,

        # Specifies the Security Account Manager (SAM) account name of the user (ldapDisplayName 'sAMAccountName')
        [Parameter(Mandatory)]
        [System.String] $UserName,

        ## Specifies a new password value for an account
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        ## Specifies whether the user account is created or deleted
        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present',

        ## Specifies the common nane assigned to the user account (ldapDisplayName 'cn')
        [ValidateNotNull()]
        [System.String] $CommonName = $UserName,

        ## Specifies the UPN assigned to the user account (ldapDisplayName 'userPrincipalName')
        [ValidateNotNull()]
        [System.String] $UserPrincipalName,

        ## Specifies the display name of the object (ldapDisplayName 'displayName')
        [ValidateNotNull()]
        [System.String] $DisplayName,

        ## Specifies the X.500 path of the Organizational Unit (OU) or container where the new object is created
        [ValidateNotNull()]
        [System.String] $Path,

        ## Specifies the user's given name (ldapDisplayName 'givenName')
        [ValidateNotNull()]
        [System.String] $GivenName,

        ## Specifies the initials that represent part of a user's name (ldapDisplayName 'initials')
        [ValidateNotNull()]
        [System.String] $Initials,

        ## Specifies the user's last name or surname (ldapDisplayName 'sn')
        [ValidateNotNull()]
        [System.String] $Surname,

        ## Specifies a description of the object (ldapDisplayName 'description')
        [ValidateNotNull()]
        [System.String] $Description,

        ## Specifies the user's street address (ldapDisplayName 'streetAddress')
        [ValidateNotNull()]
        [System.String] $StreetAddress,

        ## Specifies the user's post office box number (ldapDisplayName 'postOfficeBox')
        [ValidateNotNull()]
        [System.String] $POBox,

        ## Specifies the user's town or city (ldapDisplayName 'l')
        [ValidateNotNull()]
        [System.String] $City,

        ## Specifies the user's or Organizational Unit's state or province (ldapDisplayName 'st')
        [ValidateNotNull()]
        [System.String] $State,

        ## Specifies the user's postal code or zip code (ldapDisplayName 'postalCode')
        [ValidateNotNull()]
        [System.String] $PostalCode,

        ## Specifies the country or region code for the user's language of choice (ldapDisplayName 'c')
        [ValidateNotNull()]
        [System.String] $Country,

        ## Specifies the user's department (ldapDisplayName 'department')
        [ValidateNotNull()]
        [System.String] $Department,

        ## Specifies the user's division (ldapDisplayName 'division')
        [ValidateNotNull()]
        [System.String] $Division,

        ## Specifies the user's company (ldapDisplayName 'company')
        [ValidateNotNull()]
        [System.String] $Company,

        ## Specifies the location of the user's office or place of business (ldapDisplayName 'physicalDeliveryOfficeName')
        [ValidateNotNull()]
        [System.String] $Office,

        ## Specifies the user's title (ldapDisplayName 'title')
        [ValidateNotNull()]
        [System.String] $JobTitle,

        ## Specifies the user's e-mail address (ldapDisplayName 'mail')
        [ValidateNotNull()]
        [System.String] $EmailAddress,

        ## Specifies the user's employee ID (ldapDisplayName 'employeeID')
        [ValidateNotNull()]
        [System.String] $EmployeeID,

        ## Specifies the user's employee number (ldapDisplayName 'employeeNumber')
        [ValidateNotNull()]
        [System.String] $EmployeeNumber,

        ## Specifies a user's home directory path (ldapDisplayName 'homeDirectory')
        [ValidateNotNull()]
        [System.String] $HomeDirectory,

        ## Specifies a drive that is associated with the UNC path defined by the HomeDirectory property (ldapDisplayName 'homeDrive')
        [ValidateNotNull()]
        [System.String] $HomeDrive,

        ## Specifies the URL of the home page of the object (ldapDisplayName 'wWWHomePage')
        [ValidateNotNull()]
        [System.String] $HomePage,

        ## Specifies a path to the user's profile (ldapDisplayName 'profilePath')
        [ValidateNotNull()]
        [System.String] $ProfilePath,

        ## Specifies a path to the user's log on script (ldapDisplayName 'scriptPath')
        [ValidateNotNull()]
        [System.String] $LogonScript,

        ## Specifies the notes attached to the user's accoutn (ldapDisplayName 'info')
        [ValidateNotNull()]
        [System.String] $Notes,

        ## Specifies the user's office telephone number (ldapDisplayName 'telephoneNumber')
        [ValidateNotNull()]
        [System.String] $OfficePhone,

        ## Specifies the user's mobile phone number (ldapDisplayName 'mobile')
        [ValidateNotNull()]
        [System.String] $MobilePhone,

        ## Specifies the user's fax phone number (ldapDisplayName 'facsimileTelephoneNumber')
        [ValidateNotNull()]
        [System.String] $Fax,

        ## Specifies the user's home telephone number (ldapDisplayName 'homePhone')
        [ValidateNotNull()]
        [System.String] $HomePhone,

         ## Specifies the user's pager number (ldapDisplayName 'pager')
        [ValidateNotNull()]
        [System.String] $Pager,

        ## Specifies the user's IP telephony phone number (ldapDisplayName 'ipPhone')
        [ValidateNotNull()]
        [System.String] $IPPhone,

        ## Specifies the user's manager specified as a Distinguished Name (ldapDisplayName 'manager')
        [ValidateNotNull()]
        [System.String] $Manager,

        ## Specifies if the account is enabled (default True)
        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        ## Specifies whether the account password can be changed
        [ValidateNotNull()]
        [System.Boolean] $CannotChangePassword,

        ## Specifies whether the password of an account can expire
        [ValidateNotNull()]
        [System.Boolean] $PasswordNeverExpires,

        ## Specifies the Active Directory Domain Services instance to use to perform the task.
        [ValidateNotNull()]
        [System.String] $DomainController,

        ## Specifies the user account credentials to use to perform this task. Ideally this should just be called 'Credential' but is here for backwards compatibility
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential,

        ## Specifies the authentication context type when testing user passwords #61
        [ValidateSet('Default','Negotiate')]
        [System.String] $PasswordAuthentication = 'Default'
    )

    Assert-Parameters @PSBoundParameters;
    $targetResource = Get-TargetResource @PSBoundParameters;

    ## Add common name, ensure and enabled as they may not be explicitly passed
    $PSBoundParameters['Ensure'] = $Ensure;
    $PSBoundParameters['Enabled'] = $Enabled;

    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Absent') {
            ## User does not exist and needs creating
            $newADUserParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter;
            if ($PSBoundParameters.ContainsKey('Path'))
            {
                $newADUserParams['Path'] = $Path;
            }
            Write-Verbose -Message ($LocalizedData.AddingADUser -f $UserName);
            New-ADUser @newADUserParams -SamAccountName $UserName;
            ## Now retrieve the newly created user
            $targetResource = Get-TargetResource @PSBoundParameters;
        }

        $setADUserParams = Get-ADCommonParameters @PSBoundParameters;
        $replaceUserProperties = @{};
        $removeUserProperties = @{};
        foreach ($parameter in $PSBoundParameters.Keys)
        {
            ## Only check/action properties specified/declared parameters that match one of the function's
            ## parameters. This will ignore common parameters such as -Verbose etc.
            if ($targetResource.ContainsKey($parameter))
            {
                if ($parameter -eq 'Path' -and ($PSBoundParameters.Path -ne $targetResource.Path))
                {
                    ## Cannot move users by updating the DistinguishedName property
                    $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
                    ## Using the SamAccountName for identity with Move-ADObject does not work, use the DN instead
                    $adCommonParameters['Identity'] = $targetResource.DistinguishedName;
                    Write-Verbose -Message ($LocalizedData.MovingADUser -f $targetResource.Path, $PSBoundParameters.Path);
                    Move-ADObject @adCommonParameters -TargetPath $PSBoundParameters.Path;
                }
                elseif ($parameter -eq 'CommonName' -and ($PSBoundParameters.CommonName -ne $targetResource.CommonName))
                {
                    ## Cannot rename users by updating the CN property directly
                    $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
                    ## Using the SamAccountName for identity with Rename-ADObject does not work, use the DN instead
                    $adCommonParameters['Identity'] = $targetResource.DistinguishedName;
                    Write-Verbose -Message ($LocalizedData.RenamingADUser -f $targetResource.CommonName, $PSBoundParameters.CommonName);
                    Rename-ADObject @adCommonParameters -NewName $PSBoundParameters.CommonName;
                }
                elseif ($parameter -eq 'Password')
                {
                    $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
                    Write-Verbose -Message ($LocalizedData.SettingADUserPassword -f $UserName);
                    Set-ADAccountPassword @adCommonParameters -Reset -NewPassword $Password.Password;
                }
                elseif ($parameter -eq 'Enabled' -and ($PSBoundParameters.$parameter -ne $targetResource.$parameter))
                {
                    ## We cannot enable/disable an account with -Add or -Replace parameters, but inform that
                    ## we will change this as it is out of compliance (it always gets set anyway)
                    Write-Verbose -Message ($LocalizedData.UpdatingADUserProperty -f $parameter, $PSBoundParameters.$parameter);
                }
                elseif ($PSBoundParameters.$parameter -ne $targetResource.$parameter)
                {
                    ## Find the associated AD property
                    $adProperty = $adPropertyMap | Where-Object { $_.Parameter -eq $parameter };

                    if ([System.String]::IsNullOrEmpty($adProperty))
                    {
                        ## We can't do anything is an empty AD property!
                    }
                    elseif ([System.String]::IsNullOrEmpty($PSBoundParameters.$parameter))
                    {
                        ## We are removing properties
                        ## Only remove if the existing value in not null or empty
                        if (-not ([System.String]::IsNullOrEmpty($targetResource.$parameter)))
                        {
                            Write-Verbose -Message ($LocalizedData.RemovingADUserProperty -f $parameter, $PSBoundParameters.$parameter);
                            if ($adProperty.UseCmdletParameter -eq $true)
                            {
                                ## We need to pass the parameter explicitly to Set-ADUser, not via -Remove
                                $setADUserParams[$adProperty.Parameter] = $PSBoundParameters.$parameter;
                            }
                            elseif ([System.String]::IsNullOrEmpty($adProperty.ADProperty))
                            {
                                $removeUserProperties[$adProperty.Parameter] = $targetResource.$parameter;
                            }
                            else
                            {
                                $removeUserProperties[$adProperty.ADProperty] = $targetResource.$parameter;
                            }
                        }
                    } #end if remove existing value
                    else
                    {
                        ## We are replacing the existing value
                        Write-Verbose -Message ($LocalizedData.UpdatingADUserProperty -f $parameter, $PSBoundParameters.$parameter);
                        if ($adProperty.UseCmdletParameter -eq $true)
                        {
                            ## We need to pass the parameter explicitly to Set-ADUser, not via -Replace
                            $setADUserParams[$adProperty.Parameter] = $PSBoundParameters.$parameter;
                        }
                        elseif ([System.String]::IsNullOrEmpty($adProperty.ADProperty))
                        {
                            $replaceUserProperties[$adProperty.Parameter] = $PSBoundParameters.$parameter;
                        }
                        else
                        {
                            $replaceUserProperties[$adProperty.ADProperty] = $PSBoundParameters.$parameter;
                        }
                    } #end if replace existing value
                }

            } #end if TargetResource parameter
        } #end foreach PSBoundParameter

        ## Only pass -Remove and/or -Replace if we have something to set/change
        if ($replaceUserProperties.Count -gt 0)
        {
            $setADUserParams['Replace'] = $replaceUserProperties;
        }
        if ($removeUserProperties.Count -gt 0)
        {
            $setADUserParams['Remove'] = $removeUserProperties;
        }

        Write-Verbose -Message ($LocalizedData.UpdatingADUser -f $UserName);
        [ref] $null = Set-ADUser @setADUserParams -Enabled $Enabled;
    }
    elseif (($Ensure -eq 'Absent') -and ($targetResource.Ensure -eq 'Present'))
    {
        ## User exists and needs removing
        Write-Verbose ($LocalizedData.RemovingADUser -f $UserName);
        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
        [ref] $null = Remove-ADUser @adCommonParameters -Confirm:$false;
    }

} #end function Set-TargetResource

# Internal function to validate unsupported options/configurations
function Assert-Parameters
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Password,

        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        [Parameter(ValueFromRemainingArguments)]
        $IgnoredArguments
    )

    ## We cannot test/set passwords on disabled AD accounts
    if (($PSBoundParameters.ContainsKey('Password')) -and ($Enabled -eq $false))
    {
        $throwInvalidArgumentErrorParams = @{
            ErrorId = 'xADUser_DisabledAccountPasswordConflict';
            ErrorMessage = $LocalizedData.PasswordParameterConflictError -f 'Enabled', $false, 'Password';
        }
        ThrowInvalidArgumentError @throwInvalidArgumentErrorParams;
    }

} #end function Assert-Parameters

# Internal function to test the validity of a user's password.
function Test-Password
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.String] $DomainName,

        [Parameter(Mandatory)]
        [System.String] $UserName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Password,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential,

        ## Specifies the authentication context type when testing user passwords #61
        [Parameter(Mandatory)]
        [ValidateSet('Default','Negotiate')]
        [System.String] $PasswordAuthentication
    )

    Write-Verbose -Message ($LocalizedData.CreatingADDomainConnection -f $DomainName);
    Add-Type -AssemblyName 'System.DirectoryServices.AccountManagement';

    if ($DomainAdministratorCredential)
    {
        $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
                                [System.DirectoryServices.AccountManagement.ContextType]::Domain,
                                $DomainName,
                                $DomainAdministratorCredential.UserName,
                                $DomainAdministratorCredential.GetNetworkCredential().Password
                            );
    }
    else
    {
        $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
                                [System.DirectoryServices.AccountManagement.ContextType]::Domain,
                                $DomainName,
                                $null,
                                $null
                            );
    }
    Write-Verbose -Message ($LocalizedData.CheckingADUserPassword -f $UserName);

    if ($PasswordAuthentication -eq 'Negotiate')
    {
        return $principalContext.ValidateCredentials(
            $UserName,
            $Password.GetNetworkCredential().Password,
            [System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate -bor
                [System.DirectoryServices.AccountManagement.ContextOptions]::Signing -bor
                    [System.DirectoryServices.AccountManagement.ContextOptions]::Sealing
        );
    }
    else
    {
        ## Use default authentication context
        return $principalContext.ValidateCredentials(
            $UserName,
            $Password.GetNetworkCredential().Password
        );
    }

} #end function Test-Password

## Import the common AD functions
$adCommonFunctions = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1';
. $adCommonFunctions;

Export-ModuleMember -Function *-TargetResource
