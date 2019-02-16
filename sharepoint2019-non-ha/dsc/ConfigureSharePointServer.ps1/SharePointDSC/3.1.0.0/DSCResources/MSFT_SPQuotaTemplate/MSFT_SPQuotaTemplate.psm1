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
        [System.UInt32]  
        $StorageMaxInMB,

        [Parameter()] 
        [System.UInt32]  
        $StorageWarningInMB,

        [Parameter()] 
        [System.UInt32]  
        $MaximumUsagePointsSolutions,

        [Parameter()] 
        [System.UInt32] 
        $WarningUsagePointsSolutions,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
    
    Write-Verbose -Message "Getting Quota Template settings for quota $Name"

    if ($StorageMaxInMB -lt $StorageWarningInMB) 
    {
        Throw "StorageMaxInMB must be equal to or larger than StorageWarningInMB."
    }

    if ($MaximumUsagePointsSolutions -lt $WarningUsagePointsSolutions) 
    {
        Throw ("MaximumUsagePointsSolutions must be equal to or larger than " + `
               "WarningUsagePointsSolutions.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        try 
        {
            $spFarm = Get-SPFarm
        } 
        catch 
        {
            Write-Verbose -Message ("No local SharePoint farm was detected. Quota " + `
                                    "template settings will not be applied")
            return @{
                Name = $params.Name
                StorageMaxInMB = 0
                StorageWarningInMB = 0 
                MaximumUsagePointsSolutions = 0
                WarningUsagePointsSolutions = 0
                Ensure = "Absent"
                InstallAccount = $params.InstallAccount
            }
        }

        # Get a reference to the Administration WebService
        $admService = Get-SPDSCContentService

        $template = $admService.QuotaTemplates[$params.Name]
        if ($null -eq $template) 
        {
            return @{
                Name = $params.Name
                Ensure = "Absent"
                InstallAccount = $params.InstallAccount
            }
        } 
        else 
        {
            return @{
                Name = $params.Name
                # Convert from bytes to megabytes
                StorageMaxInMB = ($template.StorageMaximumLevel / 1MB) 
                # Convert from bytes to megabytes
                StorageWarningInMB = ($template.StorageWarningLevel / 1MB) 
                MaximumUsagePointsSolutions = $template.UserCodeMaximumLevel
                WarningUsagePointsSolutions = $template.UserCodeWarningLevel
                Ensure = "Present"
                InstallAccount = $params.InstallAccount
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
        [System.UInt32]  
        $StorageMaxInMB,

        [Parameter()] 
        [System.UInt32]  
        $StorageWarningInMB,

        [Parameter()] 
        [System.UInt32]  
        $MaximumUsagePointsSolutions,

        [Parameter()] 
        [System.UInt32] 
        $WarningUsagePointsSolutions,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting Quota Template settings for quota $Name"

    if ($StorageMaxInMB -lt $StorageWarningInMB) 
    {
        Throw "StorageMaxInMB must be equal to or larger than StorageWarningInMB."
    }

    if ($MaximumUsagePointsSolutions -lt $WarningUsagePointsSolutions) 
    {
        Throw ("MaximumUsagePointsSolutions must be equal to or larger than " + `
               "WarningUsagePointsSolutions.")
    }

    switch ($Ensure) 
    {
        "Present" {
            Write-Verbose "Ensure is set to Present - Add or update template"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]
        
                try 
                {
                    $spFarm = Get-SPFarm
                } 
                catch 
                {
                    throw ("No local SharePoint farm was detected. Quota " + `
                           "template settings will not be applied")
                    return
                }

                Write-Verbose -Message "Start update"
                # Get a reference to the Administration WebService
                $admService = Get-SPDSCContentService

                $template = $admService.QuotaTemplates[$params.Name]

                if ($null -eq $template) 
                {
                    #Template does not exist, create new template
                    $newTemplate = New-Object Microsoft.SharePoint.Administration.SPQuotaTemplate
                    $newTemplate.Name = $params.Name
                    if ($params.ContainsKey("StorageMaxInMB")) 
                    {
                        $newTemplate.StorageMaximumLevel = ($params.StorageMaxInMB * 1MB) 
                    }
                    if ($params.ContainsKey("StorageWarningInMB")) 
                    {
                        $newTemplate.StorageWarningLevel = ($params.StorageWarningInMB * 1MB) 
                    } 
                    if ($params.ContainsKey("MaximumUsagePointsSolutions")) 
                    {
                        $newTemplate.UserCodeMaximumLevel = $params.MaximumUsagePointsSolutions 
                    } 
                    if ($params.ContainsKey("WarningUsagePointsSolutions")) 
                    {
                        $newTemplate.UserCodeWarningLevel = $params.WarningUsagePointsSolutions 
                    } 
                    $admService.QuotaTemplates.Add($newTemplate)
                    $admService.Update()
                } 
                else 
                {
                    #Template exists, update settings
                    if ($params.ContainsKey("StorageMaxInMB")) 
                    {
                        $template.StorageMaximumLevel = ($params.StorageMaxInMB * 1MB) 
                    } 
                    if ($params.ContainsKey("StorageWarningInMB")) 
                    {
                        $template.StorageWarningLevel = ($params.StorageWarningInMB * 1MB) 
                    } 
                    if ($params.ContainsKey("MaximumUsagePointsSolutions")) 
                    {
                        $template.UserCodeMaximumLevel = $params.MaximumUsagePointsSolutions 
                    } 
                    if ($params.ContainsKey("WarningUsagePointsSolutions")) 
                    {
                        $template.UserCodeWarningLevel = $params.WarningUsagePointsSolutions 
                    }
                    $admService.Update()
                }
            }
        }
        "Absent" {
            Write-Verbose "Ensure is set to Absent - Removing template"

            if ($StorageMaxInMB `
                -or $StorageWarningInMB `
                -or $MaximumUsagePointsSolutions `
                -or $WarningUsagePointsSolutions) 
            {
                Throw ("Do not use StorageMaxInMB, StorageWarningInMB, " + `
                       "MaximumUsagePointsSolutions or WarningUsagePointsSolutions " + `
                       "when Ensure is specified as Absent")
            }

            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]
        
                try 
                {
                    $spFarm = Get-SPFarm
                } 
                catch 
                {
                    Write-Verbose -Message ("No local SharePoint farm was detected. Quota " + `
                                            "template settings will not be applied")
                    return
                }

                Write-Verbose -Message "Start update"
                # Get a reference to the Administration WebService
                $admService = Get-SPDSCContentService

                # Delete template, function does not throw an error when the template does not 
                # exist. So safe to call without error handling.
                $admService.QuotaTemplates.Delete($params.Name)
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
        [System.String]  
        $Name,

        [Parameter()] 
        [System.UInt32]  
        $StorageMaxInMB,

        [Parameter()] 
        [System.UInt32]  
        $StorageWarningInMB,

        [Parameter()] 
        [System.UInt32]  
        $MaximumUsagePointsSolutions,

        [Parameter()] 
        [System.UInt32] 
        $WarningUsagePointsSolutions,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing Quota Template settings for quota $Name"

    if ($StorageMaxInMB -lt $StorageWarningInMB) 
    {
        Throw "StorageMaxInMB must be equal to or larger than StorageWarningInMB."
    }

    if ($MaximumUsagePointsSolutions -lt $WarningUsagePointsSolutions) 
    {
        Throw ("MaximumUsagePointsSolutions must be equal to or larger than " + `
               "WarningUsagePointsSolutions.")
    }

    switch ($Ensure) 
    {
        "Present" {
            $CurrentValues = Get-TargetResource @PSBoundParameters
            if ($CurrentValues.Ensure -eq "Absent")
            {
                return $false 
            }
            return Test-SPDscParameterState -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters
        }
        "Absent" {
            if ($StorageMaxInMB `
                -or $StorageWarningInMB `
                -or $MaximumUsagePointsSolutions `
                -or $WarningUsagePointsSolutions) 
            {
                Throw ("Do not use StorageMaxInMB, StorageWarningInMB, " + `
                       "MaximumUsagePointsSolutions or WarningUsagePointsSolutions " + `
                       "when Ensure is specified as Absent")
            }

            $CurrentValues = Get-TargetResource @PSBoundParameters
            if ($CurrentValues.Ensure -eq "Present") 
            {
                # Error occured in Get method or template exists, which is not supposed to be. Return false
                return $false
            } 
            else 
            {
                # Template does not exists, which is supposed to be. Return true
                return $true
            } 
        }
    }
}

Export-ModuleMember -Function *-TargetResource
