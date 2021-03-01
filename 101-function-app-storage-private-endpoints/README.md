# Function App with Azure Storage private endpoints

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-function-app-storage-private-endpoints/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-function-app-storage-private-endpoints/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-function-app-storage-private-endpoints/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-function-app-storage-private-endpoints/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-function-app-storage-private-endpoints%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-function-app-storage-private-endpoints%2Fazuredeploy.json)

This sample Azure Resource Manager template deploys an Azure Function App that communicates with the Azure Storage account referenced by the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) and [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) app settings, [via private endpoints](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#private-endpoints). 

![Function App with Storage Private Endpoints](/images/function-app-storage-privateendponts.png) 

### Azure Function App

The Function App uses the AzureWebJobsStorage and WEBSITE_CONTENTAZUREFILECONNECTIONSTRING app settings to connect to a private endpoint-secured Storage Account.

### Elastic Premium Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Elastic Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan#features). 

If you don't execute the optional inline deployment script, specify the plan size that you want in the "initialplansize" parameter, and you can ignore the "finalplansize" parameter. Otherwise, set "initialplansize" to a value that is different from the size you want the plan to use.

### Azure Storage account

The Storage account that the Function uses for operation and for file contents. 


### Virtual Network

Azure resources in this sample either integrate with or are placed within a virtual network. The use of private endpoints keeps network traffic contained with the virtual network.

The sample uses two subnets:

- Subnet for Azure Function virtual network integration.  This subnet is delegated to the Function App.
- Subnet for private endpoints.  Private IP addresses are allocated from this subnet.

### Private Endpoints

[Azure Private Endpoints](https://docs.microsoft.com/azure/private-link/private-endpoint-overview) are used to connect to specific Azure resources using a private IP address  This ensures that network traffic remains within the designated virtual network, and access is available only for specific resources.  This sample configures private endpoints for the following Azure resources:

- [Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-private-endpoints)
  - Azure File storage
  - Azure Blob storage
  - Azure Queue storage
  - Azure Table storage
  
### Private DNS Zones

Using a private endpoint to connect to Azure resources means connecting to a private IP address instead of the public endpoint.  Existing Azure services are configured to use existing DNS to connect to the public endpoint.  The DNS configuration will need to be overridden to connect to the private endpoint.

A private DNS zone will be created for each Azure resource configured with a private endpoint.  A DNS A record is created for each private IP address associated with the private endpoint. 

The following DNS zones are created in this sample:

- privatelink.queue.core.windows.net
- privatelink.blob.core.windows.net
- privatelink.table.core.windows.net
- privatelink.file.core.windows.net

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

### Optional in-line deployment script

After the first time you configure the Function App to talk to the private endpoint-enabled Storage account, you may need to vertically scale the Plan and connect to the file system via Kudu (eg by performing a content deployment or by making a GET request to the Kudu /DebugConsole) to refresh the SMB connection so that the Function App can successfully retrieve the contents from the Storage account. The optional deployment script in this template automates these steps.

The script will change the size of the plan, and then retrieve the site-level credentials from the publish profile and make an authenticated request to the Kudu /Debugconsole page of the Function App.

#### Prerequisites to run the in-line deployment script

You will need a user-assigned managed identity to run the script because the script performs actions upon a Azure resources, 

The principal that is used to deploy the ARM template will need Managed Identity Operator permissions in order to use the managed identity. The deployment principal will also need the permissions described in [this document]. If you are using a deployment principal is assigned the Contributor role to the resource group, then the principal would already have these permissions and you shouldn't need to assign the Managed Identity Operator role or create a custom role for these actions. By default, the template assumes that the principal is a Contributor and does not assign permissions to the principal.

The prereqs template does the following:
- Creates a user-assigned managed identity.
- Creates a custom role with the necessary permissions to perform operations on Function Apps and App Service Plans and assigns this role to the managed identity. By default, the role is created and assigned in the scope of the resource group.
- If the isContributor parameter is set to false: creates a custom role with the necessary permissions to run the deployment script and assigns this role to the deployment principal. By default, the role is created and assigned in the scope of the resource group.
- If the isContributor parameter is set to false: Assigns the deployment principal as a Managed Identity Operator to the managed identity.

In order to run the prereq template, you must have Owner permissions in the scope that you are assigning roles in. For example, if using the default scope of resource group, you must have Owner permissions on the resource group.

You will also need to provide the object id of an existing deployment principal, as well as the user-assigned managed identity name.
Note: The object id of a service principal is different from the object id of the AAD App registration. 
You can get the object id of a service principal via [PowerShell](https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadserviceprincipal?view=azureadps-2.0#example-2--retrieve-a-service-principal-by-id
) or [CLI](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az_ad_sp_show-examples).

#### Using the deployment script in the main template

To execute the inline deployment script in the main template:
- For the postDeploymentScript parameter, specify either "azpowershell" or "azcli" depending on which modules your deployment environment has. If you leave the value as "none", the inline deployment script won't get executed.
- For the "userIdentity" and "userIdentityResourceGroup" parameters, specify values that correpond to an existing User Managed Identity that has the necessary permissions described [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template#configure-the-minimum-permissions).
- Specify the plan size that you want in the "finalplansize" parameter, and specify a different plan size in the "initialplansize" parameter. For example, if you want the plan size to be EP1, specify "EP2" for the "initialplansize" parameter and specify "EP1" for the "finalplansize" parameter. This way, 
