<#
    Implementatation Notes

    Managing Disposable Objects
        The types PrincipalContext, Principal, and DirectoryEntry are used througout the code and
        all are disposable. However, in many cases, disposing the object immediately causes
        subsequent operations to fail or duplicate disposes calls to occur.

        To simplify management of these disposables, each public entry point defines a $disposables
        ArrayList variable and passes it to secondary functions that may need to create disposable
        objects. The public entry point is then required to dispose the contents of the list in a
        finally block.

    Managing PrincipalContext Instances
        To use the AccountManagement APIs to connect to the local machine or a domain, a
        PrincipalContext is needed.

        For the local groups and users, a PrincipalContext reflecting the current user can be
        created.

        For the default domain, the domain where the machine is joined, explicit credentials are
        needed since the default user context is SYSTEM which has no rights to the domain.

        Additional PrincipalContext instances may be needed when the machine is in a domain that is
        part of a multi-domain forest. For example, Microsoft uses a multi-domain forest that
        includes domains such as ntdev, redmond, wingroup and a group may have members that
        span multiple domains. Unless the enterprise implements the Global Catalog,
        something that Microsoft does not do, a unique PrincipalContext is needed to resolve
        accounts in each of the domains.

        To manage the use of PrincipalContext across domains, public entry points define a
        $principalContextCache hashtable and pass it to support functions that need to resolve a group
        or group member. Consumers of a PrincipalContext call Get-PrincipalContext with a scope
        (domain name or machine name). Get-PrincipalContext returns an existing hashtable entry or
        creates a new entry.  Note that a PrincipalContext to a target domain requires connecting
        to the domain. The hashtable avoids subsequent connection calls. Also note that
        Get-PrincipalContext takes a Credential parameter for the case where a new PrincipalContext
        is needed. The implicit assumption is that the credential provided for the primary domain
        also has rights to resolve accounts in any of the other domains.

    Resolving Group Members
        The original implementation assumed that group members could be resolved using the machine
        PrincipalContext or the logged on user. In practice this is not reliable since the resource
        is typically run under the SYSTEM account and this account is not guaranteed to have rights
        to resolve domain accounts. Additionally, the APIs for enumerating group members do not
        provide a facility for passing additional credentials resulting in domain members failing
        to resolve.

        To address this, group members are enumerated by first converting the GroupPrincipal to a
        DirectoryEntry and enumerating its child members. The returned DirectoryEntry instances are
        then resolved to Principal objects using a PrincipalContext appropriate for the target
        domain.

    Handling Stale Group Members
        A group may have stale members if the machine was moved from one domain to a another
        foreign domain or when accounts are deleted (domain or local). At this point, members that
        were defined in the original domain or were deleted are now stale and cannot be resolved
        using Principal::FindByIdentity. The original implementation failed at this point
        preventing any operations against the group. The current implementation calls Write-Warning
        with the associated SID of the member that cannot be resolved then continues the operation.
#>

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonResourceHelper for Test-IsNanoServer
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonResourceHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonResourceHelper.psm1'
Import-Module -Name $script:commonResourceHelperFilePath

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xGroupResource'

if (-not (Test-IsNanoServer))
{
    Add-Type -AssemblyName 'System.DirectoryServices.AccountManagement'
}

<#
    .SYNOPSIS
        Retrieves the current state of the group with the specified name.

    .PARAMETER GroupName
        The name of the group to retrieve the current state of.

    .PARAMETER Credential
        A credential to resolve non-local group members.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Assert-GroupNameValid -GroupName $GroupName

    if (Test-IsNanoServer)
    {
        Write-Verbose -Message ($script:localizedData.InvokingFunctionForGroup -f 'Get-TargetResourceOnNanoServer', $GroupName)
        return Get-TargetResourceOnNanoServer @PSBoundParameters
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.InvokingFunctionForGroup -f 'Get-TargetResourceOnFullSKU', $GroupName)
        return Get-TargetResourceOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Creates, modifies, or removes a group.

    .PARAMETER GroupName
        The name of the group to create, modify, or remove.

    .PARAMETER Ensure
        Specifies whether the group should exist or not.

        To ensure that the group does exist, set this property to present.
        To ensure that the group does not exist, set this property to Absent.
        
        The default value is Present.

    .PARAMETER Description
        The description the group should have.

    .PARAMETER Members
        The members the group should have.

        This property will replace all the current group members with the specified members.

        Members should be specified as strings in the format of their domain qualified name 
        (domain\username), their UPN (username@domainname), their distinguished name (CN=username,DC=...),
        or their username (for local machine accounts).  
        
        Using either the MembersToExclude or MembersToInclude properties in the same configuration
        as this property will generate an error.

    .PARAMETER MembersToInclude
        The members the group should include.

        This property will only add members to a group.

        Members should be specified as strings in the format of their domain qualified name 
        (domain\username), their UPN (username@domainname), their distinguished name (CN=username,DC=...),
        or their username (for local machine accounts).

        Using the Members property in the same configuration as this property will generate an error.

    .PARAMETER MembersToExclude
        The members the group should exclude.

        This property will only remove members from a group.

        Members should be specified as strings in the format of their domain qualified name 
        (domain\username), their UPN (username@domainname), their distinguished name (CN=username,DC=...),
        or their username (for local machine accounts).

        Using the Members property in the same configuration as this property will generate an error.

    .PARAMETER Credential
        A credential to resolve and add non-local group members.

        An error will occur if this account does not have the appropriate Active Directory permissions to add all
        non-local accounts to the group.

    .NOTES
        ShouldProcess PSSA rule is suppressed because Set-TargetResourceOnFullSKU and
        Set-TargetResourceOnNanoServer call ShouldProcess.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [String]
        $Description,

        [String[]]
        $Members,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Write-Verbose ($script:localizedData.SetTargetResourceStartMessage -f $GroupName)

    Assert-GroupNameValid -GroupName $GroupName

    if (Test-IsNanoServer)
    {
        Set-TargetResourceOnNanoServer @PSBoundParameters
    }
    else
    {
        Set-TargetResourceOnFullSKU @PSBoundParameters
    }

    Write-Verbose ($script:localizedData.SetTargetResourceEndMessage -f $GroupName)
}

<#
    .SYNOPSIS
        Tests if the group with the specified name is in the desired state.

    .PARAMETER GroupName
        The name of the group to test the state of.

    .PARAMETER Ensure
        Indicates if the group should exist or not.

        Set this property to "Absent" to test that the group does not exist.
        Setting it to "Present" (the default value) tests that the group exists.

    .PARAMETER Description
        The description of the group to test for.

    .PARAMETER Members
        The list of members the group should have.
        
        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.  

        If you set this property in a configuration, do not use either the MembersToExclude or
        MembersToInclude property. Doing so will generate an error.

    .PARAMETER MembersToInclude
        A list of members that should be in the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.  

        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER MembersToExclude
        A list of members that should not be in the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER Credential
        The credentials required to resolve non-local group members
