# User name and password needed for this resource and Write-Verbose Used in helper functions
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCUseVerboseMessageInDSCResource', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonResourceHelper.psm1')

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xUserResource'

if (-not (Test-IsNanoServer))
{
    Add-Type -AssemblyName 'System.DirectoryServices.AccountManagement'
}

<#
    .SYNOPSIS
        Retrieves the user with the given username

    .PARAMETER UserName
        The name of the user to retrieve.
#>
function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName
    )

    if (Test-IsNanoServer)
    {
        Get-TargetResourceOnNanoServer @PSBoundParameters
    }
    else
    {
        Get-TargetResourceOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Creates, modifies, or deletes a user.
    
    .PARAMETER UserName
        The name of the user to create, modify, or delete.

    .PARAMETER Ensure
        Specifies whether the user should exist or not.
        By default this is set to Present.

    .PARAMETER FullName
        The (optional) full name or display name of the user.
        If not provided this value will remain blank.

    .PARAMETER Description
        Optional description for the user.

    .PARAMETER Password
        The desired password for the user.

    .PARAMETER Disabled
        Specifies whether the user should be disabled or not.
        By default this is set to $false

    .PARAMETER PasswordNeverExpires
        Specifies whether the password should ever expire or not.
        By default this is set to $false

    .PARAMETER PasswordChangeRequired
        Specifies whether the user must reset their password or not.
        By default this is set to $false

    .PARAMETER PasswordChangeNotAllowed
        Specifies whether the user is allowed to change their password or not.
        By default this is set to $false

    .NOTES 
        If Ensure is set to 'Present' then the password parameter is required.
#>
function Set-TargetResource
{
    # Should process is called in a helper functions but not directly in Set-TargetResource
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $FullName,

        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Password,

        [System.Boolean]
        $Disabled,

        [System.Boolean]
        $PasswordNeverExpires,

        [System.Boolean]
        $PasswordChangeRequired,

        [System.Boolean]
        $PasswordChangeNotAllowed
    )

    if (Test-IsNanoServer)
    {
        Set-TargetResourceOnNanoServer @PSBoundParameters
    }
    else
    {
        Set-TargetResourceOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Tests if a user is in the desired state.

    .PARAMETER UserName
        The name of the user to test the state of.

    .PARAMETER Ensure
        Specifies whether the user should exist or not.
        By default this is set to Present

    .PARAMETER FullName
        The full name/display name that the user should have.
        If not provided, this value will not be tested.

    .PARAMETER Description
        The description that the user should have.
        If not provided, this value will not be tested.

    .PARAMETER Password
        The password the user should have.

    .PARAMETER Disabled
        Specifies whether the user account should be disabled or not.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password should ever expire or not.

    .PARAMETER PasswordChangeRequired
        Not used in Test-TargetResource as there is no easy way to test this value.

    .PARAMETER PasswordChangeNotAllowed
        Specifies whether the user should be allowed to change their password or not.
#>
function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $FullName,

        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Password,

        [System.Boolean]
        $Disabled,

        [System.Boolean]
        $PasswordNeverExpires,

        [System.Boolean]
        $PasswordChangeRequired,

        [System.Boolean]
        $PasswordChangeNotAllowed
    )

    if (Test-IsNanoServer)
    {
        Test-TargetResourceOnNanoServer @PSBoundParameters
    }
    else
    {
        Test-TargetResourceOnFullSKU @PSBoundParameters
    }
}


<#
    .SYNOPSIS
        Retrieves the user with the given username when on a full server

    .PARAMETER UserName
        The name of the user to retrieve.
#>
function Get-TargetResourceOnFullSKU
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName
    )

    Set-StrictMode -Version Latest

    Assert-UserNameValid -UserName $UserName

    # Try to find a user by a name
    $principalContext = New-Object `
                -TypeName System.DirectoryServices.AccountManagement.PrincipalContext `
                -ArgumentList ([System.DirectoryServices.AccountManagement.ContextType]::Machine)

    try
    {
        Write-Verbose -Message 'Starting Get-TargetResource on FullSKU'
        $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($principalContext, $UserName)
        if ($null -ne $user)
        {
            # The user is found. Return all user properties and Ensure='Present'.
            $returnValue = @{
                                UserName = $user.Name
                                Ensure = 'Present'
                                FullName = $user.DisplayName
                                Description = $user.Description
                                Disabled = -not $user.Enabled
                                PasswordNeverExpires = $user.PasswordNeverExpires
                                PasswordChangeRequired = $null
                                PasswordChangeNotAllowed = $user.UserCannotChangePassword
                            }

            return $returnValue
        }

        # The user is not found. Return Ensure = Absent.
        return @{
                    UserName = $UserName
                    Ensure = 'Absent'
                }
    }
    catch
    {
         New-ConnectionException -ErrorId 'MultipleMatches' -ErrorMessage ($script:localizedData.MultipleMatches + $_)
    }
    finally
    {
        if ($null -ne $user)
        {
            $user.Dispose()
        }

        $principalContext.Dispose()
    }
}

