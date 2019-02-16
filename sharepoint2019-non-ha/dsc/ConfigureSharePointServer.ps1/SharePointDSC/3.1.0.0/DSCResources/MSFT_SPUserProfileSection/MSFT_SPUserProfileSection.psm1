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
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter(Mandatory = $true)] 
        [System.string] 
        $UserProfileService,

        [Parameter()] 
        [System.string] 
        $DisplayName,

        [Parameter()] 
        [System.uint32] 
        $DisplayOrder,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting user profile section $Name"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        $upsa = Get-SPServiceApplication -Name $params.UserProfileService `
                                         -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name = $params.Name
            Ensure = "Absent"
            UserProfileService = $params.UserProfileService
        } 

        if ($null -eq $upsa) 
        {
            return $nullReturn 
        }

        $caURL = (Get-SpWebApplication -IncludeCentralAdministration | Where-Object -FilterScript {
            $_.IsAdministrationWebApplication -eq $true
        }).Url
        $context = Get-SPServiceContext -Site $caURL 
        $userProfileConfigManager  = New-Object -TypeName "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" `
                                                -ArgumentList $context
        $properties = $userProfileConfigManager.GetPropertiesWithSection()
        
        $userProfileProperty = $properties.GetSectionByName($params.Name) 
        if ($null -eq $userProfileProperty)
        {
            return $nullReturn
        }

        return @{
            Name = $userProfileProperty.Name 
            UserProfileService = $params.UserProfileService
            DisplayName = $userProfileProperty.DisplayName
            DisplayOrder =$userProfileProperty.DisplayOrder 
            Ensure = "Present"
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
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter(Mandatory = $true)] 
        [System.string] 
        $UserProfileService,

        [Parameter()] 
        [System.string] 
        $DisplayName,

        [Parameter()] 
        [System.uint32] 
        $DisplayOrder,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    # note for integration test: CA can take a couple of minutes to notice the change. 
    # don't try refreshing properties page. go through from a fresh "flow" from Service apps page
    Write-Verbose -Message "Setting user profile section $Name"

    $PSBoundParameters.Ensure = $Ensure
    
    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        
        $ups = Get-SPServiceApplication -Name $params.UserProfileService `
                                        -ErrorAction SilentlyContinue 
 
        if ($null -eq $ups)
        {
            throw "Service application $($params.UserProfileService) not found"
        }
        
        $caURL = (Get-SpWebApplication  -IncludeCentralAdministration | Where-Object -FilterScript {
            $_.IsAdministrationWebApplication -eq $true 
        }).Url
        $context = Get-SPServiceContext  $caURL 

        $userProfileConfigManager  = New-Object -TypeName "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" `
                                                -ArgumentList $context

        if ($null -eq $userProfileConfigManager)
        {
            #if config manager returns null when ups is available then isuee is permissions
            throw "Account running process needs admin permission on user profile service application"
        }
        $properties = $userProfileConfigManager.GetPropertiesWithSection()
        $userProfileProperty = $properties.GetSectionByName($params.Name) 

        if ($params.ContainsKey("Ensure") -and $params.Ensure -eq "Absent")
        {
            if ($null -ne $userProfileProperty)
            {
                $properties.RemoveSectionByName($params.Name)
            }
            return
        } 
        elseif($null -eq $userProfileProperty)
        {
            $coreProperty = $properties.Create($true)
            $coreProperty.Name = $params.Name
            $coreProperty.DisplayName = $params.DisplayName
            $coreProperty.Commit()
        }
        else
        {
            Set-SPDscObjectPropertyIfValuePresent -ObjectToSet $userProfileProperty `
                                                  -PropertyToSet "DisplayName" `
                                                  -ParamsValue $params `
                                                  -ParamKey "DisplayName"
            $userProfileProperty.Commit()
        }

        #region display order
        if ($params.ContainsKey("DisplayOrder"))
        {
            $properties = $userProfileConfigManager.GetPropertiesWithSection()
            $properties.SetDisplayOrderBySectionName($params.Name,$params.DisplayOrder)
            $properties.CommitDisplayOrder()
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
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter(Mandatory = $true)] 
        [System.string] 
        $UserProfileService,

        [Parameter()] 
        [System.string] 
        $DisplayName,

        [Parameter()] 
        [System.uint32] 
        $DisplayOrder,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount

    )

    Write-Verbose -Message "Testing user profile section $Name"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues) 
    {
        return $false  
    }

    if ($Ensure -eq "Present") 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Name",
                                                         "DisplayName", 
                                                         "DisplayOrder", 
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
