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
        [ValidateSet("Manage Lists", "Override List Behaviors", "Add Items", "Edit Items",
                     "Delete Items", "View Items", "Approve Items", "Open Items", 
                     "View Versions", "Delete Versions", "Create Alerts", 
                     "View Application Pages")] 
        [System.String[]] 
        $ListPermissions,
        
        [Parameter()] 
        [ValidateSet("Manage Permissions", "View Web Analytics Data", "Create Subsites",
                     "Manage Web Site", "Add and Customize Pages", "Apply Themes and Borders",
                     "Apply Style Sheets", "Create Groups", "Browse Directories", 
                     "Use Self-Service Site Creation", "View Pages", "Enumerate Permissions",
                     "Browse User Information", "Manage Alerts", "Use Remote Interfaces", 
                     "Use Client Integration Features", "Open", "Edit Personal User Information")]
        [System.String[]] 
        $SitePermissions,
        
        [Parameter()]
        [ValidateSet("Manage Personal Views", "Add/Remove Personal Web Parts", 
                     "Update Personal Web Parts")] 
        [System.String[]] 
        $PersonalPermissions,
        
        [Parameter()] 
        [System.Boolean] 
        $AllPermissions,
        
        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting permissions for Web Application '$WebAppUrl'"

    Test-SPDSCInput @PSBoundParameters

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        
        if ($null -eq $wa)
        {
            throw "The specified web application could not be found." 
        }

        if ($wa.RightsMask -eq [Microsoft.SharePoint.SPBasePermissions]::FullMask) 
        {
            $returnval = @{
                WebAppUrl = $params.WebAppUrl
                AllPermissions = $true
            }
        } 
        else 
        {
            $ListPermissions     = @()
            $SitePermissions     = @()
            $PersonalPermissions = @()

            $rightsmask = ($wa.RightsMask -split ",").trim()
            foreach ($rightmask in $rightsmask) 
            {
                switch ($rightmask) 
                {
                    "ManageLists" {
                        $ListPermissions += "Manage Lists" 
                    }
                    "CancelCheckout" {
                        $ListPermissions += "Override List Behaviors" 
                    }
                    "AddListItems" {
                        $ListPermissions += "Add Items" 
                    }
                    "EditListItems" {
                        $ListPermissions += "Edit Items" 
                    }
                    "DeleteListItems" {
                        $ListPermissions += "Delete Items" 
                    }
                    "ViewListItems" {
                        $ListPermissions += "View Items" 
                    }
                    "ApproveItems" {
                        $ListPermissions += "Approve Items" 
                    }
                    "OpenItems" {
                        $ListPermissions += "Open Items" 
                    }
                    "ViewVersions" {
                        $ListPermissions += "View Versions" 
                    }
                    "DeleteVersions" {
                        $ListPermissions += "Delete Versions" 
                    }
                    "CreateAlerts" {
                         $ListPermissions += "Create Alerts" 
                        }
                    "ViewFormPages" {
                        $ListPermissions += "View Application Pages" 
                    }

                    "ManagePermissions" {
                        $SitePermissions += "Manage Permissions" 
                    }
                    "ViewUsageData" {
                        $SitePermissions += "View Web Analytics Data" 
                    }
                    "ManageSubwebs" {
                        $SitePermissions += "Create Subsites" 
                    }
                    "ManageWeb" {
                        $SitePermissions += "Manage Web Site" 
                    }
                    "AddAndCustomizePages" {
                        $SitePermissions += "Add and Customize Pages" 
                    }
                    "ApplyThemeAndBorder" {
                        $SitePermissions += "Apply Themes and Borders" 
                    }
                    "ApplyStyleSheets" {
                        $SitePermissions += "Apply Style Sheets" 
                    }
                    "CreateGroups" {
                        $SitePermissions += "Create Groups" 
                    }
                    "BrowseDirectories" {
                        $SitePermissions += "Browse Directories"
                     }
                    "CreateSSCSite" {
                        $SitePermissions += "Use Self-Service Site Creation" 
                    }
                    "ViewPages" {
                        $SitePermissions += "View Pages" 
                    }
                    "EnumeratePermissions" {
                        $SitePermissions += "Enumerate Permissions" 
                    }
                    "BrowseUserInfo" {
                        $SitePermissions += "Browse User Information" 
                    }
                    "ManageAlerts" {
                        $SitePermissions += "Manage Alerts" 
                    }
                    "UseRemoteAPIs" {
                        $SitePermissions += "Use Remote Interfaces" 
                    }
                    "UseClientIntegration" {
                        $SitePermissions += "Use Client Integration Features" 
                    }
                    "Open" {
                        $SitePermissions += "Open" 
                    }
                    "EditMyUserInfo" {
                        $SitePermissions += "Edit Personal User Information" 
                    }

                    "ManagePersonalViews" {
                        $PersonalPermissions += "Manage Personal Views" 
                    }
                    "AddDelPrivateWebParts" {
                        $PersonalPermissions += "Add/Remove Personal Web Parts" 
                    }
                    "UpdatePersonalWebParts" {
                        $PersonalPermissions += "Update Personal Web Parts" 
                    }
                }
            }

            $returnval = @{
                WebAppUrl = $params.WebAppUrl
                ListPermissions     = $ListPermissions
                SitePermissions     = $SitePermissions
                PersonalPermissions = $PersonalPermissions
            }
        }
        return $returnval
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
        [ValidateSet("Manage Lists", "Override List Behaviors", "Add Items", "Edit Items",
                     "Delete Items", "View Items", "Approve Items", "Open Items", 
                     "View Versions", "Delete Versions", "Create Alerts", 
                     "View Application Pages")] 
        [System.String[]] 
        $ListPermissions,
        
        [Parameter()] 
        [ValidateSet("Manage Permissions", "View Web Analytics Data", "Create Subsites",
                     "Manage Web Site", "Add and Customize Pages", "Apply Themes and Borders",
                     "Apply Style Sheets", "Create Groups", "Browse Directories", 
                     "Use Self-Service Site Creation", "View Pages", "Enumerate Permissions",
                     "Browse User Information", "Manage Alerts", "Use Remote Interfaces", 
                     "Use Client Integration Features", "Open", "Edit Personal User Information")]
        [System.String[]] 
        $SitePermissions,
        
        [Parameter()]
        [ValidateSet("Manage Personal Views", "Add/Remove Personal Web Parts", 
                     "Update Personal Web Parts")] 
        [System.String[]] 
        $PersonalPermissions,
        
        [Parameter()] 
        [System.Boolean] 
        $AllPermissions,
        
        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting permissions for Web Application '$WebAppUrl'"

    Test-SPDSCInput @PSBoundParameters

    $result = Get-TargetResource @PSBoundParameters
    
    if ($AllPermissions)
    {
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
            $params = $args[0]

            $wa = Get-SPWebApplication -Identity $params.WebAppUrl `
                                       -ErrorAction SilentlyContinue
            
            if ($null -eq $wa)
            {
                throw "The specified web application could not be found."
            }

            $wa.RightsMask = [Microsoft.SharePoint.SPBasePermissions]::FullMask
            $wa.Update()
        }
    } 
    else 
    {
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
            $params = $args[0]

            $wa = Get-SPWebApplication -Identity $params.WebAppUrl `
                                       -ErrorAction SilentlyContinue
            
            if ($null -eq $wa)
            {
                throw "The specified web application could not be found." 
            }

            $newMask = [Microsoft.SharePoint.SPBasePermissions]::EmptyMask
            foreach ($lp in $params.ListPermissions) 
            {
                switch ($lp) 
                {
                    "Manage Lists" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ManageLists
                    }
                    "Override List Behaviors" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::CancelCheckout
                    }
                    "Add Items" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::AddListItems
                    }
                    "Edit Items" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::EditListItems
                    }
                    "Delete Items" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::DeleteListItems
                    }
                    "View Items" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ViewListItems
                    }
                    "Approve Items" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ApproveItems
                    }
                    "Open Items" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::OpenItems
                    }
                    "View Versions" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ViewVersions
                    }
                    "Delete Versions" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::DeleteVersions
                    }
                    "Create Alerts" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::CreateAlerts
                    }
                    "View Application Pages" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ViewFormPages
                    }
                }
            }

            foreach ($sp in $params.SitePermissions) 
            {
                switch ($sp) 
                {
                    "Manage Permissions" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ManagePermissions
                    }
                    "View Web Analytics Data" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ViewUsageData
                    }
                    "Create Subsites" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ManageSubwebs
                    }
                    "Manage Web Site" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ManageWeb
                    }
                    "Add and Customize Pages" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::AddAndCustomizePages
                    }
                    "Apply Themes and Borders" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ApplyThemeAndBorder
                    }
                    "Apply Style Sheets" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ApplyStyleSheets
                    }
                    "Create Groups" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::CreateGroups
                    }
                    "Browse Directories" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::BrowseDirectories
                    }
                    "Use Self-Service Site Creation" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::CreateSSCSite
                    }
                    "View Pages" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ViewPages
                    }
                    "Enumerate Permissions" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::EnumeratePermissions
                    }
                    "Browse User Information" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::BrowseUserInfo
                    }
                    "Manage Alerts" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ManageAlerts
                    }
                    "Use Remote Interfaces" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::UseRemoteAPIs
                    }
                    "Use Client Integration Features" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::UseClientIntegration
                    }
                    "Open" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::Open
                    }
                    "Edit Personal User Information" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::EditMyUserInfo
                    }
                }
            }

            foreach ($pp in $params.PersonalPermissions) 
            {
                switch ($pp) 
                {
                    "Manage Personal Views" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::ManagePersonalViews
                    }
                    "Add/Remove Personal Web Parts" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::AddDelPrivateWebParts
                    }
                    "Update Personal Web Parts" {
                        $newMask = $newMask -bor [Microsoft.SharePoint.SPBasePermissions]::UpdatePersonalWebParts
                    }
                }
            }
            $wa.RightsMask = $newMask
            $wa.Update()
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
        [ValidateSet("Manage Lists", "Override List Behaviors", "Add Items", "Edit Items",
                     "Delete Items", "View Items", "Approve Items", "Open Items", 
                     "View Versions", "Delete Versions", "Create Alerts", 
                     "View Application Pages")] 
        [System.String[]] 
        $ListPermissions,
        
        [Parameter()] 
        [ValidateSet("Manage Permissions", "View Web Analytics Data", "Create Subsites",
                     "Manage Web Site", "Add and Customize Pages", "Apply Themes and Borders",
                     "Apply Style Sheets", "Create Groups", "Browse Directories", 
                     "Use Self-Service Site Creation", "View Pages", "Enumerate Permissions",
                     "Browse User Information", "Manage Alerts", "Use Remote Interfaces", 
                     "Use Client Integration Features", "Open", "Edit Personal User Information")]
        [System.String[]] 
        $SitePermissions,
        
        [Parameter()]
        [ValidateSet("Manage Personal Views", "Add/Remove Personal Web Parts", 
                     "Update Personal Web Parts")] 
        [System.String[]] 
        $PersonalPermissions,
        
        [Parameter()] 
        [System.Boolean] 
        $AllPermissions,
        
        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing permissions for Web Application '$WebAppUrl'"

    Test-SPDSCInput @PSBoundParameters

    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    if ($AllPermissions -eq $true) 
    {
        if ($CurrentValues.ContainsKey("AllPermissions")) 
        {
            return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                            -DesiredValues $PSBoundParameters `
                                            -ValuesToCheck @("AllPermissions")
        } 
        else 
        {
            return $false
        }    
    } 
    else 
    {
        if ($CurrentValues.ContainsKey("AllPermissions")) 
        {
            return $false
        } 
        else 
        {
            if ($null -ne (Compare-Object -ReferenceObject $ListPermissions `
                                          -DifferenceObject $CurrentValues.ListPermissions)) 
            {
                return $false 
            }
            if ($null -ne (Compare-Object -ReferenceObject $SitePermissions `
                                          -DifferenceObject $CurrentValues.SitePermissions)) 
            {
                return $false 
            }
            if ($null -ne (Compare-Object -ReferenceObject $PersonalPermissions `
                                          -DifferenceObject $CurrentValues.PersonalPermissions)) 
            {
                return $false 
            }
            return $true
        }    
    }
}