#>
function Test-TargetResource
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [String]
        $Description,

        [String[]]
        $Members,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Assert-GroupNameValid -GroupName $GroupName

    if (Test-IsNanoServer)
    {
        Write-Verbose ($script:localizedData.InvokingFunctionForGroup -f 'Test-TargetResourceOnNanoServer', $GroupName)
        return Test-TargetResourceOnNanoServer @PSBoundParameters
    }
    else
    {
        Write-Verbose ($script:localizedData.InvokingFunctionForGroup -f 'Test-TargetResourceOnFullSKU', $GroupName)
        return Test-TargetResourceOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Retrieves the current state of the group with the specified name on a full server.

    .PARAMETER GroupName
        The name of the group to retrieve the current state of.

    .PARAMETER Credential
        A credential to resolve non-local group members.
#>
function Get-TargetResourceOnFullSKU
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $principalContextCache = @{}
    $disposables = New-Object -TypeName 'System.Collections.ArrayList'

    try
    {
        $principalContext = Get-PrincipalContext `
            -PrincipalContextCache $principalContextCache `
            -Disposables $Disposables `
            -Scope $env:COMPUTERNAME

        $group = Get-Group -GroupName $GroupName -PrincipalContext $principalContext

        if ($null -ne $group)
        {
            $null = $disposables.Add($group)

            # The group was found. Find the group members.
            $members = Get-MembersOnFullSKU -Group $group -PrincipalContextCache $principalContextCache `
                -Credential $Credential -Disposables $disposables

            return @{
                GroupName = $group.Name
                Ensure = 'Present'
                Description = $group.Description
                Members = $members
            }
        }
        else
        {
            # The group was not found.
            return @{
                GroupName = $GroupName
                Ensure = 'Absent'
            }
        }
    }
    finally
    {
        Remove-DisposableObject -Disposables $disposables
    }
}

<#
    .SYNOPSIS
        Retrieves the current state of the group with the specified name on Nano Server.

    .PARAMETER GroupName
        The name of the group to retrieve the current state of.

    .PARAMETER Credential
        A credential to resolve non-local group members.
#>
function Get-TargetResourceOnNanoServer
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    try
    {
        $group = Get-LocalGroup -Name $GroupName -ErrorAction 'Stop'
    }
    catch
    {
        if ($_.CategoryInfo.Reason -eq 'GroupNotFoundException')
        {
            # The group was not found.
            return @{
                GroupName = $GroupName
                Ensure = 'Absent'
            }
        }

        New-InvalidOperationException -ErrorRecord $_
    }

    # The group was found. Find the group members.
    $members = Get-MembersOnNanoServer -Group $group

    return @{
        GroupName = $group.Name
        Ensure = 'Present'
        Description = $group.Description
        Members = $members
    }
}

<#
    .SYNOPSIS
        The Set-TargetResource cmdlet on a full server.

    .PARAMETER GroupName
        The name of the group for which you want to ensure a specific state.

    .PARAMETER Ensure
        Indicates if the group should exist or not.
        
        Set this property to Present to ensure that the group exists.
        Set this property to Absent to ensure that the group does not exist.
        
        The default value is Present.

    .PARAMETER Description
        The description of the group.

    .PARAMETER Members
        Use this property to replace the current group membership with the specified members.
        
        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        an unqualified (username) for local machine accounts.
        
        If you set this property in a configuration, do not use either the MembersToExclude or 
        MembersToInclude property. Doing so will generate an error.

    .PARAMETER MembersToInclude
        Use this property to add members to the existing membership of the group.
        
        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts. 
        
        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER MembersToExclude
        Use this property to remove members from the existing membership of the group.
        
        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts. 
        
        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER Credential
        The credentials required to access remote resources. Note: This account must have the
        appropriate Active Directory permissions to add all non-local accounts to the group.
        Otherwise, an error will occur.
#>
function Set-TargetResourceOnFullSKU
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [String]
        $Description,

        [String[]]
        $Members,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $principalContextCache = @{}
    $disposables = New-Object -TypeName 'System.Collections.ArrayList'

    try
    {
        $principalContext = Get-PrincipalContext `
            -PrincipalContextCache $principalContextCache `
            -Disposables $disposables `
            -Scope $env:computerName

        # Try to find a group by its name.
        $group = Get-Group -GroupName $GroupName -PrincipalContext $principalContext
        $groupOriginallyExists = $null -ne $group

        if ($Ensure -eq 'Present')
        {
            $shouldProcessTarget = $script:localizedData.GroupWithName -f $GroupName
            if ($groupOriginallyExists)
            {
                $null = $disposables.Add($group)
                $whatIfShouldProcess = $PSCmdlet.ShouldProcess($shouldProcessTarget, $script:localizedData.SetOperation)
            }
            else
            {
                $whatIfShouldProcess = $PSCmdlet.ShouldProcess($shouldProcessTarget, $script:localizedData.AddOperation)
            }

            if ($whatIfShouldProcess)
            {
                $saveChanges = $false

                if (-not $groupOriginallyExists)
                {
                    $localPrincipalContext = Get-PrincipalContext -PrincipalContextCache $principalContextCache `
                        -Disposables $disposables -Scope $env:COMPUTERNAME

                    $group = New-Object -TypeName 'System.DirectoryServices.AccountManagement.GroupPrincipal' `
                        -ArgumentList @( $localPrincipalContext )
                    $null = $disposables.Add($group)

                    $group.Name = $GroupName
                    $saveChanges = $true
                }

                # Set group properties.

                if ($PSBoundParameters.ContainsKey('Description') -and $Description -ne $group.Description)
                {
                    $group.Description = $Description
                    $saveChanges = $true
                }

                $actualMembersAsPrincipals = $null

                <#
                    Group members can be updated in two ways:
                    1. Supplying the Members parameter - this causes the membership to be replaced
                        with the members defined in Members.

                        NOTE: If Members is empty, the group membership is cleared.

                    2. Providing MembersToInclude and/or MembersToExclude
                        - this adds/removes members from the list.

                        If Members is mutually exclusive with MembersToInclude and MembersToExclude
                        If Members is not defined then MembersToInclude or MembersToExclude
                        must contain at least one entry.
                #>
                if ($PSBoundParameters.ContainsKey('Members'))
                {
                    foreach ($incompatibleParameterName in @( 'MembersToInclude', 'MembersToExclude' ))
                    {
                        if ($PSBoundParameters.ContainsKey($incompatibleParameterName))
                        {
                            New-InvalidArgumentException -ArgumentName $incompatibleParameterName `
                                -Message ($script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', $incompatibleParameterName)
                        }
                    }

                    if ($groupOriginallyExists)
                    {
                        $actualMembersAsPrincipals = @( Get-MembersAsPrincipalsList `
                            -Group $group `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables `
                            -Credential $Credential
                        )
                    }

                    if ($Members.Count -eq 0 -and $null -ne $actualMembersAsPrincipals -and $actualMembersAsPrincipals.Count -ne 0)
                    {
                        Clear-GroupMembers -Group $group
                        $saveChanges = $true
                    }
                    elseif ($Members.Count -ne 0)
                    {
                        # Remove duplicate names as strings.
                        $uniqueMembers = $Members | Select-Object -Unique

                        # Resolve the names to actual principal objects.
                        $membersAsPrincipals = @( ConvertTo-UniquePrincipalsList `
                            -MemberNames $uniqueMembers `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables `
                            -Credential $Credential )

                        if ($null -ne $actualMembersAsPrincipals -and $actualMembersAsPrincipals.Count -gt 0)
                        {
                            foreach ($memberAsPrincipal in $membersAsPrincipals)
                            {
                                if ($actualMembersAsPrincipals -notcontains $memberAsPrincipal)
                                {
                                    Add-GroupMember -Group $group -MemberAsPrincipal $memberAsPrincipal
                                    $saveChanges = $true
                                }
                            }

                            foreach ($actualMemberAsPrincipal in $actualMembersAsPrincipals)
                            {
                                    if ($membersAsPrincipals -notcontains $actualMemberAsPrincipal)
                                    {
                                        Remove-GroupMember -Group $group -MemberAsPrincipal $actualMemberAsPrincipal
                                        $saveChanges = $true
                                    }
                                }
                        }
                        else
                        {
                            # Set the members of the group
                            foreach ($memberAsPrincipal in $membersAsPrincipals)
                            {
                                    Add-GroupMember -Group $group -MemberAsPrincipal $memberAsPrincipal
                                }

                            $saveChanges = $true
                        }
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.GroupAndMembersEmpty -f $GroupName)
                    }
                }
                elseif ($PSBoundParameters.ContainsKey('MembersToInclude') -or $PSBoundParameters.ContainsKey('MembersToExclude'))
                {
                    if ($groupOriginallyExists)
                    {
                        $actualMembersAsPrincipals = @( Get-MembersAsPrincipalsList `
                            -Group $group `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables `
                            -Credential $Credential
                        )
                    }

                    $membersToIncludeAsPrincipals = $null
                    $uniqueMembersToInclude = $MembersToInclude | Select-Object -Unique

                    if ($null -eq $uniqueMembersToInclude)
                    {
                        Write-Verbose -Message $script:localizedData.MembersToIncludeEmpty
                    }
                    else
                    {
                        # Resolve the names to actual principal objects.
                        $membersToIncludeAsPrincipals = @( ConvertTo-UniquePrincipalsList `
                            -MemberNames $uniqueMembersToInclude `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables `
                            -Credential $Credential
                        )
                    }

                    $membersToExcludeAsPrincipals = $null
                    $uniqueMembersToExclude = $MembersToExclude | Select-Object -Unique

                    if ($null -eq $uniqueMembersToExclude)
                    {
                        Write-Verbose -Message $script:localizedData.MembersToExcludeEmpty
                    }
                    else
                    {
                        # Resolve the names to actual principal objects.
                        $membersToExcludeAsPrincipals = @( ConvertTo-UniquePrincipalsList `
                            -MemberNames $uniqueMembersToExclude `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables `
                            -Credential $Credential
                        )
                    }

                    foreach ($includedPrincipal in $membersToIncludeAsPrincipals)
                    {
                        <#
                            Throw an error if any common principals were provided in MembersToInclude
                            and MembersToExclude.
                        #>
                        if ($membersToExcludeAsPrincipals -contains $includedPrincipal)
                        {
                            New-InvalidArgumentException -ArgumentName 'MembersToInclude and MembersToExclude' `
                                -Message ($script:localizedData.IncludeAndExcludeConflict -f $includedPrincipal.SamAccountName,
                                    'MembersToInclude', 'MembersToExclude')
                        }

                        if ($actualMembersAsPrincipals -notcontains $includedPrincipal)
                        {
                            Add-GroupMember -Group $group -MemberAsPrincipal $includedPrincipal
                            $saveChanges = $true
                        }
                    }

                    foreach ($excludedPrincipal in $membersToExcludeAsPrincipals)
                    {
                        if ($actualMembersAsPrincipals -contains $excludedPrincipal)
                        {
                            Remove-GroupMember -Group $group -MemberAsPrincipal $excludedPrincipal
                            $saveChanges = $true
                        }
                    }
                }

                if ($saveChanges)
                {
                    Save-Group -Group $group

                    # Send an operation success verbose message.
                    if ($groupOriginallyExists)
                    {
                        Write-Verbose -Message ($script:localizedData.GroupUpdated -f $GroupName)
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.GroupCreated -f $GroupName)
                    }
                }
                else
                {
                    Write-Verbose -Message ($script:localizedData.NoConfigurationRequired -f $GroupName)
                }
            }
        }
        else
        {
            if ($groupOriginallyExists)
            {
                if ($PSCmdlet.ShouldProcess(($script:localizedData.GroupWithName -f $GroupName), $script:localizedData.RemoveOperation))
                {
                    # Don't add group to $disposables since Delete also disposes.
                    Remove-Group -Group $group
                    Write-Verbose -Message ($script:localizedData.GroupRemoved -f $GroupName)
                }
                else
                {
                    $null = $disposables.Add($group)
                }
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.NoConfigurationRequiredGroupDoesNotExist -f $GroupName)
            }
        }
    }
    finally
    {
        Remove-DisposableObject -Disposables $disposables
    }
}

