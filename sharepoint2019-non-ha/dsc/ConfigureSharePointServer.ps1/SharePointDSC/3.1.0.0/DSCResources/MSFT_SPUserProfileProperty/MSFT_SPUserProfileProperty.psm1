function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.string]
        $Name,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter(Mandatory = $true)]
        [System.string]
        $UserProfileService,

        [Parameter()]
        [System.string]
        $DisplayName,

        [Parameter()]
        [ValidateSet("Big Integer",
            "Binary",
            "Boolean",
            "Date",
            "DateNoYear",
            "Date Time",
            "Email",
            "Float",
            "HTML",
            "Integer",
            "Person",
            "String (Single Value)",
            "String (Multi Value)",
            "TimeZone",
            "Unique Identifier",
            "URL")]
        [System.string]
        $Type,

        [Parameter()]
        [System.string]
        $Description,

        [Parameter()]
        [ValidateSet("Mandatory", "Optin", "Optout", "Disabled")]
        [System.string]
        $PolicySetting,

        [Parameter()]
        [ValidateSet("Public", "Contacts", "Organization", "Manager", "Private")]
        [System.string]
        $PrivacySetting,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PropertyMappings,

        [Parameter()]
        [System.uint32]
        $Length,

        [Parameter()]
        [System.uint32]
        $DisplayOrder,

        [Parameter()]
        [System.Boolean]
        $IsEventLog,

        [Parameter()]
        [System.Boolean]
        $IsVisibleOnEditor,

        [Parameter()]
        [System.Boolean]
        $IsVisibleOnViewer,

        [Parameter()]
        [System.Boolean]
        $IsUserEditable,

        [Parameter()]
        [System.Boolean]
        $IsAlias,

        [Parameter()]
        [System.Boolean]
        $IsSearchable,

        [Parameter()]
        [System.Boolean]
        $UserOverridePrivacy,

        [Parameter()]
        [System.string]
        $TermStore,

        [Parameter()]
        [System.string]
        $TermGroup,

        [Parameter()]
        [System.string]
        $TermSet,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting user profile property $Name"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
        -Arguments $PSBoundParameters `
        -ScriptBlock {
        $params = $args[0]

        $upsa = Get-SPServiceApplication -Name $params.UserProfileService `
            -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name               = $params.Name
            UserProfileService = $params.UserProfileService
            Ensure             = "Absent"
        }
        if ($null -eq $upsa)
        {
            return $nullReturn
        }

        $caURL = (Get-SPWebApplication -IncludeCentralAdministration | Where-Object -FilterScript {
                $_.IsAdministrationWebApplication -eq $true
            }).Url

        $context = Get-SPServiceContext -Site $caURL

        $userProfileSubTypeManager = Get-SPDSCUserProfileSubTypeManager -Context $context
        $userProfileSubType = $userProfileSubTypeManager.GetProfileSubtype("UserProfile")

        $userProfileProperty = $userProfileSubType.Properties.GetPropertyByName($params.Name)
        if ($null -eq $userProfileProperty)
        {
            return $nullReturn
        }

        $termSet = @{
            TermSet   = ""
            TermGroup = ""
            TermStore = ""
        }

        if ($null -ne $userProfileProperty.CoreProperty.TermSet)
        {
            $termSet.TermSet = $userProfileProperty.CoreProperty.TermSet.Name
            $termSet.TermGroup = $userProfileProperty.CoreProperty.TermSet.Group.Name
            $termSet.TermStore = $userProfileProperty.CoreProperty.TermSet.TermStore.Name
        }

        $userProfilePropertyMappings = @()

        $userProfileConfigManager = New-Object -TypeName "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" `
            -ArgumentList $context

        if ($null -eq $userProfileConfigManager.ConnectionManager)
        {
            return $nullReturn
        }

        foreach ($propertyMapping in $params.PropertyMappings)
        {
            try
            {
                $connection = $userProfileConfigManager.ConnectionManager[$propertyMapping.ConnectionName]

                # This only works with SharePoint 2013 and AD Sync Connections.
                $syncConnection = $connection | Where-Object -FilterScript {
                    $null -ne $_.PropertyMapping -and $null -ne $_.PropertyMapping.Item($params.Name)
                }

                if ($null -ne $syncConnection)
                {
                    # This code will only be reached with SP 2013 and AD Sync Connections.
                    $currentMapping = $syncConnection.PropertyMapping.Item($params.Name)
                    if ($null -ne $currentMapping)
                    {
                        $mapping = @{}
                        $mapping.Direction = "Import"
                        $mapping.ConnectionName = $params.MappingConnectionName
                        if ($currentMapping.IsExport)
                        {
                            $mapping.Direction = "Export"
                        }
                        $mapping.PropertyName = $currentMapping.DataSourcePropertyName

                        $userProfilePropertyMappings += (New-CimInstance -ClassName MSFT_SPUserProfilePropertyMapping -ClientOnly -Property @{
                                ConnectionName = $propertyMapping.ConnectionName
                                PropertyName   = $mapping.ConnectionName
                                Direction      = $mapping.Direction
                            })
                    }
                }
                else
                {
                    # This code is for SP 2013, 2016 and 2019 with AD Import Connections.
                    if ($connection.Type -eq "ActiveDirectoryImport")
                    {
                        try
                        {
                            $adImportConnection = [Microsoft.Office.Server.UserProfiles.ActiveDirectoryImportConnection]$connection
                        }
                        catch [Exception]
                        {
                            $adImportConnection = $connection
                        }

                        $propertyFlags = [System.Reflection.BindingFlags]::Instance -bor `
                            [System.Reflection.BindingFlags]::NonPublic

                        $propMembers = $adImportConnection.GetType().GetMethods($propertyFlags)

                        $adImportPropertyMappingsMethod = $propMembers | Where-Object -FilterScript {
                            $_.Name -eq "ADImportPropertyMappings"
                        }
                        $propertyMappings = $adImportPropertyMappingsMethod.Invoke($adImportConnection, $null)

                        $propertyMappings | ForEach-Object -Process {
                            $currentMappingMembers = $_.GetType().GetMembers($propertyFlags)
                            $profileProperty = $currentMappingMembers | Where-Object -FilterScript {
                                $_.Name -eq "ProfileProperty"
                            }
                            if ($null -ne $profileProperty)
                            {
                                $profilePropertyValue = $profileProperty.GetValue($_)
                                if ($profilePropertyValue -eq $params.Name)
                                {
                                    $adAttributeProperty = $currentMappingMembers | Where-Object -FilterScript {
                                        $_.Name -eq "ADAttribute"
                                    }
                                    if ($null -ne $adAttributeProperty)
                                    {
                                        $userProfilePropertyMappings += (New-CimInstance -ClassName MSFT_SPUserProfilePropertyMapping -ClientOnly -Property @{
                                                ConnectionName = $propertyMapping.ConnectionName
                                                PropertyName   = $adAttributeProperty.GetValue($_)
                                                Direction      = "Import"
                                            })
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch [Exception]
            {
                Write-Verbose "An unecpexted error occured. Please report an issue! $_"
            }
        }

        return @{
            Name                = $userProfileProperty.Name
            UserProfileService  = $params.UserProfileService
            DisplayName         = $userProfileProperty.DisplayName
            Type                = $userProfileProperty.CoreProperty.Type
            Description         = $userProfileProperty.Description
            PolicySetting       = $userProfileProperty.PrivacyPolicy
            PrivacySetting      = $userProfileProperty.DefaultPrivacy
            PropertyMappings    = $userProfilePropertyMappings
            Length              = $userProfileProperty.CoreProperty.Length
            DisplayOrder        = $userProfileProperty.DisplayOrder
            IsEventLog          = $userProfileProperty.TypeProperty.IsEventLog
            IsVisibleOnEditor   = $userProfileProperty.TypeProperty.IsVisibleOnEditor
            IsVisibleOnViewer   = $userProfileProperty.TypeProperty.IsVisibleOnViewer
            IsUserEditable      = $userProfileProperty.IsUserEditable
            IsAlias             = $userProfileProperty.IsAlias
            IsSearchable        = $userProfileProperty.CoreProperty.IsSearchable
            TermStore           = $termSet.TermStore
            TermGroup           = $termSet.TermGroup
            TermSet             = $termSet.TermSet
            UserOverridePrivacy = $userProfileProperty.UserOverridePrivacy
            Ensure              = "Present"
        }

    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.string]
        $Name,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter(Mandatory = $true)]
        [System.string]
        $UserProfileService,

        [Parameter()]
        [System.string]
        $DisplayName,

        [Parameter()]
        [ValidateSet("Big Integer",
            "Binary",
            "Boolean",
            "Date",
            "DateNoYear",
            "Date Time",
            "Email",
            "Float",
            "HTML",
            "Integer",
            "Person",
            "String (Single Value)",
            "String (Multi Value)",
            "TimeZone",
            "Unique Identifier",
            "URL")]
        [System.string]
        $Type,

        [Parameter()]
        [System.string]
        $Description,

        [Parameter()]
        [ValidateSet("Mandatory", "Optin", "Optout", "Disabled")]
        [System.string]
        $PolicySetting,

        [Parameter()]
        [ValidateSet("Public", "Contacts", "Organization", "Manager", "Private")]
        [System.string]
        $PrivacySetting,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PropertyMappings,

        [Parameter()]
        [System.uint32]
        $Length,

        [Parameter()]
        [System.uint32]
        $DisplayOrder,

        [Parameter()]
        [System.Boolean]
        $IsEventLog,

        [Parameter()]
        [System.Boolean]
        $IsVisibleOnEditor,

        [Parameter()]
        [System.Boolean]
        $IsVisibleOnViewer,

        [Parameter()]
        [System.Boolean]
        $IsUserEditable,

        [Parameter()]
        [System.Boolean]
        $IsAlias,

        [Parameter()]
        [System.Boolean]
        $IsSearchable,

        [Parameter()]
        [System.Boolean]
        $UserOverridePrivacy,

        [Parameter()]
        [System.string]
        $TermStore,

        [Parameter()]
        [System.string]
        $TermGroup,

        [Parameter()]
        [System.string]
        $TermSet,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    # Note for integration test: CA can take a couple of minutes to notice the change. don't try
    # refreshing properties page. Go through from a fresh "flow" from Service apps page

    Write-Verbose -Message "Setting user profile property $Name"

    $PSBoundParameters.Ensure = $Ensure

    Invoke-SPDSCCommand -Credential $InstallAccount `
        -Arguments $PSBoundParameters `
        -ScriptBlock {

        $params = $args[0]

        if ( ($params.ContainsKey("TermSet")  `
                    -or $params.ContainsKey("TermGroup") `
                    -or $params.ContainsKey("TermSet") ) `
                -and ($params.ContainsKey("TermSet") `
                    -and $params.ContainsKey("TermGroup") `
                    -and $params.ContainsKey("TermSet") -eq $false)
        )
        {
            throw ("You have to provide all 3 parameters Termset, TermGroup and TermStore " + `
                    "when providing any of the 3.")
        }

        if ($params.ContainsKey("TermSet") `
                -and (@("string (single value)", "string (multi value)").Contains($params.Type.ToLower()) -eq $false))
        {
            throw "Only String and String Multivalue can use Termsets"
        }

        $ups = Get-SPServiceApplication -Name $params.UserProfileService `
            -ErrorAction SilentlyContinue

        if ($null -eq $ups)
        {
            return $null
        }

        $caURL = (Get-SPWebApplication -IncludeCentralAdministration | Where-Object -FilterScript {
                $_.IsAdministrationWebApplication -eq $true
            }).Url
        $context = Get-SPServiceContext $caURL

        $userProfileConfigManager = New-Object -TypeName "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" `
            -ArgumentList $context

        if ($null -eq $userProfileConfigManager)
        {
            #if config manager returns when ups is available then isuee is permissions
            throw ("Account running process needs admin permissions on the user profile " + `
                    "service application")
        }
        $coreProperties = $userProfileConfigManager.ProfilePropertyManager.GetCoreProperties()

        $userProfileSubTypeManager = Get-SPDSCUserProfileSubTypeManager $context
        $userProfileSubType = $userProfileSubTypeManager.GetProfileSubtype("UserProfile")

        $userProfileProperty = $userProfileSubType.Properties.GetPropertyByName($params.Name)

        if ($null -ne $userProfileProperty `
                -and $userProfileProperty.CoreProperty.Type -ne $params.Type)
        {
            throw ("Can't change property type. Current Type is " + `
                    "$($userProfileProperty.CoreProperty.Type)")
        }

        $termSet = $null

        if ($params.ContainsKey("TermSet"))
        {
            $currentTermSet = $userProfileProperty.CoreProperty.TermSet;
            if ($currentTermSet.Name -ne $params.TermSet -or
                $currentTermSet.Group.Name -ne $params.TermGroup -or
                $currentTermSet.TermStore.Name -ne $params.TermStore)
            {
                $session = New-Object -TypeName Microsoft.SharePoint.Taxonomy.TaxonomySession `
                    -ArgumentList $caURL

                $termStore = $session.TermStores[$params.TermStore]

                if ($null -eq $termStore)
                {
                    throw "Term Store $($params.termStore) not found"
                }

                $group = $termStore.Groups[$params.TermGroup]

                if ($null -eq $group)
                {
                    throw "Term Group $($params.termGroup) not found"
                }

                $termSet = $group.TermSets[$params.TermSet]
                if ($null -eq $termSet)
                {
                    throw "Term Set $($params.termSet) not found"
                }
            }
        }

        if ($params.ContainsKey("Ensure") -and $params.Ensure -eq "Absent")
        {
            if ($null -ne $userProfileProperty)
            {
                $coreProperties.RemovePropertyByName($params.Name)
                return
            }
        }
        elseif ($null -eq $userProfileProperty)
        {
            $coreProperty = $coreProperties.Create($false)
            $coreProperty.Name = $params.Name
            $coreProperty.DisplayName = $params.DisplayName

            Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $coreProperty `
                -PropertyToSet "Length" `
                -ParamsValue $params `
                -ParamKey "Length"

            if ($params.Type -eq "String (Multi Value)")
            {
                $coreProperty.IsMultivalued = $true
            }

            $coreProperty.Type = $params.Type
            if ($null -ne $termSet)
            {
                $coreProperty.TermSet = $termSet
            }

            $userProfilePropertyManager = $userProfileConfigManager.ProfilePropertyManager
            $userProfileTypeProperties = $userProfilePropertyManager.GetProfileTypeProperties([Microsoft.Office.Server.UserProfiles.ProfileType]::User)
            $userProfileSubTypeProperties = $userProfileSubType.Properties

            $CoreProperties.Add($coreProperty)
            $upTypeProperty = $userProfileTypeProperties.Create($coreProperty)
            $userProfileTypeProperties.Add($upTypeProperty)
            $upSubProperty = $userProfileSubTypeProperties.Create($UPTypeProperty)
            $userProfileSubTypeProperties.Add($upSubProperty)
            Start-Sleep -Milliseconds 100
            $userProfileProperty = $userProfileSubType.Properties.GetPropertyByName($params.Name)

        }

        $coreProperty = $userProfileProperty.CoreProperty
        $userProfileTypeProperty = $userProfileProperty.TypeProperty
        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $coreProperty `
            -PropertyToSet "DisplayName" `
            -ParamsValue $params `
            -ParamKey "DisplayName"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $coreProperty `
            -PropertyToSet "Description" `
            -ParamsValue $params `
            -ParamKey "Description"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileTypeProperty `
            -PropertyToSet "IsVisibleOnViewer" `
            -ParamsValue $params `
            -ParamKey "IsVisibleOnViewer"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileTypeProperty `
            -PropertyToSet "IsVisibleOnEditor" `
            -ParamsValue $params `
            -ParamKey "IsVisibleOnEditor"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileTypeProperty `
            -PropertyToSet "IsEventLog" `
            -ParamsValue $params `
            -ParamKey "IsEventLog"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $coreProperty `
            -PropertyToSet "IsSearchable" `
            -ParamsValue $params `
            -ParamKey "IsSearchable"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileProperty `
            -PropertyToSet "DefaultPrivacy" `
            -ParamsValue $params `
            -ParamKey "PrivacySetting"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileProperty `
            -PropertyToSet "PrivacyPolicy" `
            -ParamsValue $params `
            -ParamKey "PolicySetting"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileProperty `
            -PropertyToSet "IsUserEditable" `
            -ParamsValue $params `
            -ParamKey "IsUserEditable"

        Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileProperty `
            -PropertyToSet "UserOverridePrivacy" `
            -ParamsValue $params `
            -ParamKey "UserOverridePrivacy"
        if ($termSet)
        {
            $coreProperty.TermSet = $termSet
        }

        $userProfileProperty.CoreProperty.Commit()
        $userProfileTypeProperty.Commit()
        $userProfileProperty.Commit()

        if ($params.ContainsKey("DisplayOrder"))
        {
            $profileManager = New-Object -TypeName "Microsoft.Office.Server.UserProfiles.UserProfileManager" `
                -ArgumentList $context
            $profileManager.Properties.SetDisplayOrderByPropertyName($params.Name, $params.DisplayOrder)
            $profileManager.Properties.CommitDisplayOrder()
        }

        if ($params.ContainsKey("PropertyMappings"))
        {
            foreach ($propertyMapping in $PropertyMappings)
            {
                $syncConnection = $userProfileConfigManager.ConnectionManager[$propertyMapping.ConnectionName]

                if ($null -eq $syncConnection)
                {
                    throw "connection not found"
                }

                if ($null -ne $syncConnection.PropertyMapping)
                {
                    $currentMapping = $syncConnection.PropertyMapping.Item($params.Name)
                }

                if ($null -eq $currentMapping `
                        -or ($currentMapping.DataSourcePropertyName -ne $params.MappingPropertyName) `
                        -or ($currentMapping.IsImport `
                            -and $propertyMapping.Direction -eq "Export")
                )
                {
                    if ($null -ne $currentMapping)
                    {
                        $currentMapping.Delete() #API allows updating, but UI doesn't do that.
                    }

                    $export = $propertyMapping.Direction -eq "Export"
                    if ($syncConnection.Type -eq "ActiveDirectoryImport")
                    {
                        if ($export)
                        {
                            throw "not implemented"
                        }
                        else
                        {
                            $syncConnection.AddPropertyMapping($propertyMapping.PropertyName, $params.Name)
                            $syncConnection.Update()
                        }
                    }
                    else
                    {
                        if ($export)
                        {
                            $syncConnection.PropertyMapping.AddNewExportMapping([Microsoft.Office.Server.UserProfiles.ProfileType]::User,
                                $params.Name,
                                $propertyMapping.PropertyName)
                        }
                        else
                        {
                            $syncConnection.PropertyMapping.AddNewMapping([Microsoft.Office.Server.UserProfiles.ProfileType]::User,
                                $params.Name,
                                $propertyMapping.PropertyName)
                        }
                    }
                }
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.string]
        $Name,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter(Mandatory = $true)]
        [System.string]
        $UserProfileService,

        [Parameter()]
        [System.string]
        $DisplayName,

        [Parameter()]
        [ValidateSet("Big Integer",
            "Binary",
            "Boolean",
            "Date",
            "DateNoYear",
            "Date Time",
            "Email",
            "Float",
            "HTML",
            "Integer",
            "Person",
            "String (Single Value)",
            "String (Multi Value)",
            "TimeZone",
            "Unique Identifier",
            "URL")]
        [System.string]
        $Type,

        [Parameter()]
        [System.string]
        $Description,

        [Parameter()]
        [ValidateSet("Mandatory", "Optin", "Optout", "Disabled")]
        [System.string]
        $PolicySetting,

        [Parameter()]
        [ValidateSet("Public", "Contacts", "Organization", "Manager", "Private")]
        [System.string]
        $PrivacySetting,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PropertyMappings,

        [Parameter()]
        [System.uint32]
        $Length,

        [Parameter()]
        [System.uint32]
        $DisplayOrder,

        [Parameter()]
        [System.Boolean]
        $IsEventLog,

        [Parameter()]
        [System.Boolean]
        $IsVisibleOnEditor,

        [Parameter()]
        [System.Boolean]
        $IsVisibleOnViewer,

        [Parameter()]
        [System.Boolean]
        $IsUserEditable,

        [Parameter()]
        [System.Boolean]
        $IsAlias,

        [Parameter()]
        [System.Boolean]
        $IsSearchable,

        [Parameter()]
        [System.Boolean]
        $UserOverridePrivacy,

        [Parameter()]
        [System.string]
        $TermStore,

        [Parameter()]
        [System.string]
        $TermGroup,

        [Parameter()]
        [System.string]
        $TermSet,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount

    )

    Write-Verbose -Message "Testing for user profile property $Name"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present")
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck @("Name",
            "DisplayName",
            "Type",
            "Description",
            "PolicySetting",
            "PrivacySetting",
            "PropertyMappings",
            "Length",
            "DisplayOrder",
            "IsEventLog",
            "IsVisibleOnEditor",
            "IsVisibleOnViewer",
            "IsUserEditable",
            "IsAlias",
            "IsSearchabe",
            "UserOverridePrivacy",
            "TermGroup",
            "TermStore",
            "TermSet",
            "Ensure")
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
