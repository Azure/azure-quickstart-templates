# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        RetrievingGroupMembers         = Retrieving group membership based on '{0}' property.
        GroupMembershipInDesiredState  = Group membership is in the desired state.
        GroupMembershipNotDesiredState = Group membership is NOT in the desired state.

        AddingGroupMembers             = Adding '{0}' member(s) to AD group '{1}'.
        RemovingGroupMembers           = Removing '{0}' member(s) from AD group '{1}'.
        AddingGroup                    = Adding AD Group '{0}'
        UpdatingGroup                  = Updating AD Group '{0}'
        RemovingGroup                  = Removing AD Group '{0}'
        MovingGroup                    = Moving AD Group '{0}' to '{1}'
        GroupNotFound                  = AD Group '{0}' was not found
        NotDesiredPropertyState        = AD Group '{0}' is not correct. Expected '{1}', actual '{2}'
        UpdatingGroupProperty          = Updating AD Group property '{0}' to '{1}'
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $GroupName,

        [ValidateSet('DomainLocal','Global','Universal')]
        [System.String]
        $GroupScope = 'Global',

        [ValidateSet('Security','Distribution')]
        [System.String]
        $Category = 'Security',

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [System.String[]]
        $Members,

        [System.String[]]
        $MembersToInclude,

        [System.String[]]
        $MembersToExclude,

        [ValidateSet('SamAccountName','DistinguishedName','SID','ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        ## This must be the user's DN
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Notes
    )
    Assert-Module -ModuleName 'ActiveDirectory';
    $adGroupParams = Get-ADCommonParameters @PSBoundParameters;
    try {
        $adGroup = Get-ADGroup @adGroupParams -Property Name,GroupScope,GroupCategory,DistinguishedName,Description,DisplayName,ManagedBy,Info;
        Write-Verbose -Message ($LocalizedData.RetrievingGroupMembers -f $MembershipAttribute);
        ## Retrieve the current list of members, returning the specified membership attribute
        $adGroupMembers = (Get-ADGroupMember @adGroupParams).$MembershipAttribute;
        $targetResource = @{
            GroupName = $adGroup.Name;
            GroupScope = $adGroup.GroupScope;
            Category = $adGroup.GroupCategory;
            Path = Get-ADObjectParentDN -DN $adGroup.DistinguishedName;
            Description = $adGroup.Description;
            DisplayName = $adGroup.DisplayName;
            Members = $adGroupMembers;
            MembersToInclude = $MembersToInclude;
            MembersToExclude = $MembersToExclude;
            MembershipAttribute = $MembershipAttribute;
            ManagedBy = $adGroup.ManagedBy;
            Notes = $adGroup.Info;
            Ensure = 'Absent';
        }
        if ($adGroup)
        {
            $targetResource['Ensure'] = 'Present';
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Verbose ($LocalizedData.GroupNotFound -f $GroupName);
        $targetResource = @{
            GroupName = $GroupName;
            GroupScope = $GroupScope;
            Category = $Category;
            Path = $Path;
            Description = $Description;
            DisplayName = $DisplayName;
            Members = @();
            MembersToInclude = $MembersToInclude;
            MembersToExclude = $MembersToExclude;
            MembershipAttribute = $MembershipAttribute;
            ManagedBy = $ManagedBy;
            Notes = $Notes;
            Ensure = 'Absent';
        }
    }
    return $targetResource;
} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $GroupName,

        [ValidateSet('DomainLocal','Global','Universal')]
        [System.String]
        $GroupScope = 'Global',

        [ValidateSet('Security','Distribution')]
        [System.String]
        $Category = 'Security',

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [System.String[]]
        $Members,

        [System.String[]]
        $MembersToInclude,

        [System.String[]]
        $MembersToExclude,

        [ValidateSet('SamAccountName','DistinguishedName','SID','ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        ## This must be the user's DN
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Notes
    )
    ## Validate parameters before we even attempt to retrieve anything
    $assertMemberParameters = @{};
    if ($PSBoundParameters.ContainsKey('Members') -and -not [system.string]::IsNullOrEmpty($Members))
    {
        $assertMemberParameters['Members'] = $Members;
    }
    if ($PSBoundParameters.ContainsKey('MembersToInclude') -and -not [system.string]::IsNullOrEmpty($MembersToInclude))
    {
        $assertMemberParameters['MembersToInclude'] = $MembersToInclude;
    }
    if ($PSBoundParameters.ContainsKey('MembersToExclude') -and -not [system.string]::IsNullOrEmpty($MembersToExclude))
    {
        $assertMemberParameters['MembersToExclude'] = $MembersToExclude;
    }
    Assert-MemberParameters @assertMemberParameters -ModuleName 'xADDomain' -ErrorAction Stop;

    $targetResource = Get-TargetResource @PSBoundParameters;
    $targetResourceInCompliance = $true;
    if ($targetResource.GroupScope -ne $GroupScope)
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'GroupScope', $GroupScope, $targetResource.GroupScope);
        $targetResourceInCompliance = $false;
    }
    if ($targetResource.Category -ne $Category)
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Category', $Category, $targetResource.Category);
        $targetResourceInCompliance = $false;
    }
    if ($Path -and ($targetResource.Path -ne $Path))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Path', $Path, $targetResource.Path);
        $targetResourceInCompliance = $false;
    }
    if ($Description -and ($targetResource.Description -ne $Description))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Description', $Description, $targetResource.Description);
        $targetResourceInCompliance = $false;
    }
    if ($DisplayName -and ($targetResource.DisplayName -ne $DisplayName))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'DisplayName', $DisplayName, $targetResource.DisplayName);
        $targetResourceInCompliance = $false;
    }
    if ($ManagedBy -and ($targetResource.ManagedBy -ne $ManagedBy))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'ManagedBy', $ManagedBy, $targetResource.ManagedBy);
        $targetResourceInCompliance = $false;
    }
    if ($Notes -and ($targetResource.Notes -ne $Notes))
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Notes', $Notes, $targetResource.Notes);
        $targetResourceInCompliance = $false;
    }
    ## Test group members match passed membership parameters
    if (-not (Test-Members @assertMemberParameters -ExistingMembers $targetResource.Members))
    {
        Write-Verbose -Message $LocalizedData.GroupMembershipNotDesiredState;
        $targetResourceInCompliance = $false;
    }
    if ($targetResource.Ensure -ne $Ensure)
    {
        Write-Verbose ($LocalizedData.NotDesiredPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure);
        $targetResourceInCompliance = $false;
    }
    return $targetResourceInCompliance;
} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $GroupName,

        [ValidateSet('DomainLocal','Global','Universal')]
        [System.String]
        $GroupScope = 'Global',

        [ValidateSet('Security','Distribution')]
        [System.String]
        $Category = 'Security',

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DisplayName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [System.String[]]
        $Members,

        [System.String[]]
        $MembersToInclude,

        [System.String[]]
        $MembersToExclude,

        [ValidateSet('SamAccountName','DistinguishedName','SID','ObjectGUID')]
        [System.String]
        $MembershipAttribute = 'SamAccountName',

        ## This must be the user's DN
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ManagedBy,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Notes

    )
    Assert-Module -ModuleName 'ActiveDirectory';
    $adGroupParams = Get-ADCommonParameters @PSBoundParameters;

    try {
        $adGroup = Get-ADGroup @adGroupParams -Property Name,GroupScope,GroupCategory,DistinguishedName,Description,DisplayName,ManagedBy,Info;

        if ($Ensure -eq 'Present') {

            $setADGroupParams = $adGroupParams.Clone();
            $setADGroupParams['Identity'] = $adGroup.DistinguishedName;

            # Update existing group properties
            if ($Category -ne $adGroup.GroupCategory)
            {
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'Category', $Category);
                $setADGroupParams['GroupCategory'] = $Category;
            }
            if ($GroupScope -ne $adGroup.GroupScope)
            {
                ## Cannot change DomainLocal to Global or vice versa directly. Need to change them to a Universal group first!
                Set-ADGroup -Identity $adGroup.DistinguishedName -GroupScope Universal;
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'GroupScope', $GroupScope);
                $setADGroupParams['GroupScope'] = $GroupScope;
            }
            if ($Description -and ($Description -ne $adGroup.Description))
            {
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'Description', $Description);
                $setADGroupParams['Description'] = $Description;
            }
            if ($DisplayName -and ($DisplayName -ne $adGroup.DisplayName))
            {
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'DisplayName', $DisplayName);
                $setADGroupParams['DisplayName'] = $DisplayName;
            }
            if ($ManagedBy -and ($ManagedBy -ne $adGroup.ManagedBy))
            {
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'ManagedBy', $ManagedBy);
                $setADGroupParams['ManagedBy'] = $ManagedBy;
            }
            if ($Notes -and ($Notes -ne $adGroup.Info))
            {
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'Notes', $Notes);
                $setADGroupParams['Replace'] = @{ Info = $Notes };
            }
            Write-Verbose ($LocalizedData.UpdatingGroup -f $GroupName);
            Set-ADGroup @setADGroupParams;

            # Move group if the path is not correct
            if ($Path -and ($Path -ne (Get-ADObjectParentDN -DN $adGroup.DistinguishedName))) {
                Write-Verbose ($LocalizedData.MovingGroup -f $GroupName, $Path);
                $moveADObjectParams = $adGroupParams.Clone();
                $moveADObjectParams['Identity'] = $adGroup.DistinguishedName
                Move-ADObject @moveADObjectParams -TargetPath $Path;
            }

            Write-Verbose -Message ($LocalizedData.RetrievingGroupMembers -f $MembershipAttribute);
            $adGroupMembers = (Get-ADGroupMember @adGroupParams).$MembershipAttribute;
            if (-not (Test-Members -ExistingMembers $adGroupMembers -Members $Members -MembersToInclude $MembersToInclude -MembersToExclude $MembersToExclude))
            {
                ## The fact that we're in the Set method, there is no need to validate the parameter
                ## combination as this was performed in the Test method
                if ($PSBoundParameters.ContainsKey('Members') -and -not [system.string]::IsNullOrEmpty($Members))
                {
                    # Remove all existing first and add explicit members
                    $Members = Remove-DuplicateMembers -Members $Members;
                    # We can only remove members if there are members already in the group!
                    if ($adGroupMembers.Count -gt 0)
                    {
                        Write-Verbose -Message ($LocalizedData.RemovingGroupMembers -f $adGroupMembers.Count, $GroupName);
                        Remove-ADGroupMember @adGroupParams -Members $adGroupMembers -Confirm:$false;
                    }
                    Write-Verbose -Message ($LocalizedData.AddingGroupMembers -f $Members.Count, $GroupName);
                    Add-ADGroupMember @adGroupParams -Members $Members;
                }
                if ($PSBoundParameters.ContainsKey('MembersToInclude') -and -not [system.string]::IsNullOrEmpty($MembersToInclude))
                {
                    $MembersToInclude = Remove-DuplicateMembers -Members $MembersToInclude;
                    Write-Verbose -Message ($LocalizedData.AddingGroupMembers -f $MembersToInclude.Count, $GroupName);
                    Add-ADGroupMember @adGroupParams -Members $MembersToInclude;
                }
                if ($PSBoundParameters.ContainsKey('MembersToExclude') -and -not [system.string]::IsNullOrEmpty($MembersToExclude))
                {
                    $MembersToExclude = Remove-DuplicateMembers -Members $MembersToExclude;
                    Write-Verbose -Message ($LocalizedData.RemovingGroupMembers -f $MembersToExclude.Count, $GroupName);
                    Remove-ADGroupMember @adGroupParams -Members $MembersToExclude -Confirm:$false;
                }
            }
        }
        elseif ($Ensure -eq 'Absent')
        {
            # Remove existing group
            Write-Verbose ($LocalizedData.RemovingGroup -f $GroupName);
            Remove-ADGroup @adGroupParams -Confirm:$false;
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        ## The AD group doesn't exist
        if ($Ensure -eq 'Present')
        {

            Write-Verbose ($LocalizedData.GroupNotFound -f $GroupName);
            Write-Verbose ($LocalizedData.AddingGroup -f $GroupName);

            $adGroupParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter;
            if ($Description)
            {
                $adGroupParams['Description'] = $Description;
            }
            if ($DisplayName)
            {
                $adGroupParams['DisplayName'] = $DisplayName;
            }
            if ($ManagedBy)
            {
                $adGroupParams['ManagedBy'] = $ManagedBy;
            }
            if ($Path)
            {
                $adGroupParams['Path'] = $Path;
            }
            ## Create group
            $adGroup = New-ADGroup @adGroupParams -GroupCategory $Category -GroupScope $GroupScope -PassThru;

            ## Only the New-ADGroup cmdlet takes a -Name parameter. Refresh
            ## the parameters with the -Identity parameter rather than -Name
            $adGroupParams = Get-ADCommonParameters @PSBoundParameters

            if ($Notes) {
                ## Can't set the Notes field when creating the group
                Write-Verbose ($LocalizedData.UpdatingGroupProperty -f 'Notes', $Notes);
                $setADGroupParams = $adGroupParams.Clone();
                $setADGroupParams['Identity'] = $adGroup.DistinguishedName;
                Set-ADGroup @setADGroupParams -Add @{ Info = $Notes };
            }

            ## Add the required members
            if ($PSBoundParameters.ContainsKey('Members') -and -not [system.string]::IsNullOrEmpty($Members))
            {
                $Members = Remove-DuplicateMembers -Members $Members;
                Write-Verbose -Message ($LocalizedData.AddingGroupMembers -f $Members.Count, $GroupName);
                Add-ADGroupMember @adGroupParams -Members $Members;
            }
            elseif ($PSBoundParameters.ContainsKey('MembersToInclude') -and -not [system.string]::IsNullOrEmpty($MembersToInclude))
            {
                $MembersToInclude = Remove-DuplicateMembers -Members $MembersToInclude;
                Write-Verbose -Message ($LocalizedData.AddingGroupMembers -f $MembersToInclude.Count, $GroupName);
                Add-ADGroupMember @adGroupParams -Members $MembersToInclude;
            }

        }
    } #end catch
} #end function Set-TargetResource

## Import the common AD functions
$adCommonFunctions = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1';
. $adCommonFunctions;

Export-ModuleMember -Function *-TargetResource;
