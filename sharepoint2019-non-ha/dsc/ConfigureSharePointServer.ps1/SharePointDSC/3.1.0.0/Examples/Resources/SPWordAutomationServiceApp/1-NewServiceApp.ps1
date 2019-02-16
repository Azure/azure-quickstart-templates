<#
.EXAMPLE
    This example makes sure the service application exists and has a specific configuration
#>

    Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPWordAutomationServiceApp WordAutomation 
            {
                Name = "Word Automation Service Application" 
                Ensure = "Present"
                ApplicationPool = "SharePoint Web Services"
                DatabaseName = "WordAutomation_DB"
                DatabaseServer = "SQLServer"
                SupportedFileFormats = "docx", "doc", "mht", "rtf", "xml"
                DisableEmbeddedFonts = $false
                MaximumMemoryUsage = 100
                RecycleThreshold = 100
                DisableBinaryFileScan = $false
                ConversionProcesses = 8
                JobConversionFrequency = 15
                NumberOfConversionsPerProcess = 12
                TimeBeforeConversionIsMonitored = 5
                MaximumConversionAttempts = 2
                MaximumSyncConversionRequests = 25 
                KeepAliveTimeout = 30
                MaximumConversionTime = 300
                PsDscRunAsCredential = $SetupAccount 
            } 
        }
    }