<#
    .SYNOPSIS
        Creates, modifies, or deletes a user when on a full server.
    
    .PARAMETER UserName
        The name of the user to create, modify, or delete.

    .PARAMETER Ensure
        Specifies whether the user should exist or not.
        By default this is set to Present

    .PARAMETER FullName
        The (optional) full name or display name of the user.
        If not provided this value will remain blank.

    .PARAMETER Description
        Optional description for the user.

    .PARAMETER Password
        The desired password for the user.

    .PARAMETER Disabled
        Specifies whether the user should be disabled or not.
        By default this is set to $false

    .PARAMETER PasswordNeverExpires
        Specifies whether the password should ever expire or not.
        By default this is set to $false

    .PARAMETER PasswordChangeRequired
        Specifies whether the user must reset their password or not.
        By default this is set to $false

    .PARAMETER PasswordChangeNotAllowed
        Specifies whether the user is allowed to change their password or not.
        By default this is set to $false

    .NOTES 
        If Ensure is set to 'Present' then the Password parameter is required.
#>
function Set-TargetResourceOnFullSKU
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $FullName,

        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Password,

        [System.Boolean]
        $Disabled,

        [System.Boolean]
        $PasswordNeverExpires,

        [System.Boolean]
        $PasswordChangeRequired,

        [System.Boolean]
        $PasswordChangeNotAllowed
    )

    Set-StrictMode -Version Latest

    Write-Verbose -Message ($script:localizedData.ConfigurationStarted -f $UserName)

    Assert-UserNameValid -UserName $UserName


    # Try to find a user by name.
    $principalContext = New-Object `
                -TypeName System.DirectoryServices.AccountManagement.PrincipalContext `
                -ArgumentList ([System.DirectoryServices.AccountManagement.ContextType]::Machine)

    try
    {
        $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($principalContext, $UserName)
        if ($Ensure -eq 'Present')
        {
            $whatIfShouldProcess = $true
            $userExists = $false
            $saveChanges = $false

            if ($null -eq $user)
            {
                # A user does not exist. Check WhatIf for adding a user
                $whatIfShouldProcess = $pscmdlet.ShouldProcess($script:localizedData.UserWithName -f $UserName, $script:localizedData.AddOperation)
            }
            else
            {
                # A user exists
                $userExists = $true

                # Check WhatIf for setting a user
                $whatIfShouldProcess = $pscmdlet.ShouldProcess($script:localizedData.UserWithName -f $UserName, $script:localizedData.SetOperation)
            }

            if ($whatIfShouldProcess)
            {
                if (-not $userExists)
                {
                    # The user with the provided name does not exist so add a new user
                    $user = New-Object `
                                -TypeName System.DirectoryServices.AccountManagement.UserPrincipal `
                                -ArgumentList $principalContext
                    $user.Name = $UserName
                    $saveChanges = $true
                }

                # Set user properties.
                if ($PSBoundParameters.ContainsKey('FullName') -and ((-not $userExists) -or ($FullName -ne $user.DisplayName)))
                {
                    $user.DisplayName = $FullName
                    $saveChanges = $true
                }
                else
                {
                    if (-not $userExists)
                    {
                        # For a newly created user, set the DisplayName property to an empty string since by default DisplayName is set to user's name
                        $user.DisplayName = [String]::Empty
                    }
                }

                if ($PSBoundParameters.ContainsKey('Description') -and ((-not $userExists) -or ($Description -ne $user.Description)))
                {
                    $user.Description = $Description
                    $saveChanges = $true
                }

                # Set the password regardless of the state of the user
                if ($PSBoundParameters.ContainsKey('Password'))
                {
                    $user.SetPassword($Password.GetNetworkCredential().Password)
                    $saveChanges = $true
                }

                if ($PSBoundParameters.ContainsKey('Disabled') -and ((-not $userExists) -or ($Disabled -eq $user.Enabled)))
                {
                    $user.Enabled = -not $Disabled
                    $saveChanges = $true
                }

                if ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -and ((-not $userExists) -or ($PasswordNeverExpires -ne $user.PasswordNeverExpires)))
                {
                    $user.PasswordNeverExpires = $PasswordNeverExpires
                    $saveChanges = $true
                }

                if ($PSBoundParameters.ContainsKey('PasswordChangeRequired'))
                {
                    if ($PasswordChangeRequired)
                    {
                        # Expire the password which will force the user to change the password at the next logon
                        $user.ExpirePasswordNow()
                        $saveChanges = $true
                    }
                }

                if ($PSBoundParameters.ContainsKey('PasswordChangeNotAllowed') -and ((-not $userExists) -or ($PasswordChangeNotAllowed -ne $user.UserCannotChangePassword)))
                {
                    $user.UserCannotChangePassword = $PasswordChangeNotAllowed
                    $saveChanges = $true

                }

                if ($saveChanges)
                {
                    $user.Save()

                    # Send an operation success verbose message
                    if ($userExists)
                    {
                        Write-Verbose -Message ($script:localizedData.UserUpdated -f $UserName)
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.UserCreated -f $UserName)
                    }
                }
                else
                {
                    Write-Verbose -Message ($script:localizedData.NoConfigurationRequired -f $UserName)
                }
            }
        }
        else
        {
            # Ensure is set to 'Absent'
            if ($user -ne $null)
            {
                # The user exists
                if ($pscmdlet.ShouldProcess($script:localizedData.UserWithName -f $UserName, $script:localizedData.RemoveOperation))
                {
                    # Remove the user
                    $user.Delete()
                }

                Write-Verbose -Message ($script:localizedData.UserRemoved -f $UserName)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.NoConfigurationRequiredUserDoesNotExist -f $UserName)
            }
        }
    }
    catch
    {
         New-InvalidOperationException -Message ($script:localizedData.MultipleMatches + $_)
    }
    finally
    {
        if ($null -ne $user)
        {
            $user.Dispose()
        }

        $principalContext.Dispose()
    }

    Write-Verbose -Message ($script:localizedData.ConfigurationCompleted -f $UserName)
}

