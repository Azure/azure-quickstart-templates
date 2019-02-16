function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Default,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Intranet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Internet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Extranet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Custom,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application authentication for '$WebAppUrl'"

    $nullreturn = @{
        WebAppUrl = $params.Name
        Default   = $null
        Intranet  = $null
        Internet  = $null
        Extranet  = $null
        Custom    = $null
    }

    if ($PSBoundParameters.ContainsKey("Default") -eq $false -and `
        $PSBoundParameters.ContainsKey("Intranet") -eq $false -and `
        $PSBoundParameters.ContainsKey("Internet") -eq $false -and `
        $PSBoundParameters.ContainsKey("Extranet") -eq $false -and `
        $PSBoundParameters.ContainsKey("Custom") -eq $false)
    {
        Write-Verbose -Message "You have to specify at least one zone."
        return $nullreturn
    }

    if ($PSBoundParameters.ContainsKey("Default"))
    {
        $result = Test-Parameter -Zone $Default
        if ($result -eq $false)
        {
            return $nullreturn
        }
    }

    if ($PSBoundParameters.ContainsKey("Intranet"))
    {
        $result = Test-Parameter -Zone $Intranet
        if ($result -eq $false)
        {
            return $nullreturn
        }
    }

    if ($PSBoundParameters.ContainsKey("Internet"))
    {
        $result = Test-Parameter -Zone $Internet
        if ($result -eq $false)
        {
            return $nullreturn
        }
    }

    if ($PSBoundParameters.ContainsKey("Extranet"))
    {
        $result = Test-Parameter -Zone $Extranet
        if ($result -eq $false)
        {
            return $nullreturn
        }
    }

    if ($PSBoundParameters.ContainsKey("Custom"))
    {
        $result = Test-Parameter -Zone $Custom
        if ($result -eq $false)
        {
            return $nullreturn
        }
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return @{
                WebAppUrl = $params.Name
                Default   = $null
                Intranet  = $null
                Internet  = $null
                Extranet  = $null
                Custom    = $null
            }
        }

        $zones = $wa.IisSettings.Keys
        $default = @()
        $intranet = @()
        $internet = @()
        $extranet = @()
        $custom = @()

        foreach ($zone in $zones)
        {
            $authProviders = Get-SPAuthenticationProvider -WebApplication $params.WebAppUrl -Zone $zone
            if ($null -eq $authProviders)
            {
                $localAuthMode          = "Classic"
                $authenticationProvider = $null
                $roleProvider           = $null
                $membershipProvider     = $null

                $provider = @{
                    AuthenticationMethod   = $localAuthMode
                    AuthenticationProvider = $authenticationProvider
                    MembershipProvider     = $membershipProvider
                    RoleProvider           = $roleProvider
                }
                switch ($zone)
                {
                    "Default"  { $default += $provider }
                    "Intranet" { $intranet += $provider }
                    "Internet" { $internet += $provider }
                    "Extranet" { $extranet += $provider }
                    "Custom"   { $custom += $provider }
                }
            }
            else
            {
                foreach ($authProvider in $authProviders)
                {
                    $localAuthMode          = $null
                    $authenticationProvider = $null
                    $roleProvider           = $null
                    $membershipProvider     = $null

                    if ($authProvider.DisplayName -eq "Windows Authentication")
                    {
                        if ($authProvider.DisableKerberos -eq $true)
                        {
                            $localAuthMode = "NTLM"
                        }
                        else
                        {
                            $localAuthMode = "Kerberos"
                        }
                    }
                    elseif ($authProvider.DisplayName -eq "Forms Authentication")
                    {
                        $localAuthMode          = "FBA"
                        $roleProvider           = $authProvider.RoleProvider
                        $membershipProvider     = $authProvider.MembershipProvider
                    }
                    else
                    {
                        $localAuthMode = "Federated"
                        $authenticationProvider = $authProvider.DisplayName
                    }

                    $provider = @{
                        AuthenticationMethod   = $localAuthMode
                        AuthenticationProvider = $authenticationProvider
                        MembershipProvider     = $membershipProvider
                        RoleProvider           = $roleProvider
                    }
                    switch ($zone)
                    {
                        "Default"  { $default += $provider }
                        "Intranet" { $intranet += $provider }
                        "Internet" { $internet += $provider }
                        "Extranet" { $extranet += $provider }
                        "Custom"   { $custom += $provider }
                    }
                }
            }
        }

        return @{
            WebAppUrl = $params.WebAppUrl
            Default   = $default
            Intranet  = $intranet
            Internet  = $internet
            Extranet  = $extranet
            Custom    = $custom
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
        $WebAppUrl,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Default,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Intranet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Internet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Extranet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Custom,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application authentication for '$WebAppUrl'"

    # Test is at least one zone is specified
    if ($PSBoundParameters.ContainsKey("Default") -eq $false -and `
        $PSBoundParameters.ContainsKey("Intranet") -eq $false -and `
        $PSBoundParameters.ContainsKey("Internet") -eq $false -and `
        $PSBoundParameters.ContainsKey("Extranet") -eq $false -and `
        $PSBoundParameters.ContainsKey("Custom") -eq $false)
    {
        throw "You have to specify at least one zone."
    }

    # Perform test on specified configurations for each zone
    if ($PSBoundParameters.ContainsKey("Default"))
    {
        Test-Parameter -Zone $Default -Exception
    }

    if ($PSBoundParameters.ContainsKey("Intranet"))
    {
        Test-Parameter -Zone $Intranet -Exception
    }

    if ($PSBoundParameters.ContainsKey("Internet"))
    {
        Test-Parameter -Zone $Internet -Exception
    }

    if ($PSBoundParameters.ContainsKey("Extranet"))
    {
        Test-Parameter -Zone $Extranet -Exception
    }

    if ($PSBoundParameters.ContainsKey("Custom"))
    {
        Test-Parameter -Zone $Custom -Exception
    }

    # Get current authentication method
    $authMethod = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            throw "Specified Web Application $($params.WebAppUrl) does not exist"
        }

        $authProviders = Get-SPAuthenticationProvider -WebApplication $params.WebAppUrl -Zone Default
        if ($null -eq $authProviders)
        {
            return "Classic"
        }
        else
        {
            return "Claims"
        }
    }

    # Check if web application is configured as Classic, but the config specifies a Claim model
    # This resource does not support Classic to Claims conversion.
    if ($authMethod -eq "Classic")
    {
        if ($PSBoundParameters.ContainsKey("Default"))
        {
            Test-ZoneIsNotClassic -Zone $Default
        }

        if ($PSBoundParameters.ContainsKey("Intranet"))
        {
            Test-ZoneIsNotClassic -Zone $Intranet
        }

        if ($PSBoundParameters.ContainsKey("Internet"))
        {
            Test-ZoneIsNotClassic -Zone $Intranet
        }

        if ($PSBoundParameters.ContainsKey("Extranet"))
        {
            Test-ZoneIsNotClassic -Zone $Extranet
        }

        if ($PSBoundParameters.ContainsKey("Custom"))
        {
            Test-ZoneIsNotClassic -Zone $Custom
        }
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($PSBoundParameters.ContainsKey("Default"))
    {
        # Test is current config matches desired config
        $result = Test-ZoneConfiguration -DesiredConfig $Default `
                                         -CurrentConfig $CurrentValues.Default

        # If that is the case, set desired config.
        if ($result -eq $false)
        {
            Set-ZoneConfiguration -WebAppUrl $WebAppUrl -Zone "Default" -DesiredConfig $Default
        }
    }

    if ($PSBoundParameters.ContainsKey("Intranet"))
    {
        # Check if specified zone exists
        if ($CurrentValues.ContainsKey("Intranet") -eq $false)
        {
            throw "Specified zone Intranet does not exist"
        }

        # Test is current config matches desired config
        $result = Test-ZoneConfiguration -DesiredConfig $Intranet `
                                         -CurrentConfig $CurrentValues.Intranet

        # If that is the case, set desired config.
        if ($result -eq $false)
        {
            Set-ZoneConfiguration -WebAppUrl $WebAppUrl -Zone "Intranet" -DesiredConfig $Intranet
        }
    }

    if ($PSBoundParameters.ContainsKey("Internet"))
    {
        # Check if specified zone exists
        if ($CurrentValues.ContainsKey("Internet") -eq $false)
        {
            throw "Specified zone Internet does not exist"
        }

        # Test is current config matches desired config
        $result = Test-ZoneConfiguration -DesiredConfig $Internet `
                                         -CurrentConfig $CurrentValues.Internet

        # If that is the case, set desired config.
        if ($result -eq $false)
        {
            Set-ZoneConfiguration -WebAppUrl $WebAppUrl -Zone "Internet" -DesiredConfig $Internet
        }
    }

    if ($PSBoundParameters.ContainsKey("Extranet"))
    {
        # Check if specified zone exists
        if ($CurrentValues.ContainsKey("Extranet") -eq $false)
        {
            throw "Specified zone Extranet does not exist"
        }

        # Test is current config matches desired config
        $result = Test-ZoneConfiguration -DesiredConfig $Extranet `
                                         -CurrentConfig $CurrentValues.Extranet

        # If that is the case, set desired config.
        if ($result -eq $false)
        {
            Set-ZoneConfiguration -WebAppUrl $WebAppUrl -Zone "Extranet" -DesiredConfig $Extranet
        }
    }

    if ($PSBoundParameters.ContainsKey("Custom"))
    {
        # Check if specified zone exists
        if ($CurrentValues.ContainsKey("Custom") -eq $false)
        {
            throw "Specified zone Custom does not exist"
        }

        # Test is current config matches desired config
        $result = Test-ZoneConfiguration -DesiredConfig $Custom `
                                         -CurrentConfig $CurrentValues.Custom

        # If that is the case, set desired config.
        if ($result -eq $false)
        {
            Set-ZoneConfiguration -WebAppUrl $WebAppUrl -Zone "Custom" -DesiredConfig $Custom
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
        $WebAppUrl,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Default,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Intranet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Internet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Extranet,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Custom,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing web application authentication for '$WebAppUrl'"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues.Default -and `
        $null -eq $CurrentValues.Intranet -and `
        $null -eq $CurrentValues.Internet -and `
        $null -eq $CurrentValues.Extranet -and `
        $null -eq $CurrentValues.Custom)
    {
        return $false
    }

    if ($PSBoundParameters.ContainsKey("Default"))
    {
        $result = Test-ZoneConfiguration -DesiredConfig $Default `
                                         -CurrentConfig $CurrentValues.Default

        if ($result -eq $false)
        {
            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey("Intranet"))
    {
        if ($CurrentValues.ContainsKey("Intranet") -eq $false)
        {
            throw "Specified zone Intranet does not exist"
        }

        $result = Test-ZoneConfiguration -DesiredConfig $Intranet `
                                         -CurrentConfig $CurrentValues.Intranet

        if ($result -eq $false)
        {
            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey("Internet"))
    {
        if ($CurrentValues.ContainsKey("Internet") -eq $false)
        {
            throw "Specified zone Internet does not exist"
        }

        $result = Test-ZoneConfiguration -DesiredConfig $Internet `
                                         -CurrentConfig $CurrentValues.Internet

        if ($result -eq $false)
        {
            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey("Extranet"))
    {
        if ($CurrentValues.ContainsKey("Extranet") -eq $false)
        {
            throw "Specified zone Extranet does not exist"
        }

        $result = Test-ZoneConfiguration -DesiredConfig $Extranet `
                                         -CurrentConfig $CurrentValues.Extranet

        if ($result -eq $false)
        {
            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey("Custom"))
    {
        if ($CurrentValues.ContainsKey("Custom") -eq $false)
        {
            throw "Specified zone Custom does not exist"
        }

        $result = Test-ZoneConfiguration -DesiredConfig $Custom `
                                         -CurrentConfig $CurrentValues.Custom

        if ($result -eq $false)
        {
            return $false
        }
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource

function Test-Parameter()
{
    param (
        [Parameter(Mandatory = $true)]
        $Zone,

        [Parameter()]
        [switch]
        $Exception
    )

    $ntlmUsed     = $false
    $kerberosUsed = $false
    foreach ($zoneConfig in $Zone)
    {
        $authProviderUsed = $false
        $membProviderUsed = $false
        $roleProviderUsed = $false
        # Check if the config contains the AuthenticationProvider Property
        $prop = $zoneConfig.CimInstanceProperties | Where-Object -FilterScript {
            $_.Name -eq "AuthenticationProvider"
        }
        if ($null -ne $prop.Value)
        {
            $authProviderUsed = $true
        }

        # Check if the config contains the MembershipProvider Property
        $prop = $zoneConfig.CimInstanceProperties | Where-Object -FilterScript {
            $_.Name -eq "MembershipProvider"
        }
        if ($null -ne $prop.Value)
        {
            $membProviderUsed = $true
        }

        # Check if the config contains the RoleProvider Property
        $prop = $zoneConfig.CimInstanceProperties | Where-Object -FilterScript {
            $_.Name -eq "RoleProvider"
        }
        if ($null -ne $prop.Value)
        {
            $roleProviderUsed = $true
        }

        switch ($zoneConfig.AuthenticationMethod)
        {
            "NTLM" {
                $ntlmUsed = $true
                if ($authProviderUsed -eq $true -or `
                    $membProviderUsed -eq $true -or `
                    $roleProviderUsed -eq $true)
                {
                    $message = "You cannot use AuthenticationProvider, MembershipProvider " + `
                               "or RoleProvider when using NTLM"
                    if ($Exception)
                    {
                        throw $message
                    }
                    else
                    {
                        Write-Verbose -Message $message
                        return $false
                    }
                }
            }
            "Kerberos" {
                $kerberosUsed = $true
                if ($authProviderUsed -eq $true -or `
                    $membProviderUsed -eq $true -or `
                    $roleProviderUsed -eq $true)
                {
                    $message = "You cannot use AuthenticationProvider, MembershipProvider " + `
                               "or RoleProvider when using Kerberos"
                    if ($Exception)
                    {
                        throw $message
                    }
                    else
                    {
                        Write-Verbose -Message $message
                        return $false
                    }
                }
            }
            "FBA" {
                if ($membProviderUsed -eq $false -or `
                    $roleProviderUsed -eq $false)
                {
                    $message = "You have to specify MembershipProvider and " + `
                               "RoleProvider when using FBA"
                    if ($Exception)
                    {
                        throw $message
                    }
                    else
                    {
                        Write-Verbose -Message $message
                        return $false
                    }
                }

                if ($authProviderUsed -eq $true)
                {
                    $message = "You cannot use AuthenticationProvider when " + `
                               "using FBA"
                    if ($Exception)
                    {
                        throw $message
                    }
                    else
                    {
                        Write-Verbose -Message $message
                        return $false
                    }
                }
            }
            "Federated" {
                if ($membProviderUsed -eq $true -or `
                    $roleProviderUsed -eq $true)
                {
                    $message = "You cannot use MembershipProvider or " + `
                               "RoleProvider when using Federated"
                    if ($Exception)
                    {
                        throw $message
                    }
                    else
                    {
                        Write-Verbose -Message $message
                        return $false
                    }
                }

                if ($authProviderUsed -eq $false)
                {
                    $message = "You have to specify AuthenticationProvider when " + `
                               "using Federated"
                    if ($Exception)
                    {
                        throw $message
                    }
                    else
                    {
                        Write-Verbose -Message $message
                        return $false
                    }
                }

            }
        }

        if ($ntlmUsed -and $kerberosUsed)
        {
            $message = "You cannot use both NTLM and Kerberos in the same zone"
            if ($Exception)
            {
                throw $message
            }
            else
            {
                Write-Verbose -Message $message
                return $false
            }
        }
    }
    if (-not $Exception)
    {
        return $true
    }
}

function Test-ZoneIsNotClassic()
{
    param (
        [Parameter(Mandatory = $true)]
        $Zone
    )

    foreach ($desiredAuth in $Zone)
    {
        if ($desiredAuth.AuthenticationMethod -ne "Classic")
        {
            throw ("Specified Web Application is using Classic Authentication and " + `
                   "Claims Authentication is specified. Please use " + `
                   "Convert-SPWebApplication first!")
        }
    }
}

function Set-ZoneConfiguration()
{
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default","Intranet","Internet","Extranet","Custom")]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DesiredConfig
    )

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        $ap = @()

        foreach ($zoneConfig in $params.DesiredConfig)
        {
            switch ($zoneConfig.AuthenticationMethod)
            {
                "NTLM" {
                    $newap = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication
                }
                "Kerberos" {
                    $newap = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication `
                                                          -DisableKerberos:$false
                }
                "FBA" {
                    $newap = New-SPAuthenticationProvider -ASPNETMembershipProvider $zoneConfig.MembershipProvider `
                                                          -ASPNETRoleProviderName $zoneConfig.RoleProvider
                }
                "Federated" {
                    $tokenIssuer = Get-SPTrustedIdentityTokenIssuer -Identity $zoneConfig.AuthenticationProvider `
                                                                    -ErrorAction SilentlyContinue
                    if ($null -eq $tokenIssuer)
                    {
                        throw ("Specified AuthenticationProvider $($zoneConfig.AuthenticationProvider) " + `
                               "does not exist")
                    }
                    $newap = New-SPAuthenticationProvider -TrustedIdentityTokenIssuer $tokenIssuer
                }
            }
            $ap += $newap
        }

        Set-SPWebApplication -Identity $params.WebAppUrl -Zone $params.Zone -AuthenticationProvider $ap
    }
}