<#
    .SYNOPSIS
        The Set-TargetResource cmdlet on Nano Server.

    .PARAMETER GroupName
        The name of the group for which you want to ensure a specific state.

    .PARAMETER Ensure
        Indicates if the group should exist or not.
        
        Set this property to Present to ensure that the group exists.
        Set this property to Absent to ensure that the group does not exist.
        
        The default value is Present.

    .PARAMETER Description
        The description of the group.

    .PARAMETER Members
        Use this property to replace the current group membership with the specified members.
        
        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.
        
        If you set this property in a configuration, do not use either the MembersToExclude or 
        MembersToInclude property. Doing so will generate an error.

    .PARAMETER MembersToInclude
        Use this property to add members to the existing membership of the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.
        
        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER MembersToExclude
        Use this property to remove members from the existing membership of the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.
        
        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER Credential
        Not used on Nano Server.
        Only local users are accessible from the resource.
#>
function Set-TargetResourceOnNanoServer
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [String]
        $Description,

        [String[]]
        $Members,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    try
    {
        $group = Get-LocalGroup -Name $GroupName -ErrorAction 'Stop'
        $groupOriginallyExists = $true
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.Reason -eq 'GroupNotFoundException')
        {
            # A group with the provided name does not exist.
            Write-Verbose -Message ($script:localizedData.GroupDoesNotExist -f $GroupName)
            $groupOriginallyExists = $false
        }
        else
        {
            New-InvalidOperationException -ErrorRecord $_
        }
    }

    if ($Ensure -eq 'Present')
    {
        $whatIfShouldProcess =
            if ($groupOriginallyExists)
            {
                $PSCmdlet.ShouldProcess(($script:localizedData.GroupWithName -f $GroupName),
                    $script:localizedData.SetOperation)
            }
            else
            {
                $PSCmdlet.ShouldProcess(($script:localizedData.GroupWithName -f $GroupName),
                    $script:localizedData.AddOperation)
            }

        if ($whatIfShouldProcess)
        {
            if (-not $groupOriginallyExists)
            {
                $group = New-LocalGroup -Name $GroupName
                Write-Verbose -Message ($script:localizedData.GroupCreated -f $GroupName)
            }

            # Set the group properties.
            if ($PSBoundParameters.ContainsKey('Description') -and 
                ((-not $groupOriginallyExists) -or ($Description -ne $group.Description)))
            {
                Set-LocalGroup -Name $GroupName -Description $Description
            }

            if ($PSBoundParameters.ContainsKey('Members'))
            {
                foreach ($incompatibleParameterName in @( 'MembersToInclude', 'MembersToExclude' ))
                {
                    if ($PSBoundParameters.ContainsKey($incompatibleParameterName))
                    {
                        New-InvalidArgumentException -ArgumentName $incompatibleParameterName `
                            -Message ($script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', $incompatibleParameterName)
                    }
                }

                $groupMembers = Get-MembersOnNanoServer -Group $group

                # Remove duplicate names as strings.
                $uniqueMembers = $Members | Select-Object -Unique

                # Remove unspecified members
                foreach ($groupMember in $groupMembers)
                {
                    if ($uniqueMembers -notcontains $groupMember)
                    {
                        Remove-LocalGroupMember -Group $GroupName -Member $groupMember
                    }
                }

                # Add specified missing members
                foreach ($uniqueMember in $uniqueMembers)
                {
                    if ($groupMembers -notcontains $uniqueMember)
                    {
                        Add-LocalGroupMember -Group $GroupName -Member $uniqueMember
                    }
                }
            }
            elseif ($PSBoundParameters.ContainsKey('MembersToInclude') -or $PSBoundParameters.ContainsKey('MembersToExclude'))
            {
                $groupMembers = Get-MembersOnNanoServer -Group $group

                $uniqueMembersToInclude = $MembersToInclude | Select-Object -Unique
                $uniqueMembersToExclude = $MembersToExclude | Select-Object -Unique

                <#
                    Both MembersToInclude and MembersToExclude were provided.
                    Check if they have common principals.
                #>
                foreach ($includedMember in $uniqueMembersToInclude)
                {
                    foreach($excludedMember in $uniqueMembersToExclude)
                    {
                        if ($includedMember -eq $excludedMember)
                        {
                            New-InvalidArgumentException -ArgumentName 'MembersToInclude and MembersToExclude' `
                                -Message ($script:localizedData.IncludeAndExcludeConflict -f $includedMember, 'MembersToInclude',
                                    'MembersToExclude')
                        }
                    }
                }

                foreach ($includedMember in $uniqueMembersToInclude)
                {
                    if ($groupMembers -notcontains $includedMember)
                    {
                        Add-LocalGroupMember -Group $GroupName -Member $includedMember
                    }
                }

                foreach($excludedMember in $uniqueMembersToExclude)
                {
                    if ($groupMembers -contains $excludedMember)
                    {
                        Remove-LocalGroupMember -Group $GroupName -Member $excludedMember
                    }
                }
            }
        }
    }
    else
    {
        # Ensure is set to "Absent".
        if ($groupOriginallyExists)
        {
            $whatIfShouldProcess = $PSCmdlet.ShouldProcess(
                ($script:localizedData.GroupWithName -f $GroupName), $script:localizedData.RemoveOperation)
            if ($whatIfShouldProcess)
            {
                # The group exists. Remove the group by the provided name.
                Remove-LocalGroup -Name $GroupName
                Write-Verbose -Message ($script:localizedData.GroupRemoved -f $GroupName)
            }
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.NoConfigurationRequiredGroupDoesNotExist -f $GroupName)
        }
    }
}

