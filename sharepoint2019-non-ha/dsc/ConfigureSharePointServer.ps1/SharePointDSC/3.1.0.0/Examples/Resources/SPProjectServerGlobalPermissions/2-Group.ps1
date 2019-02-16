<#
.EXAMPLE
    This example shows how to set permissions for a specific group that exists in a PWA site
#>

Configuration Example 
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $SetupAccount
    )
    Import-DscResource -ModuleName SharePointDsc

    node localhost 
    {
        SPProjectServerGlobalPermissions Permissions
        {
            Url = "http://projects.contoso.com"
            EntityName = "Group Name"
            EntityType = "Group"
            AllowPermissions = @(
                "LogOn",
                "NewTaskAssignment",
                "AccessProjectDataService",
                "ReassignTask",
                "ManagePortfolioAnalyses",
                "ManageUsersAndGroups",
                "ManageWorkflow",
                "ManageCheckIns",
                "ManageGanttChartAndGroupingFormats",
                "ManageEnterpriseCustomFields",
                "ManageSecurity",
                "ManageEnterpriseCalendars",
                "ManageCubeBuildingService",
                "CleanupProjectServerDatabase",
                "SaveEnterpriseGlobal",
                "ManageWindowsSharePointServices",
                "ManagePrioritizations",
                "ManageViews",
                "ContributeToProjectWebAccess",
                "ManageQueue",
                "LogOnToProjectServerFromProjectProfessional",
                "ManageDrivers",
                "ManagePersonalNotifications",
                "ManageServerConfiguration",
                "ChangeWorkflow",
                "ManageActiveDirectorySettings",
                "ManageServerEvents",
                "ManageSiteWideExchangeSync",
                "ManageListsInProjectWebAccess"
            )
            DenyPermissions = @(
                "NewProject"
            )
            PSDscRunAsCredential = $SetupAccount
        }
    }
}
