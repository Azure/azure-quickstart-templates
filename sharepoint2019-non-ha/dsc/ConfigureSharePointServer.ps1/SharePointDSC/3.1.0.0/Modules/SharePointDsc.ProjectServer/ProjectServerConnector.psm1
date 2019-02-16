function Get-SPDscProjectServerGlobalPermissionId
{
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $PermissionName
    )

    $result = $null
    [Microsoft.Office.Project.Server.Library.PSSecurityGlobalPermission] `
      | Get-Member -Static -MemberType Property | ForEach-Object -Process {
        if ($PermissionName -eq $_.Name)
        {
            $result = [Microsoft.Office.Project.Server.Library.PSSecurityGlobalPermission]::($_.Name)
        }
    }

    if ($null -eq $result)
    {
        $errorString = ""
        [Microsoft.Office.Project.Server.Library.PSSecurityGlobalPermission] `
          | Get-Member -Static -MemberType Property | ForEach-Object -Process {
                if ($errorString -eq "")
                {
                    $errorString += "$($_.Name)"
                }
                else
                {
                    $errorString += ", $($_.Name)"
                }
        }
        throw "Unable to find permission '$PermissionName' - acceptable values are: $errorString"
    }

    return $result
}

function Get-SPDscProjectServerPermissionName
{
    param(
        [Parameter(Mandatory=$true)]
        [System.Guid]
        $PermissionId
    )

    $result = $null
    [Microsoft.Office.Project.Server.Library.PSSecurityGlobalPermission] `
      | Get-Member -Static -MemberType Property | ForEach-Object -Process {
        if ($PermissionId -eq [Microsoft.Office.Project.Server.Library.PSSecurityGlobalPermission]::($_.Name))
        {
            $result = $_.Name
        }
    }

    if ($null -eq $result)
    {
        throw "Unable to find permission with ID '$PermissionId'"
    }
    return $result
}

function Get-SPDscProjectServerResourceId
{
    [OutputType([System.Guid])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PwaUrl
    )

    $webAppUrl = (Get-SPSite -Identity $PwaUrl).WebApplication.Url
    $useKerberos = -not (Get-SPAuthenticationProvider -WebApplication $webAppUrl -Zone Default).DisableKerberos
    $resourceService = New-SPDscProjectServerWebService -PwaUrl $PwaUrl `
                                                        -EndpointName Resource `
                                                        -UseKerberos:$useKerberos

    $script:SPDscReturnVal = $null
    Use-SPDscProjectServerWebService -Service $resourceService -ScriptBlock {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Project.Server.Library") | Out-Null
        $ds = [SvcResource.ResourceDataSet]::new()

        $filter = New-Object -TypeName "Microsoft.Office.Project.Server.Library.Filter"
        $filter.FilterTableName = $ds.Resources.TableName

        $idColumn = New-Object -TypeName "Microsoft.Office.Project.Server.Library.Filter+Field" `
                               -ArgumentList @(
                                 $ds.Resources.TableName,
                                 $ds.Resources.RES_UIDColumn.ColumnName,
                                 [Microsoft.Office.Project.Server.Library.Filter+SortOrderTypeEnum]::None
                               )
        $filter.Fields.Add($idColumn)

        $nameColumn = New-Object -TypeName "Microsoft.Office.Project.Server.Library.Filter+Field" `
                                 -ArgumentList @(
                                   $ds.Resources.TableName,
                                   $ds.Resources.WRES_AccountColumn.ColumnName,
                                   [Microsoft.Office.Project.Server.Library.Filter+SortOrderTypeEnum]::None
                                 )
        $filter.Fields.Add($nameColumn)

        $nameFieldFilter = New-Object -TypeName "Microsoft.Office.Project.Server.Library.Filter+FieldOperator" `
                                      -ArgumentList @(
                                        [Microsoft.Office.Project.Server.Library.Filter+FieldOperationType]::Contain,
                                        $ds.Resources.WRES_AccountColumn.ColumnName,
                                        $ResourceName
                                      )
        $filter.Criteria = $nameFieldFilter

        $filterXml = $filter.GetXml()

        $resourceDs = $resourceService.ReadResources($filterXml, $false)
        if ($resourceDs.Resources.Count -ge 1)
        {
            $resourceDs.Resources.Rows | ForEach-Object -Process {
                if ($_.WRES_Account -eq $ResourceName -or ($_.WRES_Account.Contains("0#") -and $_.WRES_Account.Contains($ResourceName)))
                {
                    $script:SPDscReturnVal = $_.RES_UID
                }
            }
            if ($null -eq $script:SPDscReturnVal)
            {
                throw "Resource '$ResourceName' not found"
            }
        }
        else
        {
            throw "Resource '$ResourceName' not found"
        }
    }
    return $script:SPDscReturnVal
}