function Test-ZoneConfiguration()
{
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DesiredConfig,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable[]]
        $CurrentConfig
    )

    # Testing specified configuration against configured values
    foreach ($zoneConfig in $DesiredConfig)
    {
        switch ($zoneConfig.AuthenticationMethod)
        {
            { $_ -in @("NTLM","Kerberos","Classic") } {
                $configuredMethod = $CurrentConfig | `
                                    Where-Object -FilterScript {
                                        $_.AuthenticationMethod -eq $zoneConfig.AuthenticationMethod
                                    }
            }
            "FBA" {
                $configuredMethod = $CurrentConfig | `
                                    Where-Object -FilterScript {
                                        $_.AuthenticationMethod -eq $zoneConfig.AuthenticationMethod -and `
                                        $_.MembershipProvider -eq $zoneConfig.MembershipProvider -and `
                                        $_.RoleProvider -eq $zoneConfig.RoleProvider
                                    }
            }
            "Federated" {
                $configuredMethod = $CurrentConfig | `
                                    Where-Object -FilterScript {
                                        $_.AuthenticationMethod -eq $zoneConfig.AuthenticationMethod -and `
                                        $_.AuthenticationProvider -eq $zoneConfig.AuthenticationProvider
                                    }
            }
        }

        if ($null -eq $configuredMethod)
        {
            return $false
        }
    }

    # Reverse: Testing configured values against specified configuration
    foreach ($zoneConfig in $CurrentConfig)
    {
        switch ($zoneConfig.AuthenticationMethod)
        {
            { $_ -in @("NTLM","Kerberos","Classic") } {
                $specifiedMethod = $DesiredConfig | `
                                   Where-Object -FilterScript {
                                       $_.AuthenticationMethod -eq $zoneConfig.AuthenticationMethod
                                   }
            }
            "FBA" {
                $specifiedMethod = $DesiredConfig | `
                                   Where-Object -FilterScript {
                                       $_.AuthenticationMethod -eq $zoneConfig.AuthenticationMethod -and `
                                       $_.MembershipProvider -eq $zoneConfig.MembershipProvider -and `
                                       $_.RoleProvider -eq $zoneConfig.RoleProvider
                                   }
            }
            "Federated" {
                $specifiedMethod = $DesiredConfig | `
                                   Where-Object -FilterScript {
                                       $_.AuthenticationMethod -eq $zoneConfig.AuthenticationMethod -and `
                                       $_.AuthenticationProvider -eq $zoneConfig.AuthenticationProvider
                                   }
            }
        }

        if ($null -eq $specifiedMethod)
        {
            return $false
        }
    }
    return $true
}
