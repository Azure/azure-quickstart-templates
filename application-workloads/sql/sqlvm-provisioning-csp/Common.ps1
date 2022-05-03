function SetupAzureResourceManagementSubscription
{
    #<#
    #.Synopsis
    #	The function signs to Azure and setup Azure subscription 
    #       for ARM development by enabling ARM cmdlets. 
    #.Description
    #	The function should be called before executing any scripts. 
    #       SubscriptionName is the name of the subscription to use. If the name has space
    #       you need to srround it with white space. 
    #.Parameter SubscriptionId
    #       SubscriptionId is Azure subscription identifier of the subscription to use.
    ##>
    param
    (
      [Parameter(Mandatory)]
      [string]$SubscriptionId
    )

    Add-AzureAccount

    Write-Host 'Selecting Azure Subscription...' $SubscriptionId -foregroundcolor Yellow
    Select-AzureSubscription -SubscriptionId $SubscriptionId


    Write-Host 'Enabling Azure Resource Manager API...' -foregroundcolor Yellow
    Switch-AzureMode AzureResourceManager
    Write-Host 'Azure ARM API enabled.' -foregroundcolor Yellow
}