function Get-SPDscProjectServerResourceName
{
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Guid]
        $ResourceId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PwaUrl
    )

    $webAppUrl = (Get-SPSite -Identity $PwaUrl).WebApplication.Url
    $useKerberos = -not (Get-SPAuthenticationProvider -WebApplication $webAppUrl -Zone Default).DisableKerberos
    $resourceService = New-SPDscProjectServerWebService -PwaUrl $PwaUrl `
                                                        -EndpointName Resource `
                                                        -UseKerberos:$useKerberos

    $script:SPDscReturnVal = ""
    Use-SPDscProjectServerWebService -Service $resourceService -ScriptBlock {
        $script:SPDscReturnVal = $resourceService.ReadResource($ResourceId).Resources.WRES_ACCOUNT
    }
    return $script:SPDscReturnVal
}

function New-SPDscProjectServerWebService
{
    [OutputType([System.IDisposable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $PwaUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet("Admin", "Archive", "Calendar", "CubeAdmin", "CustomFields",
                     "Driver", "Events", "LookupTable", "Notifications", "ObjectLinkProvider",
                     "PortfolioAnalyses", "Project", "QueueSystem", "ResourcePlan", "Resource",
                     "Security", "Statusing", "TimeSheet", "Workflow", "WssInterop")]
        $EndpointName,

        [Parameter()]
        [Switch]
        $UseKerberos
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.ServiceModel") | Out-Null
    $psDllPath = Join-Path -Path $PSScriptRoot -ChildPath "ProjectServerServices.dll"

    $filehash = "44CC60C2227011D08F36A7954C317195C0A44F3D52D51B0F54009AA03EF97E1B2F80A162D76F177E70D1756E42484DF367FACB25920C2C93FB8DFB8A8F5F08A5"
    if ($filehash -ne (Get-FileHash -Path $psDllPath -Algorithm SHA512).Hash)
    {
        throw ("The hash for ProjectServerServices.dll isn't the expected value. Please make " + `
               "sure the correct file exists on the file system.")
    }
    $bytes = [System.IO.File]::ReadAllBytes($psDllPath)
    [System.Reflection.Assembly]::Load($bytes) | Out-Null

    $maxSize = 500000000
    $svcRouter = "_vti_bin/PSI/ProjectServer.svc"
    $pwaUri = New-Object -TypeName "System.Uri" -ArgumentList $pwaUrl

    if ($pwaUri.Scheme -eq [System.Uri]::UriSchemeHttps)
    {
        $binding = New-Object -TypeName "System.ServiceModel.BasicHttpBinding" `
                              -ArgumentList ([System.ServiceModel.BasicHttpSecurityMode]::Transport)
    }
    else
    {
        $binding = New-Object -TypeName "System.ServiceModel.BasicHttpBinding" `
                              -ArgumentList ([System.ServiceModel.BasicHttpSecurityMode]::TransportCredentialOnly)
    }
    $binding.Name = "basicHttpConf"
    $binding.SendTimeout = [System.TimeSpan]::MaxValue
    $binding.MaxReceivedMessageSize = $maxSize
    $binding.ReaderQuotas.MaxNameTableCharCount = $maxSize
    $binding.MessageEncoding = [System.ServiceModel.WSMessageEncoding]::Text

    if ($UseKerberos.IsPresent -eq $false)
    {
        $binding.Security.Transport.ClientCredentialType = [System.ServiceModel.HttpClientCredentialType]::Ntlm
    }
    else
    {
        $binding.Security.Transport.ClientCredentialType = [System.ServiceModel.HttpClientCredentialType]::Windows
    }

    if ($pwaUrl.EndsWith('/') -eq $false)
    {
        $pwaUrl = $pwaUrl + "/"
    }
    $address = New-Object -TypeName "System.ServiceModel.EndpointAddress" `
                          -ArgumentList ($pwaUrl + $svcRouter)

    $webService = New-Object -TypeName "Svc$($EndpointName).$($EndpointName)Client" `
                             -ArgumentList @($binding, $address)

    $webService.ChannelFactory.Credentials.Windows.AllowedImpersonationLevel = [System.Security.Principal.TokenImpersonationLevel]::Impersonation

    return $webService
}

function Use-SPDscProjectServerWebService
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.IDisposable]
        $Service,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]
        $ScriptBlock
    )

    try
    {
        Invoke-Command -ScriptBlock $ScriptBlock
    }
    finally
    {
        if ($null -ne $Service)
        {
            $Service.Dispose()
        }
    }
}

Export-ModuleMember -Function *
