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
        [System.Management.Automation.PSCredential] 
        $InstallAccount,
        
        [Parameter()]
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present"
    )

    Write-Verbose -Message "Getting service instance '$Name'"

    $newName = (Get-SPDscServiceTypeName -DisplayName $Name)

    $invokeArgs = @{
        Credential = $InstallAccount
        Arguments = @($PSBoundParameters, $newName)
    }
    $result = Invoke-SPDSCCommand @invokeArgs -ScriptBlock {
        $params = $args[0]
        $newName = $args[1]
        
        $si = Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object -FilterScript {
            $_.TypeName -eq $params.Name -or `
            $_.TypeName -eq $newName -or `
            $_.GetType().Name -eq $newName
        }
        
        if ($null -eq $si) 
        {
            $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
            $fqdn = "$($env:COMPUTERNAME).$domain"
            $si = Get-SPServiceInstance -Server $fqdn | Where-Object -FilterScript {
                $_.TypeName -eq $params.Name -or `
                $_.TypeName -eq $newName -or `
                $_.GetType().Name -eq $newName
            }
        }
        
        if ($null -eq $si) 
        {
            return @{
                Name = $params.Name
                Ensure = "Absent"
                InstallAccount = $params.InstallAccount
            } 
        }
        if ($si.Status -eq "Online") 
        {
            $localEnsure = "Present" 
        } 
        else 
        {
            $localEnsure = "Absent" 
        }
        
        return @{
            Name = $params.Name
            Ensure = $localEnsure
            InstallAccount = $params.InstallAccount
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
        [System.Management.Automation.PSCredential] 
        $InstallAccount,
        
        [Parameter()]
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting service instance '$Name'"

    $newName = (Get-SPDscServiceTypeName -DisplayName $Name)
    $invokeArgs = @{
        Credential = $InstallAccount
        Arguments = @($PSBoundParameters, $newName)
    }

    if ($Ensure -eq "Present") 
    {
        Write-Verbose -Message "Provisioning service instance '$Name'"

        Invoke-SPDSCCommand @invokeArgs -ScriptBlock {
            $params = $args[0]
            $newName = $args[1]
            
            $si = Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object -FilterScript {
                $_.TypeName -eq $params.Name -or `
                $_.TypeName -eq $newName -or `
                $_.GetType().Name -eq $newName
            }
            
            if ($null -eq $si) 
            {
                $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
                $fqdn = "$($env:COMPUTERNAME).$domain"
                $si = Get-SPServiceInstance -Server $fqdn | Where-Object -FilterScript {
                    $_.TypeName -eq $params.Name -or `
                    $_.TypeName -eq $newName -or `
                    $_.GetType().Name -eq $newName
                }
            }
            if ($null -eq $si)
            {
                throw [Exception] "Unable to locate service application '$($params.Name)'"
            }
            Start-SPServiceInstance -Identity $si 
        }
    } 
    else 
    {
        Write-Verbose -Message "Deprovisioning service instance '$Name'"

        Invoke-SPDSCCommand @invokeArgs -ScriptBlock {
            $params = $args[0]
            $newName = $args[1]
            
            $si = Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object -FilterScript {
                $_.TypeName -eq $params.Name -or `
                $_.TypeName -eq $newName -or `
                $_.GetType().Name -eq $newName
            }
            
            if ($null -eq $si) 
            {
                $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
                $fqdn = "$($env:COMPUTERNAME).$domain"
                $si = Get-SPServiceInstance -Server $fqdn | Where-Object -FilterScript {
                    $_.TypeName -eq $params.Name -or `
                    $_.TypeName -eq $newName -or `
                    $_.GetType().Name -eq $newName
                }
            }
            if ($null -eq $si)
            {
                throw [Exception] "Unable to locate service application '$($params.Name)'"
            }
            Stop-SPServiceInstance -Identity $si
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
        [System.Management.Automation.PSCredential] 
        $InstallAccount,
        
        [Parameter()]
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing service instance '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    $testArgs = @{
        CurrentValues = (Get-TargetResource @PSBoundParameters)
        DesiredValues = $PSBoundParameters
        ValuesToCheck = @("Name", "Ensure")
    }
    return Test-SPDscParameterState @testArgs
}

function Get-SPDscServiceTypeName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $DisplayName
    )
    switch ($DisplayName)
    {
        "Access Database Service 2010" {
            return "AccessServerWebServiceInstance"
        }
        "Access Services" {
            return "AccessServicesWebServiceInstance"
        }
        "App Management Service" {
            return "AppManagementServiceInstance"
        }
        "Business Data Connectivity Service" {
            return "BdcServiceInstance"
        }
        "PerformancePoint Service" {
            return "BIMonitoringServiceInstance"
        }
        "Excel Calculation Services" {
            return "ExcelServerWebServiceInstance"
        }
        "Document Conversions Launcher Service" {
            return "LauncherServiceInstance"
        }
        "Document Conversions Load Balancer Service" {
            return "LoadBalancerServiceInstance"
        }
        "Managed Metadata Web Service" {
            return "MetadataWebServiceInstance"
        }
        "Lotus Notes Connector" {
            return "NotesWebServiceInstance"
        }
        "PowerPoint Conversion Service" {
            return "PowerPointConversionServiceInstance"
        }
        "User Profile Synchronization Service" {
            return "ProfileSynchronizationServiceInstance"
        }
        "Search Query and Site Settings Service" {
            return "SearchQueryAndSiteSettingsServiceInstance"
        }
        "Search Host Controller Service" {
            return "SearchRuntimeServiceInstance"
        }
        "SharePoint Server Search" {
            return "SearchServiceInstance"
        }
        "Secure Store Service" {
            return "SecureStoreServiceInstance"
        }
        "Microsoft SharePoint Foundation Incoming E-Mail" {
            return "SPIncomingEmailServiceInstance"
        }
        "Request Management" {
            return "SPRequestManagementServiceInstance"
        }
        "Microsoft SharePoint Foundation Subscription Settings Service" {
            return "SPSubscriptionSettingsServiceInstance"
        }
        "Microsoft SharePoint Foundation Sandboxed Code Service" {
            return "SPUserCodeServiceInstance"
        }
        "Claims to Windows Token Service" {
            return "SPWindowsTokenServiceInstance"
        }
        "Microsoft SharePoint Foundation Workflow Timer Service" {
            return "SPWorkflowTimerServiceInstance"
        }
        "Machine Translation Service" {
            return "TranslationServiceInstance"
        }
        "User Profile Service" {
            return "UserProfileServiceInstance"
        }
        "Visio Graphics Service" {
            return "VisioGraphicsServiceInstance"
        }
        "Word Automation Services" {
            return "WordServiceInstance"
        }
        "Work Management Service" {
            return "WorkManagementServiceInstance"
        }
        Default {
            return $DisplayName
        }
    }
}

Export-ModuleMember -Function *-TargetResource