<#
    .SYNOPSIS
        Tests if a user is in the desired state when on a full server.

    .PARAMETER UserName
        The name of the user to test the state of.

    .PARAMETER Ensure
        Specifies whether the user should exist or not.
        By default this is set to Present

    .PARAMETER FullName
        The full name/display name that the user should have.
        If not provided, this value will not be tested.

    .PARAMETER Description
        The description that the user should have.
        If not provided, this value will not be tested.

    .PARAMETER Password
        The password the user should have.

    .PARAMETER Disabled
        Specifies whether the user account should be disabled or not.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password should ever expire or not.

    .PARAMETER PasswordChangeRequired
        Not used in Test-TargetResource as there is no easy way to test this value.

    .PARAMETER PasswordChangeNotAllowed
        Specifies whether the user should be allowed to change their password or not.
#>
function Test-TargetResourceOnFullSKU
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $FullName,

        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Password,

        [System.Boolean]
        $Disabled,

        [System.Boolean]
        $PasswordNeverExpires,

        [System.Boolean]
        $PasswordChangeRequired,

        [System.Boolean]
        $PasswordChangeNotAllowed
    )

    Set-StrictMode -Version Latest

    Assert-UserNameValid -UserName $UserName

    # Try to find a user by a name
    $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext `
                -ArgumentList ([System.DirectoryServices.AccountManagement.ContextType]::Machine)

    try
    {
        $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($principalContext, $UserName)
        if ($null -eq $user)
        {
            # A user with the provided name does not exist
            Write-Verbose -Message ($script:localizedData.UserDoesNotExist -f $UserName)

            if ($Ensure -eq 'Absent')
            {
                return $true
            }
            else
            {
                return $false
            }
        }

        # A user with the provided name exists
        Write-Verbose -Message ($script:localizedData.UserExists -f $UserName)

        # Validate separate properties
        if ($Ensure -eq 'Absent')
        {
            # The Ensure property does not match
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Ensure', 'Absent', 'Present')
            return $false
        }

        if ($PSBoundParameters.ContainsKey('FullName') -and $FullName -ne $user.DisplayName)
        {
            # The FullName property does not match
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'FullName', $FullName, $user.DisplayName)
            return $false
        }

        if ($PSBoundParameters.ContainsKey('Description') -and $Description -ne $user.Description)
        {
            # The Description property does not match
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Description', $Description, $user.Description)
            return $false
        }

        # Password
        if ($PSBoundParameters.ContainsKey('Password'))
        {
            if (-not $principalContext.ValidateCredentials($UserName, $Password.GetNetworkCredential().Password))
            {
                # The Password property does not match
                Write-Verbose -Message ($script:localizedData.PasswordPropertyMismatch -f 'Password')
                return $false
            }
        }

        if ($PSBoundParameters.ContainsKey('Disabled') -and $Disabled -eq $user.Enabled)
        {
            # The Disabled property does not match
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Disabled', $Disabled, $user.Enabled)
            return $false
        }

        if ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -and $PasswordNeverExpires -ne $user.PasswordNeverExpires)
        {
            # The PasswordNeverExpires property does not match
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'PasswordNeverExpires', $PasswordNeverExpires, $user.PasswordNeverExpires)
            return $false
        }

        if ($PSBoundParameters.ContainsKey('PasswordChangeNotAllowed') -and $PasswordChangeNotAllowed -ne $user.UserCannotChangePassword)
        {
            # The PasswordChangeNotAllowed property does not match
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'PasswordChangeNotAllowed', $PasswordChangeNotAllowed, $user.UserCannotChangePassword)
            return $false
        }
    }
    catch
    {
         New-ConnectionException -ErrorId 'ConnectionError' -ErrorMessage ($script:localizedData.ConnectionError + $_)
    }

    finally
    {
        if ($null -ne $user)
        {
            $user.Dispose()
        }

        $principalContext.Dispose()

    }

    # All properties match
    Write-Verbose -Message ($script:localizedData.AllUserPropertisMatch -f 'User', $UserName)
    return $true
}


<#
    .SYNOPSIS
        Retrieves the user with the given username when on Nano Server.

    .PARAMETER UserName
        The name of the user to retrieve.
#>
function Get-TargetResourceOnNanoServer
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName
    )

    Set-StrictMode -Version Latest

    Assert-UserNameValid -UserName $UserName

    # Try to find a user by a name
    try
    {
        Write-Verbose -Message 'Starting Get-TargetResource on NanoServer'
        [Microsoft.PowerShell.Commands.LocalUser] $user = Get-LocalUser -Name $UserName -ErrorAction Stop
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.ToString().Contains('UserNotFoundException'))
        {
            # The user is not found
            return @{
                        UserName = $UserName
                        Ensure = 'Absent'
                    }
        }
        New-InvalidOperationException -ErrorRecord $_
    }

    # The user is found. Return all user properties and Ensure = 'Present'.
    $returnValue = @{
                        UserName = $user.Name
                        Ensure = 'Present'
                        FullName = $user.FullName
                        Description = $user.Description
                        Disabled = -not $user.Enabled
                        PasswordChangeRequired = $null
                        PasswordChangeNotAllowed = -not $user.UserMayChangePassword
                    }

    if ($user.PasswordExpires)
    {
        $returnValue.Add('PasswordNeverExpires', $false)
    }
    else
    {
        $returnValue.Add('PasswordNeverExpires', $true)
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Creates, modifies, or deletes a user when on Nano Server.
    
    .PARAMETER UserName
        The name of the user to create, modify, or delete.

    .PARAMETER Ensure
        Specifies whether the user should exist or not.
        By default this is set to Present

    .PARAMETER FullName
        The (optional) full name or display name of the user.
        If not provided this value will remain blank.

    .PARAMETER Description
        Optional description for the user.

    .PARAMETER Password
        The desired password for the user.

    .PARAMETER Disabled
        Specifies whether the user should be disabled or not.
        By default this is set to $false

    .PARAMETER PasswordNeverExpires
        Specifies whether the password should ever expire or not.
        By default this is set to $false

    .PARAMETER PasswordChangeRequired
        Specifies whether the user must reset their password or not.
        By default this is set to $false

    .PARAMETER PasswordChangeNotAllowed
        Specifies whether the user is allowed to change their password or not.
        By default this is set to $false

    .NOTES 
        If Ensure is set to 'Present' then the Password parameter is required.
#>
function Set-TargetResourceOnNanoServer
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $FullName,

        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Password,

        [System.Boolean]
        $Disabled,

        [System.Boolean]
        $PasswordNeverExpires,

        [System.Boolean]
        $PasswordChangeRequired,

        [System.Boolean]
        $PasswordChangeNotAllowed
    )

    Set-StrictMode -Version Latest

    Write-Verbose -Message ($script:localizedData.ConfigurationStarted -f $UserName)

    Assert-UserNameValid -UserName $UserName

    # Try to find a user by a name.
    $userExists = $false
    
    try
    {
        [Microsoft.PowerShell.Commands.LocalUser] $user = Get-LocalUser -Name $UserName -ErrorAction Stop
        $userExists = $true
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.ToString().Contains('UserNotFoundException'))
        {
            # The user is not found.
            Write-Verbose -Message ($script:localizedData.UserDoesNotExist -f $UserName)
        }
        else
        {
            New-InvalidOperationException -ErrorRecord $_
        }
    }

    if ($Ensure -eq 'Present')
    {
        # Ensure is set to 'Present'

        if (-not $userExists)
        {
            # The user with the provided name does not exist so add a new user
            New-LocalUser -Name $UserName -NoPassword
            Write-Verbose -Message ($script:localizedData.UserCreated -f $UserName)
        }

        # Set user properties
        if ($PSBoundParameters.ContainsKey('FullName'))
        {
            if (-not $userExists -or $FullName -ne $user.FullName)
            {
                if ($FullName -eq $null)
                {
                    Set-LocalUser -Name $UserName -FullName ([String]::Empty)
                }
                else
                {
                    Set-LocalUser -Name $UserName -FullName $FullName
                }
            }
        }
        else
        {
            if (-not $userExists)
            {
                # For a newly created user, set the DisplayName property to an empty string since by default DisplayName is set to user's name.
                Set-LocalUser -Name $UserName -FullName ([String]::Empty)
            }
        }

        if ($PSBoundParameters.ContainsKey('Description') -and ((-not $userExists) -or ($Description -ne $user.Description)))
        {
            if ($null -eq $Description)
            {
                Set-LocalUser -Name $UserName -Description ([String]::Empty)
            }
            else
            {
                Set-LocalUser -Name $UserName -Description $Description
            }
        }

        # Set the password regardless of the state of the user
        if ($PSBoundParameters.ContainsKey('Password'))
        {
            Set-LocalUser -Name $UserName -Password $Password.Password
        }

        if ($PSBoundParameters.ContainsKey('Disabled') -and ((-not $userExists) -or ($Disabled -eq $user.Enabled)))
        {
            if ($Disabled)
            {
                Disable-LocalUser -Name $UserName
            }
            else
            {
                Enable-LocalUser -Name $UserName
            }
        }

        $existingUserPasswordNeverExpires = (($userExists) -and ($null -eq $user.PasswordExpires))
        if ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -and ((-not $userExists) -or ($PasswordNeverExpires -ne $existingUserPasswordNeverExpires)))
        {
            Set-LocalUser -Name $UserName -PasswordNeverExpires:$passwordNeverExpires
        }

        if ($PSBoundParameters.ContainsKey('PasswordChangeRequired') -and ($PasswordChangeRequired))
        {
            Set-LocalUser -Name $UserName -AccountExpires ([DateTime]::Now)
        }

        # NOTE: The parameter name and the property name have opposite meaning.
        [System.Boolean] $expected = -not $PasswordChangeNotAllowed
        $actual = $expected
        
        if ($userExists)
        {
            $actual = $user.UserMayChangePassword
        }
        
        if ($PSBoundParameters.ContainsKey('PasswordChangeNotAllowed') -and ((-not $userExists) -or ($expected -ne $actual)))
        {
            Set-LocalUser -Name $UserName -UserMayChangePassword $expected
        }
    }
    else
    {
        # Ensure is set to 'Absent'
        if ($userExists)
        {
            # The user exists
            Remove-LocalUser -Name $UserName

            Write-Verbose -Message ($script:localizedData.UserRemoved -f $UserName)
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.NoConfigurationRequiredUserDoesNotExist -f $UserName)
        }
    }

    Write-Verbose -Message ($script:localizedData.ConfigurationCompleted -f $UserName)
}

<#
    .SYNOPSIS
        Tests if a user is in the desired state when on Nano Server.

    .PARAMETER UserName
        The name of the user to test the state of.

    .PARAMETER Ensure
        Specifies whether the user should exist or not.
        By default this is set to Present

    .PARAMETER FullName
        The full name/display name that the user should have.
        If not provided, this value will not be tested.

    .PARAMETER Description
        The description that the user should have.
        If not provided, this value will not be tested.

    .PARAMETER Password
        The password the user should have.

    .PARAMETER Disabled
        Specifies whether the user account should be disabled or not.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password should ever expire or not.

    .PARAMETER PasswordChangeRequired
        Not used in Test-TargetResource as there is no easy way to test this value.

    .PARAMETER PasswordChangeNotAllowed
        Specifies whether the user should be allowed to change their password or not.
#>
function Test-TargetResourceOnNanoServer
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $FullName,

        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Password,

        [System.Boolean]
        $Disabled,

        [System.Boolean]
        $PasswordNeverExpires,

        [System.Boolean]
        $PasswordChangeRequired,

        [System.Boolean]
        $PasswordChangeNotAllowed
    )

    Set-StrictMode -Version Latest

    Assert-UserNameValid -UserName $UserName

    # Try to find a user by a name
    try
    {
        [Microsoft.PowerShell.Commands.LocalUser] $user = Get-LocalUser -Name $UserName -ErrorAction Stop
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.ToString().Contains('UserNotFoundException'))
        {
            # The user is not found
            if ($Ensure -eq 'Absent')
            {
                return $true
            }
            else
            {
                return $false
            }
        }
        New-InvalidOperationException -ErrorRecord $_
    }

    # A user with the provided name exists
    Write-Verbose -Message ($script:localizedData.UserExists -f $UserName)

    # Validate separate properties
    if ($Ensure -eq 'Absent')
    {
        # The Ensure property does not match
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Ensure', 'Absent', 'Present')
        return $false
    }

    if ($PSBoundParameters.ContainsKey('FullName') -and $FullName -ne $user.FullName)
    {
        # The FullName property does not match
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'FullName', $FullName, $user.FullName)
        return $false
    }

    if ($PSBoundParameters.ContainsKey('Description') -and $Description -ne $user.Description)
    {
        # The Description property does not match
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Description', $Description, $user.Description)
        return $false
    }

    if ($PSBoundParameters.ContainsKey('Password'))
    {
        if(-not (Test-CredentialsValidOnNanoServer -UserName $UserName -Password $Password.Password))
        {
            # The Password property does not match
            Write-Verbose -Message ($script:localizedData.PasswordPropertyMismatch -f 'Password')
            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('Disabled') -and ($Disabled -eq $user.Enabled))
    {
        # The Disabled property does not match
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Disabled', $Disabled, $user.Enabled)
        return $false
    }

    $existingUserPasswordNeverExpires = ($null -eq $user.PasswordExpires)
    if ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -and $PasswordNeverExpires -ne $existingUserPasswordNeverExpires)
    {
        # The PasswordNeverExpires property does not match
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'PasswordNeverExpires', $PasswordNeverExpires, $existingUserPasswordNeverExpires)
        return $false
    }

    if ($PSBoundParameters.ContainsKey('PasswordChangeNotAllowed') -and $PasswordChangeNotAllowed -ne (-not $user.UserMayChangePassword))
    {
        # The PasswordChangeNotAllowed property does not match
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'PasswordChangeNotAllowed', $PasswordChangeNotAllowed, (-not $user.UserMayChangePassword))
        return $false
    }

    # All properties match. Return $true.
    Write-Verbose -Message ($script:localizedData.AllUserPropertisMatch -f 'User', $UserName)
    return $true
}

<#
    .SYNOPSIS
        Checks that the username does not contain invalid characters.

    .PARAMETER UserName
        The username to validate.
#>
function Assert-UserNameValid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName
    )

    # Check if the name consists of only periods and/or white spaces
    $wrongName = $true
    
    for ($i = 0; $i -lt $UserName.Length; $i++)
    {
        if (-not [Char]::IsWhiteSpace($UserName, $i) -and $UserName[$i] -ne '.')
        {
            $wrongName = $false
            break
        }
    }

    $invalidChars = @('\','/','"','[',']',':','|','<','>','+','=',';',',','?','*','@')

    if ($wrongName)
    {
        New-InvalidArgumentException `
            -Message ($script:localizedData.InvalidUserName -f $UserName, [String]::Join(' ', $invalidChars)) `
            -ArgumentName 'UserName'
    }

    if ($UserName.IndexOfAny($invalidChars) -ne -1)
    {
        New-InvalidArgumentException `
            -Message ($script:localizedData.InvalidUserName -f $UserName, [String]::Join(' ', $invalidChars)) `
            -ArgumentName 'UserName'
    }
}

<#
    .SYNOPSIS
        Creates a new Connection error record and throws it.

    .PARAMETER ErrorId
        The ID for the error record to be thrown.

    .PARAMETER ErrorMessage
        Message to be included in the error record to be thrown.
#>
function New-ConnectionException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    $errorCategory = [System.Management.Automation.ErrorCategory]::ConnectionError
    $exception = New-Object `
        -TypeName System.ArgumentException `
        -ArgumentList $ErrorMessage
    $errorRecord = New-Object `
        -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList @($exception, $ErrorId, $errorCategory, $null)
    throw $errorRecord
}

