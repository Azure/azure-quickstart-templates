# A common architecture deployed with Bicep

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-managed-identity-sql-db/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-managed-identity-sql-db%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-managed-identity-sql-db%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-managed-identity-sql-db%2Fazuredeploy.json)

A common architecture for Azure customers is Web App + Data + Managed Identity + Monitoring.

**How easy it to deploy this with Bicep?**
1. [Install Bicep CLI and VS Code extension](https://github.com/Azure/bicep/blob/main/docs/installing.md)
2. Use example from [main.bicep](main.bicep)
3. Arrange/re-order, update variables and params to your preference
4. Use the Bicep CLI to run Bicep Build command: ``` Bicep Build ./main.bicep ``` to generate ARM Template (main._json_)
5. Disregard the warning :warning:: ``` Warning BCP081: Resource type "Microsoft.Web/sites/config@2020-06-01" does not have types available. ```
   Issue being tracked here: https://github.com/Azure/bicep/issues/657
6. Create a resource group to deploy to using Azure CLI: ``` az group create --name YOURRESOURCEGROUPNAME --location centralus ```
7. Deploy ARM template (main.json) to resource group above, using Azure CLI: ``` az deployment group create -f ./main.json -g YOURRESOURCEGROUPNAME ```
8.  Enter parameters values for sqlAdministratorLogin, sqlAdministratorPassword, and managedIdentityName at command line.
9.  Wait for deployment to complete
10. Deployment complete!

Diagram of resources that are deployed:
![diagram](images/commonArchDiagram.PNG)

TODO: Clean up README