function Test-SPDSCInput() 
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $WebAppUrl,

        [Parameter()] 
        [ValidateSet("Manage Lists", "Override List Behaviors", "Add Items", "Edit Items",
                     "Delete Items", "View Items", "Approve Items", "Open Items", 
                     "View Versions", "Delete Versions", "Create Alerts", 
                     "View Application Pages")] 
        [System.String[]] 
        $ListPermissions,
        
        [Parameter()] 
        [ValidateSet("Manage Permissions", "View Web Analytics Data", "Create Subsites",
                     "Manage Web Site", "Add and Customize Pages", "Apply Themes and Borders",
                     "Apply Style Sheets", "Create Groups", "Browse Directories", 
                     "Use Self-Service Site Creation", "View Pages", "Enumerate Permissions",
                     "Browse User Information", "Manage Alerts", "Use Remote Interfaces", 
                     "Use Client Integration Features", "Open", "Edit Personal User Information")]
        [System.String[]] 
        $SitePermissions,
        
        [Parameter()]
        [ValidateSet("Manage Personal Views", "Add/Remove Personal Web Parts", 
                     "Update Personal Web Parts")] 
        [System.String[]] 
        $PersonalPermissions,
        
        [Parameter()] 
        [System.Boolean] 
        $AllPermissions,
        
        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    if ($AllPermissions) 
    {
        # AllPermissions parameter specified with and one of the other parameters 
        if ($ListPermissions -or $SitePermissions -or $PersonalPermissions) 
        {
            throw ("Do not specify parameters ListPermissions, SitePermissions " + `
                   "or PersonalPermissions when specifying parameter AllPermissions")
        }
    } 
    else 
    {
        # You have to specify all three parameters 
        if (-not ($ListPermissions -and $SitePermissions -and $PersonalPermissions)) 
        {
            throw ("One of the parameters ListPermissions, SitePermissions or " + `
                   "PersonalPermissions is missing")
        }
    }

    #Checks
    if ($ListPermissions -contains "Approve Items" -and -not ($ListPermissions -contains "Edit Items")) 
    {
        throw "Edit Items is required when specifying Approve Items"
    }
    
    if (($ListPermissions -contains "Manage Lists" `
         -or $ListPermissions -contains "Override List Behaviors" `
         -or $ListPermissions -contains "Add Items" `
         -or $ListPermissions -contains "Edit Items" `
         -or $ListPermissions -contains "Delete Items" `
         -or $ListPermissions -contains "Approve Items" `
         -or $ListPermissions -contains "Open Items" `
         -or $ListPermissions -contains "View Versions" `
         -or $ListPermissions -contains "Delete Versions" `
         -or $ListPermissions -contains "Create Alerts" `
         -or $SitePermissions -contains "Manage Permissions" `
         -or $SitePermissions -contains "Manage Web Site" `
         -or $SitePermissions -contains "Add and Customize Pages" `
         -or $SitePermissions -contains "Manage Alerts" `
         -or $SitePermissions -contains "Use Client Integration Features" `
         -or $PersonalPermissions -contains "Manage Personal Views" `
         -or $PersonalPermissions -contains "Add/Remove Personal Web Parts" `
         -or $PersonalPermissions -contains "Update Personal Web Parts") `
       -and -not ($ListPermissions -contains "View Items")) 
    {
        throw ("View Items is required when specifying Manage Lists, Override List Behaviors, " + `
               "Add Items, Edit Items, Delete Items, Approve Items, Open Items, View " + `
               "Versions, Delete Versions, Create Alerts, Manage Permissions, Manage Web Site, " + `
               "Add and Customize Pages, Manage Alerts, Use Client Integration Features, " + `
               "Manage Personal Views, Add/Remove Personal Web Parts or Update Personal Web Parts")
    }

    if (($ListPermissions -contains "View Versions" `
            -or $SitePermissions -contains "Manage Permissions") `
        -and -not ($ListPermissions -contains "Open Items")) 
    {
        throw "Open Items is required when specifying View Versions or Manage Permissions"
    }    
    
    if (($ListPermissions -contains "Delete Versions" `
            -or $SitePermissions -contains "Manage Permissions") `
        -and -not ($ListPermissions -contains "View Versions")) 
    {
        throw "View Versions is required when specifying Delete Versions or Manage Permissions"
    }    
    
    if ($SitePermissions -contains "Manage Alerts" `
        -and -not ($ListPermissions -contains "Create Alerts")) 
    {
        throw "Create Alerts is required when specifying Manage Alerts"
    }    

    if ($SitePermissions -contains "Manage Web Site" `
        -and -not ($SitePermissions -contains "Add and Customize Pages")) 
    {
        throw "Add and Customize Pages is required when specifying Manage Web Site"
    }    
    
    if (($SitePermissions -contains "Manage Permissions" `
            -or $SitePermissions -contains "Manage Web Site" `
            -or $SitePermissions -contains "Add and Customize Pages" `
            -or $SitePermissions -contains "Enumerate Permissions") `
        -and -not ($SitePermissions -contains "Browse Directories")) 
    {
        throw ("Browse Directories is required when specifying Manage Permissions, Manage Web " + `
               "Site, Add and Customize Pages or Enumerate Permissions")
    }    

    if (($ListPermissions -contains "Manage Lists" `
         -or $ListPermissions -contains "Override List Behaviors" `
         -or $ListPermissions -contains "Add Items" `
         -or $ListPermissions -contains "Edit Items" `
         -or $ListPermissions -contains "Delete Items" `
         -or $ListPermissions -contains "View Items" `
         -or $ListPermissions -contains "Approve Items" `
         -or $ListPermissions -contains "Open Items" `
         -or $ListPermissions -contains "View Versions" `
         -or $ListPermissions -contains "Delete Versions" `
         -or $ListPermissions -contains "Create Alerts" `
         -or $SitePermissions -contains "Manage Permissions" `
         -or $SitePermissions -contains "View Web Analytics Data" `
         -or $SitePermissions -contains "Create Subsites" `
         -or $SitePermissions -contains "Manage Web Site" `
         -or $SitePermissions -contains "Add and Customize Pages" `
         -or $SitePermissions -contains "Apply Themes and Borders" `
         -or $SitePermissions -contains "Apply Style Sheets" `
         -or $SitePermissions -contains "Create Groups" `
         -or $SitePermissions -contains "Browse Directories" `
         -or $SitePermissions -contains "Use Self-Service Site Creation" `
         -or $SitePermissions -contains "Enumerate Permissions" `
         -or $SitePermissions -contains "Manage Alerts" `
         -or $PersonalPermissions -contains "Manage Personal Views" `
         -or $PersonalPermissions -contains "Add/Remove Personal Web Parts" `
         -or $PersonalPermissions -contains "Update Personal Web Parts") `
       -and -not ($SitePermissions -contains "View Pages")) 
    {
        throw ("View Pages is required when specifying Manage Lists, Override List Behaviors, " + `
               "Add Items, Edit Items, Delete Items, View Items, Approve Items, Open Items, " + `
               "View Versions, Delete Versions, Create Alerts, Manage Permissions, View Web " + `
               "Analytics Data, Create Subsites, Manage Web Site, Add and Customize Pages, " + `
               "Apply Themes and Borders, Apply Style Sheets, Create Groups, Browse " + `
               "Directories, Use Self-Service Site Creation, Enumerate Permissions, Manage " + `
               "Alerts, Manage Personal Views, Add/Remove Personal Web Parts or Update " + `
               "Personal Web Parts")
    }

    if (($SitePermissions -contains "Manage Permissions" `
            -or $SitePermissions -contains "Manage Web Site") `
        -and -not ($SitePermissions -contains "Enumerate Permissions")) 
    {
        throw ("Enumerate Permissions is required when specifying Manage Permissions or " + `
               "Manage Web Site")
    }    

    if (($SitePermissions -contains "Manage Permissions" `
         -or $SitePermissions -contains "Create Subsites" `
         -or $SitePermissions -contains "Manage Web Site" `
         -or $SitePermissions -contains "Create Groups" `
         -or $SitePermissions -contains "Use Self-Service Site Creation" `
         -or $SitePermissions -contains "Enumerate Permissions" `
         -or $SitePermissions -contains "Edit Personal User Information") `
       -and -not ($SitePermissions -contains "Browse User Information")) 
    {
        throw ("Browse User Information is required when specifying Manage Permissions, " + `
               "Create Subsites, Manage Web Site, Create Groups, Use Self-Service Site " + `
               "Creation, Enumerate Permissions or Edit Personal User Information")
    }

    if ($SitePermissions -contains "Use Client Integration Features" `
        -and -not ($SitePermissions -contains "Use Remote Interfaces")) 
    {
        throw "Use Remote Interfaces is required when specifying Use Client Integration Features"
    }

    if (($ListPermissions -contains "Manage Lists" `
         -or $ListPermissions -contains "Override List Behaviors" `
         -or $ListPermissions -contains "Add Items" `
         -or $ListPermissions -contains "Edit Items" `
         -or $ListPermissions -contains "Delete Items" `
         -or $ListPermissions -contains "View Items" `
         -or $ListPermissions -contains "Approve Items" `
         -or $ListPermissions -contains "Open Items" `
         -or $ListPermissions -contains "View Versions" `
         -or $ListPermissions -contains "Delete Versions" `
         -or $ListPermissions -contains "Create Alerts" `
         -or $ListPermissions -contains "View Application Pages" `
         -or $SitePermissions -contains "Manage Permissions" `
         -or $SitePermissions -contains "View Web Analytics Data" `
         -or $SitePermissions -contains "Create Subsites" `
         -or $SitePermissions -contains "Manage Web Site" `
         -or $SitePermissions -contains "Add and Customize Pages" `
         -or $SitePermissions -contains "Apply Themes and Borders" `
         -or $SitePermissions -contains "Apply Style Sheets" `
         -or $SitePermissions -contains "Create Groups" `
         -or $SitePermissions -contains "Browse Directories" `
         -or $SitePermissions -contains "Use Self-Service Site Creation" `
         -or $SitePermissions -contains "View Pages" `
         -or $SitePermissions -contains "Enumerate Permissions" `
         -or $SitePermissions -contains "Browse User Information" `
         -or $SitePermissions -contains "Manage Alerts" `
         -or $SitePermissions -contains "Use Remote Interfaces" `
         -or $SitePermissions -contains "Use Client Integration Features" `
         -or $SitePermissions -contains "Edit Personal User Information" `
         -or $PersonalPermissions -contains "Manage Personal Views" `
         -or $PersonalPermissions -contains "Add/Remove Personal Web Parts" `
         -or $PersonalPermissions -contains "Update Personal Web Parts") `
       -and -not ($SitePermissions -contains "Open")) 
    {
        throw "Open is required when specifying any of the other permissions"
    }

    if ($PersonalPermissions -contains "Add/Remove Personal Web Parts" `
        -and -not ($PersonalPermissions -contains "Update Personal Web Parts")) 
    {
        throw "Update Personal Web Parts is required when specifying Add/Remove Personal Web Parts"
    }
}

Export-ModuleMember -Function *-TargetResource