<#
    .SYNOPSIS
        Tests the local user's credentials on the local machine.
    
    .PARAMETER UserName
        The username to validate the credentials of.

    .PARAMETER Password
        The password of the given user.
#>
function Test-CredentialsValidOnNanoServer
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateNotNullOrEmpty()]
        [SecureString]
        $Password
    )

    $source = @'
        [Flags]
        private enum LogonType
        {
            Logon32LogonInteractive = 2,
            Logon32LogonNetwork,
            Logon32LogonBatch,
            Logon32LogonService,
            Logon32LogonUnlock,
            Logon32LogonNetworkCleartext,
            Logon32LogonNewCredentials
        }

        [Flags]
        private enum LogonProvider
        {
            Logon32ProviderDefault = 0,
            Logon32ProviderWinnt35,
            Logon32ProviderWinnt40,
            Logon32ProviderWinnt50
        }

        [DllImport("api-ms-win-security-logon-l1-1-1.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern Boolean LogonUser(
            String lpszUserName,
            String lpszDomain,
            IntPtr lpszPassword,
            LogonType dwLogonType,
            LogonProvider dwLogonProvider,
            out IntPtr phToken
            );


        [DllImport("api-ms-win-core-handle-l1-1-0.dll",
            EntryPoint = "CloseHandle", SetLastError = true,
            CharSet = CharSet.Unicode, CallingConvention = CallingConvention.StdCall)]
        internal static extern bool CloseHandle(IntPtr handle);

        public static bool ValidateCredentials(string username, SecureString password)
        {
            IntPtr tokenHandle = IntPtr.Zero;
            IntPtr unmanagedPassword = IntPtr.Zero;

            unmanagedPassword = SecureStringMarshal.SecureStringToCoTaskMemUnicode(password);

            try
            {
                return LogonUser(
                    username,
                    null,
                    unmanagedPassword,
                    LogonType.Logon32LogonInteractive,
                    LogonProvider.Logon32ProviderDefault,
                    out tokenHandle);
            }
            catch
            {
                return false;
            }
            finally
            {
                if (tokenHandle != IntPtr.Zero)
                {
                    CloseHandle(tokenHandle);
                }
                if (unmanagedPassword != IntPtr.Zero) {
                    Marshal.ZeroFreeCoTaskMemUnicode(unmanagedPassword);
                }
                unmanagedPassword = IntPtr.Zero;
            }
        }
'@

    Add-Type -PassThru -Namespace Microsoft.Windows.DesiredStateConfiguration.NanoServer.UserResource `
        -Name CredentialsValidationTool -MemberDefinition $source -Using System.Security -ReferencedAssemblies System.Security.SecureString.dll | Out-Null
    return [Microsoft.Windows.DesiredStateConfiguration.NanoServer.UserResource.CredentialsValidationTool]::ValidateCredentials($UserName, $Password)
}

Export-ModuleMember -Function *-TargetResource
