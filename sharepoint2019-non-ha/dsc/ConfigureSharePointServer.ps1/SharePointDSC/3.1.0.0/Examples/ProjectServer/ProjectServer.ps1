Configuration Example
{
    param (
        [Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $FarmAccount,
        [Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $SPSetupAccount,
        [Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $WebPoolManagedAccount,
        [Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $ServicePoolManagedAccount,
        [Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $Passphrase
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc

    node "localhost"
    {
        #**********************************************************
        # Install Binaries
        #
        # This section installs SharePoint and its Prerequisites
        #**********************************************************

        SPInstallPrereqs InstallPrereqs
        {
            IsSingleInstance  = "Yes"
            Ensure            = "Present"
            InstallerPath     = "C:\binaries\prerequisiteinstaller.exe"
            OnlineMode        = $true
        }

        SPInstall InstallSharePoint
        {
            IsSingleInstance  = "Yes"
            Ensure            = "Present"
            BinaryDir         = "C:\binaries\"
            ProductKey        = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
            DependsOn         = "[SPInstallPrereqs]InstallPrereqs"
        }

        #**********************************************************
        # Basic farm configuration
        #
        # This section creates the new SharePoint farm object, and
        # provisions generic services and components used by the
        # whole farm
        #**********************************************************
        SPFarm CreateSPFarm
        {
            IsSingleInstance         = "Yes"
            Ensure                   = "Present"
            DatabaseServer           = "sql.contoso.com"
            FarmConfigDatabaseName   = "SP_Config"
            Passphrase               = $Passphrase
            FarmAccount              = $FarmAccount
            PsDscRunAsCredential     = $SPSetupAccount
            AdminContentDatabaseName = "SP_AdminContent"
            RunCentralAdmin          = $true
            DependsOn                = "[SPInstall]InstallSharePoint"
        }

        SPManagedAccount ServicePoolManagedAccount
        {
            AccountName          = $ServicePoolManagedAccount.UserName
            Account              = $ServicePoolManagedAccount
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }
        SPManagedAccount WebPoolManagedAccount
        {
            AccountName          = $WebPoolManagedAccount.UserName
            Account              = $WebPoolManagedAccount
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }
        SPDiagnosticLoggingSettings ApplyDiagnosticLogSettings
        {
            IsSingleInstance                            = "Yes"
            PsDscRunAsCredential                        = $SPSetupAccount
            LogPath                                     = "C:\ULS"
            LogSpaceInGB                                = 5
            AppAnalyticsAutomaticUploadEnabled          = $false
            CustomerExperienceImprovementProgramEnabled = $true
            DaysToKeepLogs                              = 7
            DownloadErrorReportingUpdatesEnabled        = $false
            ErrorReportingAutomaticUploadEnabled        = $false
            ErrorReportingEnabled                       = $false
            EventLogFloodProtectionEnabled              = $true
            EventLogFloodProtectionNotifyInterval       = 5
            EventLogFloodProtectionQuietPeriod          = 2
            EventLogFloodProtectionThreshold            = 5
            EventLogFloodProtectionTriggerPeriod        = 2
            LogCutInterval                              = 15
            LogMaxDiskSpaceUsageEnabled                 = $true
            ScriptErrorReportingDelay                   = 30
            ScriptErrorReportingEnabled                 = $true
            ScriptErrorReportingRequireAuth             = $true
            DependsOn                                   = "[SPFarm]CreateSPFarm"
        }
        SPUsageApplication UsageApplication
        {
            Name                  = "Usage Service Application"
            DatabaseName          = "SP_Usage"
            UsageLogCutTime       = 5
            UsageLogLocation      = "C:\UsageLogs"
            UsageLogMaxFileSizeKB = 1024
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = "[SPFarm]CreateSPFarm"
        }
        SPStateServiceApp StateServiceApp
        {
            Name                 = "State Service Application"
            DatabaseName         = "SP_State"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }
        SPDistributedCacheService EnableDistributedCache
        {
            Name                 = "AppFabricCachingService"
            Ensure               = "Present"
            CacheSizeInMB        = 1024
            ServiceAccount       = $ServicePoolManagedAccount.UserName
            PsDscRunAsCredential = $SPSetupAccount
            CreateFirewallRules  = $true
            DependsOn            = @('[SPFarm]CreateSPFarm','[SPManagedAccount]ServicePoolManagedAccount')
        }

        #**********************************************************
        # Web applications
        #
        # This section creates the web applications in the
        # SharePoint farm, as well as managed paths and other web
        # application settings
        #**********************************************************

        SPWebApplication SharePointSites
        {
            Name                   = "SharePoint Sites"
            ApplicationPool        = "SharePoint Sites"
            ApplicationPoolAccount = $WebPoolManagedAccount.UserName
            AllowAnonymous         = $false
            DatabaseName           = "SP_Content"
            WebAppUrl              = "http://sites.contoso.com"
            HostHeader             = "sites.contoso.com"
            Port                   = 80
            PsDscRunAsCredential   = $SPSetupAccount
            DependsOn              = "[SPManagedAccount]WebPoolManagedAccount"
        }

        SPCacheAccounts WebAppCacheAccounts
        {
            WebAppUrl              = "http://sites.contoso.com"
            SuperUserAlias         = "CONTOSO\SP_SuperUser"
            SuperReaderAlias       = "CONTOSO\SP_SuperReader"
            PsDscRunAsCredential   = $SPSetupAccount
            DependsOn              = "[SPWebApplication]SharePointSites"
        }

        SPSite TeamSite
        {
            Url                      = "http://sites.contoso.com"
            OwnerAlias               = "CONTOSO\SP_Admin"
            Name                     = "DSC Demo Site"
            Template                 = "STS#0"
            PsDscRunAsCredential     = $SPSetupAccount
            DependsOn                = "[SPWebApplication]SharePointSites"
        }


        #**********************************************************
        # Service instances
        #
        # This section describes which services should be running
        # and not running on the server
        #**********************************************************

        SPServiceInstance ClaimsToWindowsTokenServiceInstance
        {
            Name                 = "Claims to Windows Token Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance SecureStoreServiceInstance
        {
            Name                 = "Secure Store Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance ManagedMetadataServiceInstance
        {
            Name                 = "Managed Metadata Web Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance BCSServiceInstance
        {
            Name                 = "Business Data Connectivity Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance SearchServiceInstance
        {
            Name                 = "SharePoint Server Search"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        #**********************************************************
        # Service applications
        #
        # This section creates service applications and required
        # dependencies
        #**********************************************************

        $serviceAppPoolName = "SharePoint Service Applications"
        SPServiceAppPool MainServiceAppPool
        {
            Name                 = $serviceAppPoolName
            ServiceAccount       = $ServicePoolManagedAccount.UserName
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPSecureStoreServiceApp SecureStoreServiceApp
        {
            Name                  = "Secure Store Service Application"
            ApplicationPool       = $serviceAppPoolName
            AuditingEnabled       = $true
            AuditlogMaxSize       = 30
            DatabaseName          = "SP_SecureStore"
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = "[SPServiceAppPool]MainServiceAppPool"
        }

        SPManagedMetaDataServiceApp ManagedMetadataServiceApp
        {
            Name                 = "Managed Metadata Service Application"
            PsDscRunAsCredential = $SPSetupAccount
            ApplicationPool      = $serviceAppPoolName
            DatabaseName         = "SP_MMS"
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool"
        }

        SPBCSServiceApp BCSServiceApp
        {
            Name                  = "BCS Service Application"
            ApplicationPool       = $serviceAppPoolName
            DatabaseName          = "SP_BCS"
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = @('[SPServiceAppPool]MainServiceAppPool', '[SPSecureStoreServiceApp]SecureStoreServiceApp')
        }

        SPSearchServiceApp SearchServiceApp
        {
            Name                  = "Search Service Application"
            DatabaseName          = "SP_Search"
            ApplicationPool       = $serviceAppPoolName
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = "[SPServiceAppPool]MainServiceAppPool"
        }


        #**********************************************************
        # Project Server Configuration
        #
        # This section contains resoruces that are needed or can be
        # used in the configuration of Project Server 2016
        #**********************************************************

        SPProjectServerLicense PWALicense
        {
            IsSingleInstance     = "Yes"
            Ensure               = "Present"
            ProductKey           = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPManagedPath PWAPath
        {
            WebAppUrl            = "http://sites.contoso.com"
            RelativeUrl          = "PWA"
            Explicit             = $true
            HostHeader           = $false
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPWebApplication]SharePointSites"
        }

        SPProjectServerServiceApp PWAServiceApp
        {
            Name                 = "Project Server Service Application"
            ApplicationPool      = $serviceAppPoolName
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPProjectServerLicense]PWALicense"
        }

        SPSite PWASite
        {
            Url                      = "http://sites.contoso.com/pwa"
            OwnerAlias               = "CONTOSO\ExampleUser"
            Name                     = "PWA Site"
            Template                 = "PWA#0"
            PsDscRunAsCredential     = $SPSetupAccount
            DependsOn                = @("[SPManagedPath]PWAPath", "[SPProjectServerServiceApp]PWAServiceApp")
        }

        SPFeature PWASiteFeature
        {
            Name                 = "PWASITE"
            Url                  = "http://sites.contoso.com/pwa"
            FeatureScope         = "Site"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPSite]PWASite"
        }

        SPProjectServerPermissionMode PWAPermMode
        {
            Url                  = "http://sites.contoso.com/pwa"
            PermissionMode       = "ProjectServer"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFeature]PWASiteFeature"
        }

        SPProjectServerADResourcePoolSync PWAUserSync
        {
            Url                  = "http://sites.contoso.com/pwa"
            GroupNames           = @("CONTOSO\Project Managers", "CONTOSO\Project Members")
            AutoReactivateUsers  = $true
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFeature]PWASiteFeature"
        }

        SPTimerJobState RunProjectSeverADImport
        {
            TypeName                = "ActiveDirectorySync"
            WebAppUrl               = "N/A"
            Enabled                 = $true
            Schedule                = "daily between 03:00:00 and 03:00:00"
            PsDscRunAsCredential    = $SPSetupAccount
            DependsOn               = "[SPProjectServerADResourcePoolSync]PWAUserSync"
        }

        #**********************************************************
        # Local configuration manager settings
        #
        # This section contains settings for the LCM of the host
        # that this configuraiton is applied to
        #**********************************************************
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
    }
}
