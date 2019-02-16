<#
.EXAMPLE
    This example applies settings to disable SharePoint Designer access to the
    specified web application.
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
            SPDesignerSettings MainWebAppSPDSettings
            {
                WebAppUrl                               = "https://intranet.sharepoint.contoso.com"
                SettingsScope                           = "WebApplication"
                AllowSharePointDesigner                 = $false
                AllowDetachPagesFromDefinition          = $false
                AllowCustomiseMasterPage                = $false
                AllowManageSiteURLStructure             = $false
                AllowCreateDeclarativeWorkflow          = $false
                AllowSavePublishDeclarativeWorkflow     = $false
                AllowSaveDeclarativeWorkflowAsTemplate  = $false
                PsDscRunAsCredential                    = $SetupAccount
            }
        }
    }
