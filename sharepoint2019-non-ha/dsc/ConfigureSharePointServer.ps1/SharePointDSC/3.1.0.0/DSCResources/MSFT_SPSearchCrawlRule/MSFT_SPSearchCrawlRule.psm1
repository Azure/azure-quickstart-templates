function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Path,
        
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAppName,
        
        [Parameter()] 
        [ValidateSet("DefaultRuleAccess", 
                     "BasicAccountRuleAccess", 
                     "CertificateRuleAccess", 
                     "NTLMAccountRuleAccess", 
                     "FormRuleAccess", 
                     "CookieRuleAccess", 
                     "AnonymousAccess")] 
        [System.String] 
        $AuthenticationType,
        
        [Parameter()] 
        [ValidateSet("InclusionRule","ExclusionRule")] 
        [System.String] 
        $RuleType,
        
        [Parameter()] 
        [ValidateSet("FollowLinksNoPageCrawl",
                     "CrawlComplexUrls", 
                     "CrawlAsHTTP")] 
        [System.String[]] 
        $CrawlConfigurationRules,
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $AuthenticationCredentials,
        
        [Parameter()]  
        [System.String] 
        $CertificateName,
        
        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting Search Crawl Rule '$Path'"

    # AuthenticationType=CertificateName and CertificateRuleAccess parameters not specified
    if ($AuthenticationType -eq "CertificateRuleAccess" -and -not $CertificateName) 
    {
        throw ("When AuthenticationType=CertificateRuleAccess, the parameter " + `
               "CertificateName is required")
    }

    # AuthenticationType=CertificateName and CertificateRuleAccess parameters not 
    # specified correctly
    if ($AuthenticationType -ne "CertificateRuleAccess" -and $CertificateName)
    {
        throw "When specifying CertificateName, the AuthenticationType parameter is required"
    }

    # AuthenticationType=NTLMAccountRuleAccess and AuthenticationCredentialsparameters 
    # not specified
    if (($AuthenticationType -eq "NTLMAccountRuleAccess" `
        -or $AuthenticationType -eq "BasicAccountRuleAccess") `
        -and -not $AuthenticationCredentials) 
    {
        throw ("When AuthenticationType is NTLMAccountRuleAccess or BasicAccountRuleAccess, " + `
               "the parameter AuthenticationCredentials is required")
    }

    # AuthenticationCredentials parameters, but AuthenticationType is not NTLMAccountRuleAccess 
    # or BasicAccountRuleAccess
    if ($AuthenticationCredentials `
        -and $AuthenticationType -ne "NTLMAccountRuleAccess" `
        -and $AuthenticationType -ne "BasicAccountRuleAccess")
    {
        throw ("When specifying AuthenticationCredentials, the AuthenticationType " + `
               "parameter is required")
    }
    
    # ExclusionRule only with CrawlConfigurationRules=CrawlComplexUrls
    if ($RuleType -eq "ExclusionRule" `
        -and ($CrawlConfigurationRules -contains "CrawlAsHTTP" `
            -or $CrawlConfigurationRules -contains "FollowLinksNoPageCrawl")) 
    {
        throw ("When RuleType=ExclusionRule, CrawlConfigurationRules cannot contain " + `
               "the values FollowLinksNoPageCrawl or CrawlAsHTTP")
    }

    # ExclusionRule cannot be used with AuthenticationCredentials, CertificateName or 
    # AuthenticationType parameters
    if ($RuleType -eq "ExclusionRule" `
        -and ($AuthenticationCredentials -or $CertificateName -or $AuthenticationType)) 
    {
        throw ("When Type=ExclusionRule, parameters AuthenticationCredentials, " + `
               "CertificateName or AuthenticationType are not allowed")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApps = Get-SPServiceApplication -Name $params.ServiceAppName `
                                                -ErrorAction SilentlyContinue
        
        $nullReturn = @{
            Path = $params.Path
            ServiceAppName = $params.ServiceAppName
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        }
         
        if ($null -eq $serviceApps) 
        {
            Write-Verbose -Message "Service Application $($params.ServiceAppName) not found"
            return $nullReturn 
        }
        
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.Office.Server.Search.Administration.SearchServiceApplication" 
        }

        if ($null -eq $serviceApp) 
        {
            Write-Verbose -Message "Service Application $($params.ServiceAppName) not found"
            return $nullReturn
        } 
        else 
        {
            $crawlRule = Get-SPEnterpriseSearchCrawlRule `
                          -SearchApplication $params.ServiceAppName | Where-Object -FilterScript {
                              $_.Path -eq $params.Path 
                          }

            if ($null -eq $crawlRule) 
            {
                Write-Verbose -Message "Crawl rule $($params.Path) not found"
                return $nullReturn
            } 
            else 
            {
                $crawlConfigurationRules = @()
                if ($crawlRule.SuppressIndexing) 
                {
                    $crawlConfigurationRules += "FollowLinksNoPageCrawl" 
                }
                if ($crawlRule.FollowComplexUrls) 
                {
                    $crawlConfigurationRules += "CrawlComplexUrls" 
                }
                if ($crawlRule.CrawlAsHttp) 
                {
                    $crawlConfigurationRules += "CrawlAsHTTP" 
                }

                switch ($crawlRule.AuthenticationType) 
                {
                    {@("BasicAccountRuleAccess", 
                       "NTLMAccountRuleAccess") -contains $_ } {
                        $returnVal = @{
                            Path = $params.Path
                            ServiceAppName = $params.ServiceAppName
                            AuthenticationType = $crawlRule.AuthenticationType
                            RuleType = $crawlRule.Type.ToString()
                            CrawlConfigurationRules = $crawlConfigurationRules
                            AuthenticationCredentials = $crawlRule.AccountName
                            Ensure = "Present"
                            InstallAccount = $params.InstallAccount
                        } 
                    }
                    "CertificateRuleAccess" {
                        $returnVal = @{
                            Path = $params.Path
                            ServiceAppName = $params.ServiceAppName
                            AuthenticationType = $crawlRule.AuthenticationType
                            RuleType = $crawlRule.Type.ToString()
                            CrawlConfigurationRules = $crawlConfigurationRules
                            CertificateName = $crawlRule.AccountName
                            Ensure = "Present"
                            InstallAccount = $params.InstallAccount
                        } 
                    }
                    { @("DefaultRuleAccess", 
                        "FormRuleAccess", 
                        "CookieRuleAccess", 
                        "AnonymousAccess") -contains $_ } {
                        $returnVal = @{
                            Path = $params.Path
                            ServiceAppName = $params.ServiceAppName
                            AuthenticationType = $crawlRule.AuthenticationType.ToString()
                            RuleType = $crawlRule.Type.ToString()
                            CrawlConfigurationRules = $crawlConfigurationRules
                            Ensure = "Present"
                            InstallAccount = $params.InstallAccount
                        }                
                    }
                    default {
                            Path = $params.Path
                            ServiceAppName = $params.ServiceAppName
                            AuthenticationType = "Unknown"
                            RuleType = $crawlRule.Type.ToString()
                            CrawlConfigurationRules = $crawlConfigurationRules
                            Ensure = "Present"
                            InstallAccount = $params.InstallAccount
                    }
                }
                return $returnVal
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
        $Path,
        
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAppName,
        
        [Parameter()] 
        [ValidateSet("DefaultRuleAccess", 
                     "BasicAccountRuleAccess", 
                     "CertificateRuleAccess", 
                     "NTLMAccountRuleAccess", 
                     "FormRuleAccess", 
                     "CookieRuleAccess", 
                     "AnonymousAccess")] 
        [System.String] 
        $AuthenticationType,
        
        [Parameter()] 
        [ValidateSet("InclusionRule","ExclusionRule")] 
        [System.String] 
        $RuleType,
        
        [Parameter()] 
        [ValidateSet("FollowLinksNoPageCrawl",
                     "CrawlComplexUrls", 
                     "CrawlAsHTTP")] 
        [System.String[]] 
        $CrawlConfigurationRules,
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $AuthenticationCredentials,
        
        [Parameter()]  
        [System.String] 
        $CertificateName,
        
        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting Search Crawl Rule '$Path'"
    
    $result = Get-TargetResource @PSBoundParameters

    # AuthenticationType=CertificateName and CertificateRuleAccess parameters not specified
    if ($AuthenticationType -eq "CertificateRuleAccess" -and -not $CertificateName) 
    {
        throw ("When AuthenticationType=CertificateRuleAccess, the parameter " + `
               "CertificateName is required")
    }

    # AuthenticationType=CertificateName and CertificateRuleAccess parameters not 
    # specified correctly
    if ($AuthenticationType -ne "CertificateRuleAccess" -and $CertificateName)
    {
        throw "When specifying CertificateName, the AuthenticationType parameter is required"
    }

    # AuthenticationType=NTLMAccountRuleAccess and AuthenticationCredentialsparameters 
    # not specified
    if (($AuthenticationType -eq "NTLMAccountRuleAccess" `
        -or $AuthenticationType -eq "BasicAccountRuleAccess") `
        -and -not $AuthenticationCredentials) 
    {
        throw ("When AuthenticationType is NTLMAccountRuleAccess or BasicAccountRuleAccess, " + `
               "the parameter AuthenticationCredentials is required")
    }

    # AuthenticationCredentials parameters, but AuthenticationType is not NTLMAccountRuleAccess 
    # or BasicAccountRuleAccess
    if ($AuthenticationCredentials `
        -and $AuthenticationType -ne "NTLMAccountRuleAccess" `
        -and $AuthenticationType -ne "BasicAccountRuleAccess")
    {
        throw ("When specifying AuthenticationCredentials, the AuthenticationType " + `
               "parameter is required")
    }
    
    # ExclusionRule only with CrawlConfigurationRules=CrawlComplexUrls
    if ($RuleType -eq "ExclusionRule" `
        -and ($CrawlConfigurationRules -contains "CrawlAsHTTP" `
            -or $CrawlConfigurationRules -contains "FollowLinksNoPageCrawl")) 
    {
        throw ("When RuleType=ExclusionRule, CrawlConfigurationRules cannot contain " + `
               "the values FollowLinksNoPageCrawl or CrawlAsHTTP")
    }

    # ExclusionRule cannot be used with AuthenticationCredentials, CertificateName or 
    # AuthenticationType parameters
    if ($RuleType -eq "ExclusionRule" `
        -and ($AuthenticationCredentials -or $CertificateName -or $AuthenticationType)) 
    {
        throw ("When Type=ExclusionRule, parameters AuthenticationCredentials, " + `
               "CertificateName or AuthenticationType are not allowed")
    }

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Creating Crawl Rule $Path"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $newParams = @{
                Path = $params.Path
                SearchApplication = $params.ServiceAppName
            }
            if ($params.ContainsKey("AuthenticationType") -eq $true) 
            {
                $newParams.Add("AuthenticationType", $params.AuthenticationType) 
            }
            if ($params.ContainsKey("RuleType") -eq $true) 
            {
                $newParams.Add("Type", $params.RuleType) 
            }
            if ($params.ContainsKey("CrawlConfigurationRules") -eq $true) 
            {
                if($params.CrawlConfigurationRules -contains "FollowLinksNoPageCrawl") 
                {
                    $newParams.Add("SuppressIndexing",1) 
                }
                if($params.CrawlConfigurationRules -contains "CrawlComplexUrls") 
                {
                    $newParams.Add("FollowComplexUrls",1) 
                }
                if($params.CrawlConfigurationRules -contains "CrawlAsHTTP") 
                {
                    $newParams.Add("CrawlAsHttp",1) 
                }
            }
            if ($params.ContainsKey("AuthenticationCredentials") -eq $true) 
            {
                $newParams.Add("AccountName", $params.AuthenticationCredentials.UserName)
                $newParams.Add("AccountPassword", $params.AuthenticationCredentials.Password)
            }
            if ($params.ContainsKey("CertificateName") -eq $true) 
            {
                $newParams.Add("CertificateName", $params.CertificateName) 
            }
            
            New-SPEnterpriseSearchCrawlRule @newParams 
        }
    }
    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Updating Crawl Rule $Path"
        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]
            
            $crawlRule = Get-SPEnterpriseSearchCrawlRule `
                            -SearchApplication $params.ServiceAppName | Where-Object -FilterScript {
                                $_.Path -eq $params.Path 
                            }

            if ($null -ne $crawlRule) 
            {
                $setParams = @{
                    Identity = $params.Path
                    SearchApplication = $params.ServiceAppName
                }
                if ($params.ContainsKey("AuthenticationType") -eq $true) 
                {
                    $setParams.Add("AuthenticationType", $params.AuthenticationType) 
                }
                if ($params.ContainsKey("RuleType") -eq $true) 
                {
                    $setParams.Add("Type", $params.RuleType) 
                }
                if ($params.ContainsKey("CrawlConfigurationRules") -eq $true) 
                {
                    if($params.CrawlConfigurationRules -contains "FollowLinksNoPageCrawl") 
                    {
                        $setParams.Add("SuppressIndexing",1) 
                    }
                    if($params.CrawlConfigurationRules -contains "CrawlComplexUrls") 
                    {
                        $setParams.Add("FollowComplexUrls",1) 
                    }
                    if($params.CrawlConfigurationRules -contains "CrawlAsHTTP") 
                    {
                        $setParams.Add("CrawlAsHttp",1) 
                    }
                }
                if ($params.ContainsKey("AuthenticationCredentials") -eq $true) 
                {
                    $setParams.Add("AccountName", $params.AuthenticationCredentials.UserName)
                    $setParams.Add("AccountPassword", $params.AuthenticationCredentials.Password)
                }
                if ($params.ContainsKey("CertificateName") -eq $true) 
                {
                    $setParams.Add("AccountName", $params.CertificateName) 
                }
                Set-SPEnterpriseSearchCrawlRule @setParams 
            }
        }
    }
    
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing Crawl Rule $Path"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            Remove-SPEnterpriseSearchCrawlRule -SearchApplication $params.ServiceAppName `
                                               -Identity $params.Path `
                                               -Confirm:$false
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
        $Path,
        
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAppName,
        
        [Parameter()] 
        [ValidateSet("DefaultRuleAccess", 
                     "BasicAccountRuleAccess", 
                     "CertificateRuleAccess", 
                     "NTLMAccountRuleAccess", 
                     "FormRuleAccess", 
                     "CookieRuleAccess", 
                     "AnonymousAccess")] 
        [System.String] 
        $AuthenticationType,
        
        [Parameter()] 
        [ValidateSet("InclusionRule","ExclusionRule")] 
        [System.String] 
        $RuleType,
        
        [Parameter()] 
        [ValidateSet("FollowLinksNoPageCrawl",
                     "CrawlComplexUrls", 
                     "CrawlAsHTTP")] 
        [System.String[]] 
        $CrawlConfigurationRules,
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $AuthenticationCredentials,
        
        [Parameter()]  
        [System.String] 
        $CertificateName,
        
        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing Search Crawl Rule '$Path'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters
        
    if ($Ensure -eq "Present") 
    {
        if ($CrawlConfigurationRules) 
        {
            if ($CurrentValues.ContainsKey("CrawlConfigurationRules")) 
            {
                $compareObject = Compare-Object `
                                    -ReferenceObject $CrawlConfigurationRules `
                                    -DifferenceObject $CurrentValues.CrawlConfigurationRules
                if ($null -ne $compareObject)
                {
                    return $false 
                }
            } 
            else 
            {
                return $false 
            }
        }

        if ($CurrentValues.ContainsKey("AuthenticationCredentials") -and $AuthenticationCredentials) 
        {
            if ($AuthenticationCredentials.UserName -ne $CurrentValues.AuthenticationCredentials) 
            {
                return $false 
            }
        }
        
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure", 
                                                         "AuthenticationType", 
                                                         "RuleType", 
                                                         "CertificateName")    
    } else {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
