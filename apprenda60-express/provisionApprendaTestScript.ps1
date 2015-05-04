# Provision_Apprenda_Single.ps1
# Author: Chris Dutra

# Note - you must have access to the v2 of the Azure powershell, please refer
# to the VirtualMachine Preview Dossier for more information.
# Otherwise, this won't work. 

param(
        $platformAdminFirstName = "Chris",
        $platformAdminLastName = "Dutra",
        $platformAdminEmailAddress = "chris@dutronlabs.com",
        $platformAdminPassword = "@ppm5205",
        $newStorageAccountName = "aprexpressstorage",
        $adminUsername = "clusteradmin",
        $adminPassword = "@ppm5205",
        $location = "West US",
        $storageAccountType = "Standard_GRS",
        $vmSize = "Standard_D2",
        $vmName = "aprexpress",
        $virtualNetworkName = "apprendavnet",
        $initialize = $false,
        $createGroup = $true
	)

    if($initialize)
    {
        # To load up azure vmm preview environment
        Switch-AzureMode AzureResourceManager
        Add-AzureAccount
        Get-AzureSubscription
        Select-AzureSubscription -SubscriptionName "Windows Azure MSDN - Visual Studio Ultimate" -Default
        Join-AzureCoreResourceProvider -All -Environment production
        Get-AzureLocation
    }

	$params = @{
          platformAdminFirstName=$platformAdminFirstName;`
          platformAdminLastName=$platformAdminLastName;`
          platformAdminEmailAddress=$platformAdminEmailAddress;`
          platformAdminPassword=$platformAdminPassword;`
          newStorageAccountName=$newStorageAccountName;`
          adminUserName=$adminUserName;`
          adminPassword=$adminPassword;`
          location=$location; `
          storageAccountType=$storageAccountType;`
          vmSize=$vmSize; `
          vmName=$vmName; `
          virtualNetworkName=$virtualNetworkName; `
          }

    $pathToJSON=".\azuredeploy.json"
    $resourceGroupName="apprendasmallclustertest"
    if($createGroup)
    {
	New-AzureResourceGroup -Name $resourceGroupName -Location $location
    } 
	New-AzureResourceGroupDeployment -Name $vmName -ResourceGroupName $resourceGroupName -TemplateFile $pathToJSON -TemplateParameterObject $params