<#
    .SYNOPSIS
        The Test-TargetResource cmdlet on a full server.
        Tests if the group being managed is in the desired state.

    .PARAMETER GroupName
        The name of the group for which you want to test a specific state.

    .PARAMETER Ensure
        Indicates if the group should exist or not.
        
        Set this property to Present to ensure that the group exists.
        Set this property to Absent to ensure that the group does not exist.
        
        The default value is Present.

    .PARAMETER Description
        The description of the group to test for.

    .PARAMETER Members
        Use this property to test if the existing membership of the group matches
        the list provided.
        
        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use either the MembersToExclude or
        MembersToInclude property. Doing so will generate an error.

    .PARAMETER MembersToInclude
        Use this property to test if members need to be added to the existing membership
        of the group. 

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER MembersToExclude
        Use this property to test if members need to removed from the existing membership
        of the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER Credential
        The credentials required to resolve non-local group members
#>
function Test-TargetResourceOnFullSKU
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [String]
        $Description,

        [String[]]
        $Members,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $principalContextCache = @{}
    $disposables = New-Object -TypeName 'System.Collections.ArrayList'

    try
    {
        $principalContext = Get-PrincipalContext `
            -PrincipalContextCache $PrincipalContextCache `
            -Disposables $disposables `
            -Scope $env:computerName

        $group = Get-Group -GroupName $GroupName -PrincipalContext $principalContext

        if ($null -eq $group)
        {
            Write-Verbose -Message ($script:localizedData.GroupDoesNotExist -f $GroupName)
            return $Ensure -eq 'Absent'
        }

        $null = $disposables.Add($group)
        Write-Verbose -Message ($script:localizedData.GroupExists -f $GroupName)

        # Validate separate properties.
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Ensure', 'Absent', 'Present')
            return $false
        }

        if ($PSBoundParameters.ContainsKey('Description') -and $Description -ne $group.Description)
        {
            Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Description', $Description, $group.Description)
            return $false
        }

        if ($PSBoundParameters.ContainsKey('Members'))
        {
            foreach ($incompatibleParameterName in @( 'MembersToInclude', 'MembersToExclude' ))
            {
                if ($PSBoundParameters.ContainsKey($incompatibleParameterName))
                {
                    New-InvalidArgumentException -ArgumentName $incompatibleParameterName `
                        -Message ($script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', $incompatibleParameterName)
                }
            }

            $actualMembersAsPrincipals = @( Get-MembersAsPrincipalsList `
                -Group $group `
                -PrincipalContextCache $principalContextCache `
                -Disposables $disposables `
                -Credential $Credential
            )

            $uniqueMembers = $Members | Select-Object -Unique

            if ($null -eq $uniqueMembers)
            {
                return ($null -eq $actualMembersAsPrincipals -or $actualMembersAsPrincipals.Count -eq 0)
            }
            else
            {
                if ($null -eq $actualMembersAsPrincipals -or $actualMembersAsPrincipals.Count -eq 0)
                {
                    return $false
                }

                # Resolve the names to actual principal objects.
                $expectedMembersAsPrincipals = @( ConvertTo-UniquePrincipalsList `
                    -MemberNames $uniqueMembers `
                    -PrincipalContextCache $principalContextCache `
                    -Disposables $disposables `
                    -Credential $Credential
                )

                if ($expectedMembersAsPrincipals.Count -ne $actualMembersAsPrincipals.Count)
                {
                    Write-Verbose -Message ($script:localizedData.MembersNumberMismatch -f 'Members',
                        $expectedMembersAsPrincipals.Count, $actualMembersAsPrincipals.Count)
                    return $false
                }

                # Compare the two member lists.
                foreach ($expectedMemberAsPrincipal in $expectedMembersAsPrincipals)
                {
                    if ($actualMembersAsPrincipals -notcontains $expectedMemberAsPrincipal)
                    {
                        Write-Verbose -Message ($script:localizedData.MembersMemberMismatch -f $expectedMemberAsPrincipal.SamAccountName,
                            'Members', $group.SamAccountName)
                        return $false
                    }
                }
            }
        }
        elseif ($PSBoundParameters.ContainsKey('MembersToInclude') -or $PSBoundParameters.ContainsKey('MembersToExclude'))
        {
            $actualMembersAsPrincipals = @( Get-MembersAsPrincipalsList `
                -Group $group `
                -PrincipalContextCache $principalContextCache `
                -Disposables $disposables `
                -Credential $Credential
            )

            $membersToIncludeAsPrincipals = $null
            $uniqueMembersToInclude = $MembersToInclude | Select-Object -Unique

            if ($null -eq $uniqueMembersToInclude)
            {
                Write-Verbose -Message $script:localizedData.MembersToIncludeEmpty
            }
            else
            {
                # Resolve the names to actual principal objects.
                $membersToIncludeAsPrincipals = @( ConvertTo-UniquePrincipalsList `
                    -MemberNames $uniqueMembersToInclude `
                    -PrincipalContextCache $principalContextCache `
                    -Disposables $disposables `
                    -Credential $Credential
                )
            }

            $membersToExcludeAsPrincipals = $null
            $uniqueMembersToExclude = $MembersToExclude | Select-Object -Unique

            if ($null -eq $uniqueMembersToExclude)
            {
                Write-Verbose -Message $script:localizedData.MembersToExcludeEmpty
            }
            else
            {
                # Resolve the names to actual principal objects.
                $membersToExcludeAsPrincipals = @( ConvertTo-UniquePrincipalsList `
                    -MemberNames $uniqueMembersToExclude `
                    -PrincipalContextCache $principalContextCache `
                    -Disposables $disposables `
                    -Credential $Credential
                )
            }

            foreach ($includedPrincipal in $membersToIncludeAsPrincipals)
            {
                <#
                    Throw an error if any common principals were provided in MembersToInclude
                    and MembersToExclude.
                #>
                if ($membersToExcludeAsPrincipals -contains $includedPrincipal)
                {
                    New-InvalidArgumentException -ArgumentName 'MembersToInclude and MembersToExclude' `
                        -Message ($script:localizedData.IncludeAndExcludeConflict -f $includedPrincipal.SamAccountName,
                            'MembersToInclude', 'MembersToExclude')
                }

                if ($actualMembersAsPrincipals -notcontains $includedPrincipal)
                {
                    return $false
                }
            }

            foreach ($excludedPrincipal in $membersToExcludeAsPrincipals)
            {
                if ($actualMembersAsPrincipals -contains $excludedPrincipal)
                {
                    return $false
                }
            }
        }
    }
    finally
    {
        Remove-DisposableObject -Disposables $disposables
    }

    return $true
}

<#
    .SYNOPSIS
        The Test-TargetResource cmdlet on a Nano server
        Tests if the group being managed is in the desired state.

    .PARAMETER GroupName
        The name of the group for which you want to test a specific state.

    .PARAMETER Ensure
        Indicates if the group should exist or not.
        
        Set this property to Present to ensure that the group exists.
        Set this property to Absent to ensure that the group does not exist.
        
        The default value is Present.

    .PARAMETER Description
        The description of the group to test for.

    .PARAMETER Members
        Use this property to test if the existing membership of the group matches
        the list provided.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use either the MembersToExclude or
        MembersToInclude property. Doing so will generate an error.

    .PARAMETER MembersToInclude
        Use this property to test if members need to be added to the existing membership
        of the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER MembersToExclude
        Use this property to test if members need to removed from the existing membership
        of the group.

        The value of this property is an array of strings of the formats domain qualified name 
        (domain\username), UPN (username@domainname), distinguished name (CN=username,DC=...) and/or
        a unqualified (username) for local machine accounts.

        If you set this property in a configuration, do not use the Members property.
        Doing so will generate an error.

    .PARAMETER Credential
        The credentials required to resolve non-local group members
#>
function Test-TargetResourceOnNanoServer
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [String]
        $Description,

        [String[]]
        $Members,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    try
    {
        $group = Get-LocalGroup -Name $GroupName -ErrorAction Stop
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.Reason -eq 'GroupNotFoundException')
        {
            # A group with the provided name does not exist.
            Write-Verbose -Message ($script:localizedData.GroupDoesNotExist -f $GroupName)

            return ($Ensure -eq 'Absent')
        }

        New-InvalidOperationException -ErrorRecord $_
    }

    # A group with the provided name exists.
    Write-Verbose -Message ($script:localizedData.GroupExists -f $GroupName)

    # Validate separate properties.
    if ($Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Ensure', 'Absent', 'Present')
        return $false
    }

    if ($PSBoundParameters.ContainsKey('Description') -and $Description -ne $group.Description)
    {
        Write-Verbose -Message ($script:localizedData.PropertyMismatch -f 'Description', $Description, $group.Description)
        return $false
    }

    if ($PSBoundParameters.ContainsKey('Members'))
    {
        foreach ($incompatibleParameterName in @( 'MembersToInclude', 'MembersToExclude' ))
        {
            if ($PSBoundParameters.ContainsKey($incompatibleParameterName))
            {
                New-InvalidArgumentException -ArgumentName $incompatibleParameterName `
                    -Message ($script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', $incompatibleParameterName)
            }
        }

        $groupMembers = Get-MembersOnNanoServer -Group $group

        # Remove duplicate names as strings.
        $uniqueMembers = $Members | Select-Object -Unique

        if ($null -eq $uniqueMembers)
        {
            return ($null -eq $groupMembers -or $groupMembers.Count -eq 0)
        }
        else
        {
            if ($null -eq $groupMembers -or $uniqueMembers.Count -ne $groupMembers.Count)
            {
                return $false
            }

            foreach ($groupMember in $groupMembers)
            {
                if ($uniqueMembers -notcontains $groupMember)
                {
                    return $false
                }
            }
        }
    }
    elseif ($PSBoundParameters.ContainsKey('MembersToInclude') -or $PSBoundParameters.ContainsKey('MembersToExclude'))
    {
        $groupMembers = Get-MembersOnNanoServer -Group $group

        $uniqueMembersToInclude = $MembersToInclude | Select-Object -Unique
        $uniqueMembersToExclude = $MembersToExclude | Select-Object -Unique

        <#
            Both MembersToInclude and MembersToExclude were provided.
            Check if they have common principals.
        #>
        foreach ($includedMember in $uniqueMembersToInclude)
        {
            foreach($excludedMember in $uniqueMembersToExclude)
            {
                if ($includedMember -eq $excludedMember)
                {
                    New-InvalidArgumentException -ArgumentName 'MembersToInclude and MembersToExclude' `
                        -Message ($script:localizedData.IncludeAndExcludeConflict -f $includedMember, 'MembersToInclude',
                            'MembersToExclude')
                }
            }
        }

        foreach ($includedMember in $uniqueMembersToInclude)
        {
            if ($groupMembers -notcontains $includedMember)
            {
                return $false
            }
        }

        foreach($excludedMember in $uniqueMembersToExclude)
        {
            if ($groupMembers -contains $excludedMember)
            {
                return $false
            }
        }
    }

    # All properties match. Return $true.
    return $true
}

<#
    .SYNOPSIS
        Retrieves the members of a group on a Nano server.

    .PARAMETER Group
        The LocalGroup Object to retrieve members for.
#>
function Get-MembersOnNanoServer
{
    [OutputType([System.String[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Microsoft.PowerShell.Commands.LocalGroup]
        $Group
    )

    $localMemberNames = New-Object -TypeName 'System.Collections.ArrayList'

    # Get the group members.
    $groupMembers = Get-LocalGroupMember -Group $Group

    foreach ($groupMember in $groupMembers)
    {
        if ($groupMember.PrincipalSource -ieq 'Local')
        {
            $localMemberName = $groupMember.Name.Substring($groupMember.Name.IndexOf('\') + 1)
            $null = $localMemberNames.Add($localMemberName)
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.MemberIsNotALocalUser -f $groupMember.Name,
                $groupMember.PrincipalSource)
        }
    }

    return $localMemberNames.ToArray()
}

<#
    .SYNOPSIS
        Retrieves the members of the given a group on a full server.

    .PARAMETER Group
        The GroupPrincipal Object to retrieve members for.

    .PARAMETER PrincipalContextCache
        A hashtable cache of PrincipalContext instances for each scope.
        This is used to cache PrincipalContext instances for cases where it is used multiple times.

    .PARAMETER Disposables
        The ArrayList of disposable objects to which to add any objects that need to be disposed.

    .PARAMETER Credential
        The network credential to use when explicit credentials are needed for the target domain.
#>
function Get-MembersOnFullSKU
{
    [OutputType([System.String[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        [AllowEmptyCollection()]
        $PrincipalContextCache,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.ArrayList]
        [AllowEmptyCollection()]
        $Disposables,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $members = New-Object -TypeName 'System.Collections.ArrayList'

    $membersAsPrincipals = @( Get-MembersAsPrincipalsList `
        -Group $Group `
        -PrincipalContextCache $PrincipalContextCache `
        -Disposables $Disposables `
        -Credential $Credential
    )

    foreach ($memberAsPrincipal in $membersAsPrincipals)
    {
        if ($memberAsPrincipal.ContextType -eq [System.DirectoryServices.AccountManagement.ContextType]::Domain)
        {
            # Select only the first part of the full domain name.
            $domainName = $memberAsPrincipal.Context.Name

            $domainNameDotIndex = $domainName.IndexOf('.')
            if ($domainNameDotIndex -ne -1)
            {
                $domainName = $domainName.Substring(0, $domainNameDotIndex)
            }

            if ($memberAsPrincipal.StructuralObjectClass -ieq 'computer')
            {
                $null = $members.Add($domainName + '\' + $memberAsPrincipal.Name)
            }
            else
            {
                $null = $members.Add($domainName + '\' + $memberAsPrincipal.SamAccountName)
            }
        }
        else
        {
            $null = $members.Add($memberAsPrincipal.Name)
        }
    }

    return $members.ToArray()
}

<#
    .SYNOPSIS
        Retrieves the members of a group as Principal instances.

    .PARAMETER Group
        The group to retrieve members for.

    .PARAMETER PrincipalContextCache
        A hashtable cache of PrincipalContext instances for each scope.
        This is used to cache PrincipalContext instances for cases where it is used multiple times.

    .PARAMETER Disposables
        The ArrayList of disposable objects to which to add any objects that need to be disposed.

    .PARAMETER Credential
        The network credential to use when explicit credentials are needed for the target domain.
#>
function Get-MembersAsPrincipalsList
{
    [OutputType([System.DirectoryServices.AccountManagement.Principal[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        [AllowEmptyCollection()]
        $PrincipalContextCache,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.ArrayList]
        [AllowEmptyCollection()]
        $Disposables,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $principals = New-Object -TypeName 'System.Collections.ArrayList'

    <#
        This logic enumerates the group members using the underlying DirectoryEntry API. This is
        needed because enumerating the group members as principal instances causes a resolve to
        occur. Since there is no facility for passing credentials to perform the resolution, any
        members that cannot be resolved using the current user will fail (such as when this
        resource runs as SYSTEM). Dropping down to the underyling DirectoryEntry API allows us to
        access the account's SID which can then be used to resolve the associated principal using
        explicit credentials.
    #>
    $groupDirectoryMembers = Get-GroupMembersFromDirectoryEntry -Group $Group

    foreach ($groupDirectoryMember in $groupDirectoryMembers)
    {
        # Extract the ObjectSid from the underlying DirectoryEntry
        $memberDirectoryEntry = New-Object -TypeName 'System.DirectoryServices.DirectoryEntry' `
            -ArgumentList @( $groupDirectoryMember )
        $null = $disposables.Add($memberDirectoryEntry)

        $memberDirectoryEntryPathParts = $memberDirectoryEntry.Path.Split('/')

        if ($memberDirectoryEntryPathParts.Count -eq 4)
        {
            # Parsing WinNT://domainname/accountname or WinNT://machinename/accountname
            $scope = $memberDirectoryEntryPathParts[2]
            $accountName = $memberDirectoryEntryPathParts[3]
        }
        elseif ($memberDirectoryEntryPathParts.Count -eq 5)
        {
            # Parsing WinNT://domainname/machinename/accountname
            $scope = $memberDirectoryEntryPathParts[3]
            $accountName = $memberDirectoryEntryPathParts[4]
        }
        else
        {
            <#
                The account is stale either becuase it was deleted or the machine was moved to a
                new domain without removing the domain members from the group. If we consider this
                a fatal error, the group is no longer managable by the DSC resource.  Writing a
                warning allows the operation to complete while leaving the stale member in the
                group.
            #>
            Write-Warning -Message ($script:localizedData.MemberNotValid -f $memberDirectoryEntry.Path)
            continue
        }

        $principalContext = Get-PrincipalContext `
            -Scope $scope `
            -Credential $Credential `
            -PrincipalContextCache $PrincipalContextCache `
            -Disposables $Disposables

        # If local machine qualified, get the PrincipalContext for the local machine
        if (Test-IsLocalMachine -Scope $scope)
        {
            Write-Verbose -Message ($script:localizedData.ResolvingLocalAccount -f $accountName)
        }
        # The account is domain qualified - credential required to resolve it.
        elseif ($null -ne $principalContext)
        {
            Write-Verbose -Message ($script:localizedData.ResolvingDomainAccount -f $accountName, $scope)
        }
        else
        {
            <#
                The provided name is not scoped to the local machine and no credential was
                provided. This is an unsupported use case. A credential is required to resolve
                off-box.
            #>
            New-InvalidArgumentException -ArgumentName 'Credential' `
                -Message ($script:localizedData.DomainCredentialsRequired -f $accountName)
        }

        # Create a SID to enable comparison againt the expected member's SID.
        $memberSidBytes = $memberDirectoryEntry.Properties['ObjectSid'].Value
        $memberSid = New-Object -TypeName 'System.Security.Principal.SecurityIdentifier' `
            -ArgumentList @( $memberSidBytes, 0 )

        $principal = Resolve-SidToPrincipal -PrincipalContext $principalContext -Sid $memberSid -Scope $scope
        $null = $disposables.Add($principal)

        $null = $principals.Add($principal)
    }

    return $principals.ToArray()
}

<#
    .SYNOPSIS
        Throws an error if a group name contains invalid characters.

    .PARAMETER GroupName
        The group name to test.
#>
function Assert-GroupNameValid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName
    )

    $invalidCharacters = @( '\', '/', '"', '[', ']', ':', '|', '<', '>', '+', '=', ';', ',', '?', '*', '@' )

    if ($GroupName.IndexOfAny($invalidCharacters) -ne -1)
    {
        New-InvalidArgumentException -ArgumentName 'GroupName' `
            -Message ($script:localizedData.InvalidGroupName -f $GroupName, [String]::Join(' ', $invalidCharacters))
    }

    $nameContainsOnlyWhitspaceOrDots = $true

    # Check if the name consists of only periods and/or white spaces.
    for ($groupNameIndex = 0; $groupNameIndex -lt $GroupName.Length; $groupNameIndex++)
    {
        if (-not [Char]::IsWhiteSpace($GroupName, $groupNameIndex) -and $GroupName[$groupNameIndex] -ne '.')
        {
            $nameContainsOnlyWhitspaceOrDots = $false
            break
        }
    }

    if ($nameContainsOnlyWhitspaceOrDots)
    {
        New-InvalidArgumentException -ArgumentName 'GroupName' `
            -Message ($script:localizedData.InvalidGroupName -f $GroupName, [String]::Join(' ', $invalidCharacters))
    }
}

<#
    .SYNOPSIS
        Resolves an array of member names to Principal instances.

    .PARAMETER MemberNames
        The member names to convert to Principal instances.

    .PARAMETER PrincipalContextCache
        A hashtable cache of PrincipalContext instances for each scope.
        This is used to cache PrincipalContext instances for cases where it is used multiple times.

    .PARAMETER Disposables
        The ArrayList of disposable objects to which to add any objects that need to be disposed.

    .PARAMETER Credential
        The network credential to use when explicit credentials are needed for the target domain.
#>
function ConvertTo-UniquePrincipalsList
{
    [OutputType([System.DirectoryServices.AccountManagement.Principal[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String[]]
        $MemberNames,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        [AllowEmptyCollection()]
        $PrincipalContextCache,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.ArrayList]
        [AllowEmptyCollection()]
        $Disposables,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $principals = @()

    foreach ($memberName in $MemberNames)
    {
        $principal = ConvertTo-Principal `
            -MemberName $memberName `
            -PrincipalContextCache $PrincipalContextCache `
            -Disposables $Disposables `
            -Credential $Credential

        if ($null -ne $principal)
        {
            # Do not add duplicate entries
            if ($principal.ContextType -eq [System.DirectoryServices.AccountManagement.ContextType]::Domain)
            {
                $duplicatePrincipal = $principals | Where-Object -FilterScript { $_.DistinguishedName -ieq $principal.DistinguishedName }

                if ($null -eq $duplicatePrincipal)
                {
                    $principals += $principal
                }
            }
            else
            {
                $duplicatePrincipal = $principals | Where-Object -FilterScript { $_.SamAccountName -ieq $principal.SamAccountName }

                if ($null -eq $duplicatePrincipal)
                {
                    $principals += $principal
                }
            }
        }
    }

    return $principals
}

<#
    .SYNOPSIS
        Resolves a member name to a Principal instance.

    .PARAMETER MemberName
        The member name to convert to a Principal instance.

    .PARAMETER PrincipalContextCache
        A hashtable cache of PrincipalContext instances for each scope.
        This is used to cache PrincipalContext instances for cases where it is used multiple times.

    .PARAMETER Disposables
        The ArrayList of disposable objects to which to add any objects that need to be disposed.

    .PARAMETER Credential
        The network credential to use when explicit credentials are needed for the target domain.

    .NOTES
        ConvertTo-Principal will fail if a machine name is specified as domainname\machinename. It
        will succeed if the machine name is specified as the SAM name (domainname\machinename$) or
        as the unqualified machine name.

        Split-MemberName splits the scope and account name to avoid this problem.
#>
function ConvertTo-Principal
{
    [OutputType([System.DirectoryServices.AccountManagement.Principal])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        $MemberName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        [AllowEmptyCollection()]
        $PrincipalContextCache,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.ArrayList]
        [AllowEmptyCollection()]
        $Disposables,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    # The scope of the the object name when in the form of scope\name, UPN, or DN
    $scope, $identityValue = Split-MemberName -MemberName $MemberName

    if (Test-IsLocalMachine -Scope $scope)
    {
        # If local machine qualified, get the PrincipalContext for the local machine
        Write-Verbose -Message ($script:localizedData.ResolvingLocalAccount -f $identityValue)
    }
    elseif ($null -ne $Credential)
    {
        # The account is domain qualified - a credential is provided to resolve it.
        Write-Verbose -Message ($script:localizedData.ResolvingDomainAccount -f $identityValue, $scope)
    }
    else
    {
        <#
            The provided name is not scoped to the local machine and no credentials were provided.
            If the object is a domain qualified name, we can try to resolve the user with domain
            trust, if setup. When using domain trust, we use the object name to resolve. Object
            name can be in different formats such as a domain qualified name, UPN, or a
            distinguished name for the scope
        #>

        Write-Verbose -Message ($script:localizedData.ResolvingDomainAccountWithTrust -f $MemberName)
        $identityValue = $MemberName
    }

    $principalContext = Get-PrincipalContext `
        -Scope $scope `
        -PrincipalContextCache $PrincipalContextCache `
        -Disposables $Disposables `
        -Credential $Credential

    try
    {
        $principal = Find-Principal -PrincipalContext $principalContext -IdentityValue $identityValue
    }
    catch [System.Runtime.InteropServices.COMException]
    {
        New-InvalidArgumentException -ArgumentName $MemberName `
            -Message ( $script:localizedData.UnableToResolveAccount -f $MemberName, $_.Exception.Message, $_.Exception.HResult )
    }

    if ($null -eq $principal)
    {
        New-InvalidArgumentException -ArgumentName $MemberName -Message ($script:localizedData.CouldNotFindPrincipal -f $MemberName)
    }

    return $principal
}

<#
    .SYNOPSIS
        Resolves a SID to a principal.

    .PARAMETER Sid
        The security identifier to resolve to a Principal.

    .PARAMETER PrincipalContext
        The PrincipalContext to use to resolve the Principal.

    .PARAMETER Scope
        The scope of the PrincipalContext.
#>
function Resolve-SidToPrincipal
{
    [OutputType([System.DirectoryServices.AccountManagement.Principal])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Security.Principal.SecurityIdentifier]
        $Sid,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.PrincipalContext]
        $PrincipalContext,

        [Parameter(Mandatory = $true)]
        [String]
        $Scope
    )

    $principal = Find-Principal -PrincipalContext $PrincipalContext -IdentityValue $Sid.Value -IdentityType ([System.DirectoryServices.AccountManagement.IdentityType]::Sid)

    if ($null -eq $principal)
    {
        if (Test-IsLocalMachine -Scope $Scope)
        {
            New-InvalidArgumentException -ArgumentName 'Members, MembersToInclude, or MembersToExclude' -Message ($script:localizedData.CouldNotFindPrincipal -f $Sid.Value)
        }
        else
        {
            New-InvalidArgumentException -ArgumentName 'Members, MembersToInclude, MembersToExclude, or Credential' -Message ($script:localizedData.CouldNotFindPrincipal -f $Sid.Value)
        }
    }

    return $principal
}

<#
    .SYNOPSIS
        Retrieves a PrincipalContext to use to resolve an object in the given scope.

    .PARAMETER Scope
        The scope to retrieve the principal context for.

    .PARAMETER Credential
        The network credential to use when explicit credentials are needed for the target domain.

    .PARAMETER PrincipalContextCache
        A hashtable cache of PrincipalContext instances for each scope.
        This is used to cache PrincipalContext instances for cases where it is used multiple times.

    .PARAMETER Disposables
        The ArrayList of disposable objects to which to add any objects that need to be disposed.

    .NOTES
        When a new PrincipalContext is created, it is added to the Disposables list
        as well as the PrincipalContextCache.
#>
function Get-PrincipalContext
{
    [OutputType([System.DirectoryServices.AccountManagement.PrincipalContext])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Scope,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        [AllowEmptyCollection()]
        $PrincipalContextCache,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.ArrayList]
        [AllowEmptyCollection()]
        $Disposables
    )

    $principalContext = $null

    if (Test-IsLocalMachine -Scope $Scope)
    {
        # Check for a cached PrincipalContext for the local machine.
        if ($PrincipalContextCache.ContainsKey($env:computerName))
        {
            $principalContext = $PrincipalContextCache[$env:computerName]
        }
        else
        {
            # Create a PrincipalContext for the local machine
            $principalContext = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' `
                -ArgumentList @( [System.DirectoryServices.AccountManagement.ContextType]::Machine )

            # Cache the PrincipalContext for this scope for subsequent calls.
            $null = $PrincipalContextCache.Add($env:computerName, $principalContext)
            $null = $Disposables.Add($principalContext)
        }
    }
    elseif ($PrincipalContextCache.ContainsKey($Scope))
    {
        $principalContext = $PrincipalContextCache[$Scope]
    }
    elseif ($null -ne $Credential)
    {
        # Create a PrincipalContext targeting $Scope using the network credentials that were passed in.
        $credentialDomain = $Credential.GetNetworkCredential().Domain
        $credentialUserName = $Credential.GetNetworkCredential().UserName
        if ($credentialDomain -ne [String]::Empty)
        {
            $principalContextName = "$credentialDomain\$credentialUserName"
        }
        else
        {
            $principalContextName = $credentialUserName
        }

        $principalContext = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' `
            -ArgumentList @( [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Scope, 
                $principalContextName, $Credential.GetNetworkCredential().Password )

        # Cache the PrincipalContext for this scope for subsequent calls.
        $null = $PrincipalContextCache.Add($Scope, $principalContext)
        $null = $Disposables.Add($principalContext)
    }
    else
    {
        # Get a PrincipalContext for the current user in the target domain (even for local System account).
        $principalContext = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' `
            -ArgumentList @( [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Scope )

        # Cache the PrincipalContext for this scope for subsequent calls.
        $null = $PrincipalContextCache.Add($Scope, $principalContext)
        $null = $Disposables.Add($principalContext)
    }

    return $principalContext
}

<#
    .SYNOPSIS
        Determines if a scope represents the current machine.

    .PARAMETER Scope
        The scope to test.
#>
function Test-IsLocalMachine
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Scope
    )

    $localMachineScopes = @( '.', $env:computerName, 'localhost', '127.0.0.1', 'NT Authority', 'NT Service', 'BuiltIn' )

    if ($localMachineScopes -icontains $Scope)
    {
        return $true
    }

    <#
        Determine if we have an ip address that matches an ip address on one of the network
        adapters. This is likely overkill. Consider removing it.
    #>
    if ($Scope.Contains('.'))
    {
        $win32NetworkAdapterConfigurations = @( Get-CimInstance -ClassName 'Win32_NetworkAdapterConfiguration' )
        foreach ($win32NetworkAdapterConfiguration in $win32NetworkAdapterConfigurations)
        {
            if ($null -ne $win32NetworkAdapterConfiguration.IPAddress)
            {
                foreach ($ipAddress in $win32NetworkAdapterConfiguration.IPAddress)
                {
                    if ($ipAddress -eq $Scope)
                    {
                        return $true
                    }
                }
            }
        }
    }

    return $false
}

<#
    .SYNOPSIS
        Splits a member name into the scope and the account name.


    .DESCRIPTION
        The returned $scope is used to determine where to perform the resolution, the local machine
        or a target domain. The returned $accountName is the name of the account to resolve.

        The following details the formats that are handled as well as how the values are
        determined:

        Domain Qualified Names: (domainname\username)

        The value is split on the first '\' character with the left hand side returned as the scope
        and the right hand side returned as the account name.

        UPN: (username@domainname)

        The value is split on the first '@' character with the left hand side returned as the
        account name and the right hand side returned as the scope.

        Distinguished Name:

        The value at the first occurance of 'DC=' is used to extract the unqualified domain name.
        The incoming string is returned, as is, for the account name.

        Unqualified Account Names:

        The incoming string is returned as the account name and the local machine name is returned
        as the scope. Note that values that do not fall into the above categories are interpreted
        as unqualified account names.

    .PARAMETER MemberName
        The full name of the member to split.

    .NOTES
        ConvertTo-Principal will fail if a machine name is specified as domainname\machinename. It
        will succeed if the machine name is specified as the SAM name (domainname\machinename$) or
        as the unqualified machine name.

        Split-MemberName splits the scope and account name to avoid this problem.
#>
function Split-MemberName
{
    [OutputType([System.String[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MemberName
    )

    # Assume no scope is defined or $FullName is a DistinguishedName
    $scope = $env:computerName
    $accountName = $MemberName

    # Parse domain or machine qualified account name
    $separatorIndex = $MemberName.IndexOf('\')
    if ($separatorIndex -ne -1)
    {
        $scope = $MemberName.Substring(0, $separatorIndex)

        if (Test-IsLocalMachine -Scope $scope)
        {
            $scope = $env:computerName
        }

        $accountName = $MemberName.Substring($separatorIndex + 1)

        return [System.String[]] @( $scope, $accountName )
    }

    # Parse UPN for the scope
    $separatorIndex = $MemberName.IndexOf('@')
    if ($separatorIndex -ne -1)
    {
        $scope = $MemberName.Substring($separatorIndex + 1)
        $accountName = $MemberName.Substring(0, $separatorIndex)

        return [System.String[]] @( $scope, $accountName )
    }

    # Parse distinguished name for the scope
    $distinguishedNamePrefix = 'DC='

    $separatorIndex = $MemberName.IndexOf($distinguishedNamePrefix, [System.StringComparison]::OrdinalIgnoreCase)
    if ($separatorIndex -ne -1)
    {
        <#
            For member names in the distinguished name format, the account name returned should be
            the entire distinguished name.
            See the initialization of $accountName above.
        #>

        $startScopeIndex = $separatorIndex + $distinguishedNamePrefix.Length
        $endScopeIndex = $MemberName.IndexOf(',', $startScopeIndex)

        if ($endScopeIndex -gt $startScopeIndex)
        {
            $scopeLength = $endScopeIndex - $separatorIndex - $distinguishedNamePrefix.Length
            $scope = $MemberName.Substring($startScopeIndex, $scopeLength)

            return [System.String[]] @( $scope, $accountName )
        }
    }

    return [System.String[]] @( $scope, $accountName )
}

<#
    .SYNOPSIS
        Finds a principal by identity.
        Wrapper function for testing.

    .PARAMETER PrincipalContext
        The principal context to find the principal in.

    .PARAMETER IdentityValue
        The identity value to find the principal by (e.g. username).

    .PARAMETER IdentityType
        The identity type of the principal to find.
#>
function Find-Principal
{
    [OutputType([System.DirectoryServices.AccountManagement.Principal])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.AccountManagement.PrincipalContext]
        $PrincipalContext,

        [Parameter(Mandatory = $true)]
        [String]
        $IdentityValue,

        [System.DirectoryServices.AccountManagement.IdentityType]
        $IdentityType
    )

    if ($PSBoundParameters.ContainsKey('IdentityType'))
    {
        return [System.DirectoryServices.AccountManagement.Principal]::FindByIdentity($PrincipalContext, $IdentityType, $IdentityValue)
    }
    else
    {
        return [System.DirectoryServices.AccountManagement.Principal]::FindByIdentity($PrincipalContext, $IdentityValue)
    }
    
}

<#
    .SYNOPSIS
        Retrieves a local Windows group.

    .PARAMETER GroupName
        The name of the group to retrieve.

    .PARAMETER Disposables
        The ArrayList of disposable objects to which to add any objects that need to be disposed.

    .PARAMETER PrincipalContextCache
        A hashtable cache of PrincipalContext instances for each scope.
        This is used to cache PrincipalContext instances for cases where it is used multiple times.

    .NOTES
        The returned value is NOT added to the $disposables list because the caller may need to
        call $group.Delete() which also disposes it.
#>
function Get-Group
{
    [OutputType([System.DirectoryServices.AccountManagement.GroupPrincipal])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.AccountManagement.PrincipalContext]
        $PrincipalContext
    )

    $principalContext = Get-PrincipalContext `
        -PrincipalContextCache $PrincipalContextCache `
        -Disposables $Disposables `
        -Scope $env:COMPUTERNAME

    try
    {
        $group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($PrincipalContext, $GroupName)
    }
    catch
    {
        $group = $null
    }

    return $group
}

<#
    .SYNOPSIS
        Retrieves the members of a group from the underlying directory entry.

    .PARAMETER Group
        The group to retrieve the members of.
#>
function Get-GroupMembersFromDirectoryEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group
    )

    $groupDirectoryEntry = $Group.GetUnderlyingObject()
    return $groupDirectoryEntry.Invoke('Members')
}

<#
    .SYNOPSIS
        Clears the members of the specified group.
        This is a wrapper function for testing purposes.

    .PARAMETER Group
        The group to clear the members of.
#>
function Clear-GroupMembers
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group
    )
    
    $Group.Members.Clear()
}

<#
    .SYNOPSIS
        Adds the specified member to the specified group.
        This is a wrapper function for testing purposes.

    .PARAMETER Group
        The group to add the member to.

    .PARAMETER MemberAsPrincipal
        The member to add to the group as a principal.
#>
function Add-GroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.Principal]
        $MemberAsPrincipal
    )

    $Group.Members.Add($MemberAsPrincipal)
}

<#
    .SYNOPSIS
        Removes the specified member from the specified group.
        This is a wrapper function for testing purposes.

    .PARAMETER Group
        The group to remove the member from.

    .PARAMETER MemberAsPrincipal
        The member to remove from the group as a principal.
#>
function Remove-GroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.Principal]
        $MemberAsPrincipal
    )

    $Group.Members.Remove($MemberAsPrincipal)
}

<#
    .SYNOPSIS
        Deletes the specified group.
        This is a wrapper function for testing purposes.

    .PARAMETER Group
        The group to delete.
#>
function Remove-Group
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group
    )
    
    $Group.Delete()
}

<#
    .SYNOPSIS
        Saves the specified group.
        This is a wrapper function for testing purposes.

    .PARAMETER Group
        The group to save.
#>
function Save-Group
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.DirectoryServices.AccountManagement.GroupPrincipal]
        $Group
    )

    $Group.Save()
}

<#
    .SYNOPSIS
        Disposes of the contents of an array list containing IDisposable objects.

    .PARAMETER Disosables
        The array list of IDisposable Objects to dispose of.
#>
function Remove-DisposableObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Collections.ArrayList]
        [AllowEmptyCollection()]
        $Disposables
    )

    foreach ($disposable in $Disposables)
    {
        if ($disposable -is [System.IDisposable])
        {
            $disposable.Dispose()
        }
    }
}
