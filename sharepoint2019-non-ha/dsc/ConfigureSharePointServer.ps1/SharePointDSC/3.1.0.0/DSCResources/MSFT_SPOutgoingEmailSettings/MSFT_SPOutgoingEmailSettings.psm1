function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $WebAppUrl,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $SMTPServer,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $FromAddress,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ReplyToAddress,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $CharacterSet,

        [Parameter()] 
        [System.Boolean]  
        $UseTLS,
        
        [Parameter()] 
        [System.UInt32]  
        $SMTPPort,
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting outgoing email settings configuration for $WebAppUrl"

    $installedVersion = Get-SPDSCInstalledProductVersion
    if (($PSBoundParameters.ContainsKey("UseTLS") -eq $true) `
        -and $installedVersion.FileMajorPart -ne 16) 
    {
        throw [Exception] "UseTLS is only supported in SharePoint 2016 and SharePoint 2019."
    }

    if (($PSBoundParameters.ContainsKey("SMTPPort") -eq $true) `
        -and $installedVersion.FileMajorPart -ne 16) 
    {
        throw [Exception] "SMTPPort is only supported in SharePoint 2016 and SharePoint 2019."
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        $webApp = Get-SPWebApplication -Identity $params.WebAppUrl `
                                       -IncludeCentralAdministration `
                                       -ErrorAction SilentlyContinue

        if ($null -eq $webApp) 
        {
            return $null
        }
        
        $mailServer = $null
        if ($null -ne $webApp.OutboundMailServiceInstance) 
        {
            $mailServer = $webApp.OutboundMailServiceInstance.Server.Name
        }
        
        return @{
            WebAppUrl = $webApp.Url
            SMTPServer= $mailServer
            FromAddress= $webApp.OutboundMailSenderAddress
            ReplyToAddress= $webApp.OutboundMailReplyToAddress
            CharacterSet = $webApp.OutboundMailCodePage
            UseTLS = $webApp.OutboundMailEnableSsl
            SMTPPort = $webApp.OutboundMailPort
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

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $SMTPServer,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $FromAddress,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ReplyToAddress,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $CharacterSet,

        [Parameter()] 
        [System.Boolean]  
        $UseTLS,
        
        [Parameter()] 
        [System.UInt32]  
        $SMTPPort,
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting outgoing email settings configuration for $WebAppUrl"

    $installedVersion = Get-SPDSCInstalledProductVersion
    if (($PSBoundParameters.ContainsKey("UseTLS") -eq $true) `
        -and $installedVersion.FileMajorPart -lt 16) 
    {
        throw [Exception] "UseTLS is only supported in SharePoint 2016 and SharePoint 2019."
    }

    if (($PSBoundParameters.ContainsKey("SMTPPort") -eq $true) `
        -and $installedVersion.FileMajorPart -lt 16) 
    {
        throw [Exception] "SMTPPort is only supported in SharePoint 2016 and SharePoint 2019."
    }
    
    $null = Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
        $params = $args[0]
        $webApp = $null

        Write-Verbose -Message "Retrieving $($params.WebAppUrl)  settings"
        
        $webApp = Get-SPWebApplication $params.WebAppUrl -IncludeCentralAdministration 
        if ($null -eq $webApp)
        {
            throw "Web Application $webAppUrl not found"
        }

        $installedVersion = Get-SPDSCInstalledProductVersion
        switch ($installedVersion.FileMajorPart)
        {
            15 {
                $webApp.UpdateMailSettings($params.SMTPServer, `
                                           $params.FromAddress, `
                                           $params.ReplyToAddress, `
                                           $params.CharacterSet) 
            }
            16 {
                if ($params.ContainsKey("UseTLS") -eq $false)
                {
                    $UseTLS = $false
                }
                else
                {
                    $UseTLS = $params.UseTLS                    
                }

                if ($params.ContainsKey("SMTPPort") -eq $false)
                {
                    $SMTPPort = 25
                }
                else
                {
                    $SMTPPort = $params.SMTPPort                    
                }

                $webApp.UpdateMailSettings($params.SMTPServer, `
                                           $params.FromAddress, `
                                           $params.ReplyToAddress, `
                                           $params.CharacterSet, `
                                           $UseTLS, `
                                           $SMTPPort) 
            }
            default {
                throw ("Detected an unsupported major version of SharePoint. SharePointDsc only " + `
                       "supports SharePoint 2013, 2016 or 2019.")
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
        $WebAppUrl,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $SMTPServer,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $FromAddress,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ReplyToAddress,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $CharacterSet,

        [Parameter()] 
        [System.Boolean]  
        $UseTLS,
        
        [Parameter()] 
        [System.UInt32]  
        $SMTPPort,
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting outgoing email settings configuration for $WebAppUrl"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }
    
    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("SMTPServer",
                                                     "FromAddress",
                                                     "ReplyToAddress",
                                                     "CharacterSet",
                                                     "UseTLS",
                                                     "SMTPPort")
}

Export-ModuleMember -Function *-TargetResource
