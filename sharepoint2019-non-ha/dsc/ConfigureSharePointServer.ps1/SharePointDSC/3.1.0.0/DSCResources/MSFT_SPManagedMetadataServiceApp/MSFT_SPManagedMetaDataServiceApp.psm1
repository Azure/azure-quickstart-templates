function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String[]]
        $TermStoreAdministrators,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $ContentTypeHubUrl,

        [Parameter()]
        [System.UInt32]
        $DefaultLanguage,

        [Parameter()]
        [System.UInt32[]]
        $Languages,

        [Parameter()]
        [System.Boolean]
        $ContentTypePushdownEnabled,

        [Parameter()]
        [System.Boolean]
        $ContentTypeSyndicationEnabled,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting managed metadata service application $Name"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name                    = $params.Name
            Ensure                  = "Absent"
            ApplicationPool         = $params.ApplicationPool
            TermStoreAdministrators = @()
        }

        if ($null -eq $serviceApps)
        {
            return $nullReturn
        }

        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplication"
        }

        if ($null -eq $serviceApp)
        {
            return $nullReturn
        }
        else
        {
            $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue

            $proxyName = $params.ProxyName

            if ($null -ne $serviceAppProxies)
            {
                $serviceAppProxy = $serviceAppProxies | Where-Object -FilterScript {
                    $serviceApp.IsConnected($_)
                }
                if ($null -ne $serviceAppProxy)
                {
                    $proxyName = $serviceAppProxy.Name
                }
            }

            $proxy = Get-SPMetadataServiceApplicationProxy -Identity $proxyName `
                                                           -ErrorAction SilentlyContinue
            if ($null -ne $proxy)
            {
                $contentTypePushDownEnabled = $proxy.Properties["IsContentTypePushdownEnabled"]
                $contentTypeSyndicationEnabled = $proxy.Properties["IsNPContentTypeSyndicationEnabled"]
            }
            else
            {
                Write-Verbose "No SPMetadataServiceApplicationProxy with the name '$($proxyName)' was found. Please verify your Managed Metadata Service Application."
            }

            # Get the ContentTypeHubUrl value
            $hubUrl = ""
            try
            {
                $propertyFlags = [System.Reflection.BindingFlags]::Instance `
                    -bor [System.Reflection.BindingFlags]::NonPublic
                $defaultPartitionId = [Guid]::Parse("0C37852B-34D0-418e-91C6-2AC25AF4BE5B")

                $installedVersion = Get-SPDSCInstalledProductVersion
                switch ($installedVersion.FileMajorPart)
                {
                    15
                    {
                        $propData = $serviceApp.GetType().GetMethods($propertyFlags)
                        $method = $propData | Where-Object -FilterScript {
                            $_.Name -eq "GetContentTypeSyndicationHubLocal"
                        }
                        $hubUrl = $method.Invoke($serviceApp, $defaultPartitionId).AbsoluteUri
                    }
                    16
                    {
                        $propData = $serviceApp.GetType().GetProperties($propertyFlags)
                        $dbMapperProp = $propData | Where-Object -FilterScript {
                            $_.Name -eq "DatabaseMapper"
                        }

                        $dbMapper = $dbMapperProp.GetValue($serviceApp)

                        $propData2 = $dbMapper.GetType().GetMethods($propertyFlags)
                        $cthubMethod = $propData2 | Where-Object -FilterScript {
                            $_.Name -eq "GetContentTypeSyndicationHubLocal"
                        }

                        $hubUrl = $cthubMethod.Invoke($dbMapper, $defaultPartitionId).AbsoluteUri
                    }
                    default
                    {
                        throw ("Detected an unsupported major version of SharePoint. " + `
                                "SharePointDsc only supports SharePoint 2013, 2016 or 2019.")
                    }
                }

                if ($hubUrl)
                {
                    $hubUrl = $hubUrl.TrimEnd('/')
                }
                else
                {
                    $hubUrl = ""
                }
            }
            catch [System.Exception]
            {
                $hubUrl = ""
            }

            $centralAdminSite = Get-SPWebApplication -IncludeCentralAdministration `
                | Where-Object -FilterScript {
                $_.IsAdministrationWebApplication -eq $true
            }
            $session = Get-SPTaxonomySession -Site $centralAdminSite.Url

            $currentAdmins = @()
            $termStoreDefaultLanguage = $null
            $termStoreLanguages = @()

            if ($null -ne $session)
            {
                if ($null -ne $proxyName)
                {
                    $termStore = $session.TermStores[$proxyName]

                    if ($null -ne $termstore)
                    {
                        $termStore.TermStoreAdministrators | ForEach-Object -Process {
                            $name = [string]::Empty
                            if ($_.IsWindowsAuthenticationMode -eq $true)
                            {
                                $name = $_.PrincipalName
                            }
                            else
                            {
                                $name = (New-SPClaimsPrincipal -Identity $_.PrincipalName -IdentityType EncodedClaim).Value
                                if ($name -match "^s-1-[0-59]-\d+-\d+-\d+-\d+-\d+")
                                {
                                    $name = Resolve-SPDscSecurityIdentifier -SID $name
                                }
                            }
                            $currentAdmins += $name
                        }
                        $termStoreDefaultLanguage = $termStore.DefaultLanguage
                        $termStoreLanguages = $termStore.Languages
                    }
                    else
                    {
                        Write-Verbose "No termstore matching to the proxy name '$proxyName' was found"
                    }
                }
                else
                {
                    Write-Verbose "No valid proxy for $($params.Name) was found"
                }
            }
            else
            {
                Write-Verbose "Could not get taxonomy session. Please check if the managed metadata service is started."
            }

            return @{
                Name                          = $serviceApp.DisplayName
                ProxyName                     = $proxyName
                Ensure                        = "Present"
                ApplicationPool               = $serviceApp.ApplicationPool.Name
                DatabaseName                  = $serviceApp.Database.Name
                DatabaseServer                = $serviceApp.Database.NormalizedDataSource
                TermStoreAdministrators       = $currentAdmins
                ContentTypeHubUrl             = $hubUrl
                DefaultLanguage               = $termStoreDefaultLanguage
                Languages                     = $termStoreLanguages
                ContentTypePushdownEnabled    = $contentTypePushDownEnabled
                ContentTypeSyndicationEnabled = $contentTypeSyndicationEnabled
                InstallAccount                = $params.InstallAccount
            }
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
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String[]]
        $TermStoreAdministrators,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $ContentTypeHubUrl,

        [Parameter()]
        [System.UInt32]
        $DefaultLanguage,

        [Parameter()]
        [System.UInt32[]]
        $Languages,

        [Parameter()]
        [System.Boolean]
        $ContentTypePushdownEnabled,

        [Parameter()]
        [System.Boolean]
        $ContentTypeSyndicationEnabled,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting managed metadata service application $Name"

    $result = Get-TargetResource @PSBoundParameters

    $pName = "$Name Proxy"
    if ($null -ne $result.ProxyName)
    {
        $pName = $result.ProxyName
    }

    if ($PSBoundParameters.ContainsKey("ProxyName"))
    {
        $pName = $ProxyName
    }

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        Write-Verbose -Message "Creating Managed Metadata Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments ($PSBoundParameters, $pName) `
                            -ScriptBlock {
            $params = $args[0]
            $pName = $args[1]

            $newParams = @{
                Name            = $params.Name
                ApplicationPool = $params.ApplicationPool
                DatabaseServer  = $params.DatabaseServer
                DatabaseName    = $params.DatabaseName
            }

            if ($params.ContainsKey("ContentTypeHubUrl") -eq $true)
            {
                $newParams.Add("HubUri", $params.ContentTypeHubUrl)
            }

            $app = New-SPMetadataServiceApplication @newParams
            if ($null -ne $app)
            {
                New-SPMetadataServiceApplicationProxy -Name $pName `
                                                      -ServiceApplication $app `
                                                      -DefaultProxyGroup `
                                                      -ContentTypePushdownEnabled
            }
        }
        $result = Get-TargetResource @PSBoundParameters
    }

    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present")
    {
        if ([string]::IsNullOrEmpty($ApplicationPool) -eq $false -and `
            $ApplicationPool -ne $result.ApplicationPool)
        {
            Write-Verbose -Message "Updating application pool of Managed Metadata Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]

                $serviceApp = Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                    $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplication"
                }
                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool
                Set-SPMetadataServiceApplication -Identity $serviceApp -ApplicationPool $appPool
            }
        }

        if ($pName -ne $result.ProxyName)
        {
            Write-Verbose -Message "Updating Managed Metadata Service Application Proxy"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments @($PSBoundParameters, $pName) `
                                -ScriptBlock {
                $params = $args[0]
                $pName = $args[1]

                $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                        -ErrorAction SilentlyContinue
                $serviceApp = $serviceApps | Where-Object -FilterScript {
                    $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplication"
                }

                $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue
                if ($null -ne $serviceAppProxies)
                {
                    $serviceAppProxy = $serviceAppProxies | Where-Object -FilterScript {
                        $serviceApp.IsConnected($_)
                    }

                    if ($null -ne $serviceAppProxy)
                    {
                        Write-Verbose -Message "Updating Proxy Name from '$($result.ProxyName)' to '$pName'"
                        $serviceAppProxy.Name = $pName
                        $serviceAppProxy.Update()
                    }
                    else
                    {
                        Write-Verbose -Message "Creating Service Application Proxy '$pName'"
                        New-SPMetadataServiceApplicationProxy -Name $pName `
                                                              -ServiceApplication $serviceApp `
                                                              -DefaultProxyGroup `
                                                              -ContentTypePushdownEnabled
                    }
                }
            }
        }

        if (($PSBoundParameters.ContainsKey("ContentTypeHubUrl") -eq $true) `
                -and ($ContentTypeHubUrl.TrimEnd('/') -ne $result.ContentTypeHubUrl.TrimEnd('/')))
        {
            Write-Verbose -Message "Updating Content type hub for Managed Metadata Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                -Arguments $PSBoundParameters `
                -ScriptBlock {
                $params = $args[0]

                $serviceApp = Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                    $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplication"
                }
                Set-SPMetadataServiceApplication -Identity $serviceApp -HubUri $params.ContentTypeHubUrl
            }
        }

        if (($PSBoundParameters.ContainsKey("TermStoreAdministrators") -eq $true) `
                -and ($null -ne (Compare-Object -ReferenceObject $result.TermStoreAdministrators `
                        -DifferenceObject $TermStoreAdministrators)))
        {
            Write-Verbose -Message "Updating the term store administrators"
            # Update the term store administrators
            Invoke-SPDSCCommand -Credential $InstallAccount `
                -Arguments @($PSBoundParameters, $result, $pName) `
                -ScriptBlock {

                $params = $args[0]
                $currentValues = $args[1]
                $pName = $args[2]

                $centralAdminSite = Get-SPWebApplication -IncludeCentralAdministration `
                    | Where-Object -FilterScript {
                    $_.IsAdministrationWebApplication -eq $true
                }
                $session = Get-SPTaxonomySession -Site $centralAdminSite.Url
                $termStore = $session.TermStores[$pName]

                if ($null -eq $termStore)
                {
                    throw "The name of the Managed Metadata Service Application Proxy '$pName' did not return any termstore."
                }

                $changesToMake = Compare-Object -ReferenceObject $currentValues.TermStoreAdministrators `
                    -DifferenceObject $params.TermStoreAdministrators

                $changesToMake | ForEach-Object -Process {
                    $change = $_
                    switch ($change.SideIndicator)
                    {
                        "<="
                        {
                            # remove an existing user
                            if ($termStore.TermStoreAdministrators.PrincipalName -contains $change.InputObject)
                            {
                                $termStore.DeleteTermStoreAdministrator($change.InputObject)
                            }
                            else
                            {
                                $claimsToken = New-SPClaimsPrincipal -Identity $change.InputObject `
                                    -IdentityType WindowsSamAccountName
                                $termStore.DeleteTermStoreAdministrator($claimsToken.ToEncodedString())
                            }
                        }
                        "=>"
                        {
                            # add a new user
                            $termStore.AddTermStoreAdministrator($change.InputObject)
                        }
                        default
                        {
                            throw "An unknown side indicator was found."
                        }
                    }
                }

                $termStore.CommitAll();
            }
        }

        if (($PSBoundParameters.ContainsKey("DefaultLanguage") -eq $true) `
                -and ($DefaultLanguage -ne $result.DefaultLanguage))
        {
            # The lanauge settings should be set to default
            Write-Verbose -Message "Updating the default language for Managed Metadata Service Application Proxy '$pName'"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                -Arguments @($PSBoundParameters, $pName) `
                -ScriptBlock {

                $params = $args[0]
                $pName = $args[1]

                $centralAdminSite = Get-SPWebApplication -IncludeCentralAdministration `
                    | Where-Object -FilterScript {
                    $_.IsAdministrationWebApplication -eq $true
                }
                $session = Get-SPTaxonomySession -Site $centralAdminSite.Url
                $termStore = $session.TermStores[$pName]

                if ($null -eq $termStore)
                {
                    throw "The name of the Managed Metadata Service Application Proxy '$pName' did not return any termstore."
                }

                $permissionResult = $termStore.TermStoreAdministrators.DoesUserHavePermissions([Microsoft.SharePoint.Taxonomy.TaxonomyRights]::ManageTermStore)

                if (-not($permissionResult))
                {
                    $termStore.AddTermStoreAdministrator([Security.Principal.WindowsIdentity]::GetCurrent().Name)
                    $termStore.CommitAll()
                }

                $termStore.DefaultLanguage = $params.DefaultLanguage
                $termStore.CommitAll()

                if (-not ($permissionResult))
                {
                    $termStore.DeleteTermStoreAdministrator([Security.Principal.WindowsIdentity]::GetCurrent().Name)
                    $termStore.CommitAll()
                }
            }
        }

        if (($PSBoundParameters.ContainsKey("Languages") -eq $true) `
                -and ($null -ne (Compare-Object -ReferenceObject $result.Languages `
                        -DifferenceObject $Languages)))
        {
            Write-Verbose -Message "Updating working languages for Managed Metadata Service Application Proxy '$pName'"
            # Update the term store working languages
            Invoke-SPDSCCommand -Credential $InstallAccount `
                -Arguments @($PSBoundParameters, $result, $pName) `
                -ScriptBlock {

                $params = $args[0]
                $currentValues = $args[1]
                $pName = $args[2]

                $centralAdminSite = Get-SPWebApplication -IncludeCentralAdministration `
                    | Where-Object -FilterScript {
                    $_.IsAdministrationWebApplication -eq $true
                }
                $session = Get-SPTaxonomySession -Site $centralAdminSite.Url
                $termStore = $session.TermStores[$pName]

                if ($null -eq $termStore)
                {
                    throw "The name of the Managed Metadata Service Application Proxy '$pName' did not return any termstore."
                }

                $permissionResult = $termStore.TermStoreAdministrators.DoesUserHavePermissions([Microsoft.SharePoint.Taxonomy.TaxonomyRights]::ManageTermStore)

                if (-not($permissionResult))
                {
                    $termStore.AddTermStoreAdministrator([Security.Principal.WindowsIdentity]::GetCurrent().Name)
                    $termStore.CommitAll()
                }

                $changesToMake = Compare-Object -ReferenceObject $currentValues.Languages `
                    -DifferenceObject $params.Languages

                $changesToMake | ForEach-Object -Process {
                    $change = $_
                    switch ($change.SideIndicator)
                    {
                        "<="
                        {
                            # delete a working language
                            $termStore.DeleteLanguage($change.InputObject)
                        }
                        "=>"
                        {
                            # add a working language
                            $termStore.AddLanguage($change.InputObject)
                        }
                        default
                        {
                            throw "An unknown side indicator was found."
                        }
                    }
                }

                $termStore.CommitAll();

                if (-not ($permissionResult))
                {
                    $termStore.DeleteTermStoreAdministrator([Security.Principal.WindowsIdentity]::GetCurrent().Name)
                    $termStore.CommitAll()
                }
            }
        }

        if (($PSBoundParameters.ContainsKey("ContentTypePushdownEnabled") -eq $true) `
                -and ($ContentTypePushdownEnabled -ne $result.ContentTypePushdownEnabled)
        )
        {
            Invoke-SPDSCCommand -Credential $InstallAccount `
                -Arguments @($PSBoundParameters, $pName) `
                -ScriptBlock {
                $params = $args[0]
                $pName = $args[1]

                $proxy = Get-SPMetadataServiceApplicationProxy -Identity $pName
                if ($null -ne $proxy)
                {
                    $proxy.Properties["IsContentTypePushdownEnabled"] = $params.ContentTypePushdownEnabled
                    $proxy.Update()
                }
                else
                {
                    throw [Exception] "No SPMetadataServiceApplicationProxy with the name '$($proxyName)' was found. Please verify your Managed Metadata Service Application."
                }
            }
        }

        if (($PSBoundParameters.ContainsKey("ContentTypeSyndicationEnabled") -eq $true) `
                -and ($ContentTypeSyndicationEnabled -ne $result.ContentTypeSyndicationEnabled)
        )
        {
            Invoke-SPDSCCommand -Credential $InstallAccount `
                -Arguments @($PSBoundParameters, $pName) `
                -ScriptBlock {
                $params = $args[0]
                $pName = $args[1]

                $proxy = Get-SPMetadataServiceApplicationProxy -Identity $pName
                if ($null -ne $proxy)
                {
                    $proxy.Properties["IsNPContentTypeSyndicationEnabled"] = $params.ContentTypeSyndicationEnabled
                    $proxy.Update()
                }
                else
                {
                    throw [Exception] "No SPMetadataServiceApplicationProxy with the name '$($proxyName)' was found. Please verify your Managed Metadata Service Application."
                }
            }
        }
    }

    if ($Ensure -eq "Absent")
    {
        # The service app should not exit
        Write-Verbose -Message "Removing Managed Metadata Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
            -Arguments $PSBoundParameters `
            -ScriptBlock {
            $params = $args[0]

            $serviceApp = Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplication"
            }

            $proxies = Get-SPServiceApplicationProxy
            foreach ($proxyInstance in $proxies)
            {
                if ($serviceApp.IsConnected($proxyInstance))
                {
                    $proxyInstance.Delete()
                }
            }

            Remove-SPServiceApplication -Identity $serviceApp -Confirm:$false
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
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String[]]
        $TermStoreAdministrators,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $ContentTypeHubUrl,

        [Parameter()]
        [System.UInt32]
        $DefaultLanguage,

        [Parameter()]
        [System.UInt32[]]
        $Languages,

        [Parameter()]
        [System.Boolean]
        $ContentTypePushdownEnabled,

        [Parameter()]
        [System.Boolean]
        $ContentTypeSyndicationEnabled,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing managed metadata service application $Name"

    $PSBoundParameters.Ensure = $Ensure
    if ($PSBoundParameters.ContainsKey("ContentTypeHubUrl") -eq $true)
    {
        $PSBoundParameters.ContentTypeHubUrl = $ContentTypeHubUrl.TrimEnd('/')
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $valuesToCheck = @("ApplicationPool",
                       "ContentTypeHubUrl"
                       "ContentTypePushdownEnabled"
                       "ContentTypeSyndicationEnabled"
                       "DefaultLanguage"
                       "Ensure",
                       "Languages"
                       "TermStoreAdministrators"
                       "ProxyName")

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck $valuesToCheck
}

Export-ModuleMember -Function *-TargetResource
