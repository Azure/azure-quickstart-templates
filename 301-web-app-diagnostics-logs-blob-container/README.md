# Web App with diagnostics logging to Storage Account Blob Container

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-web-app-diagnostics-logs-blob-container/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-web-app-diagnostics-logs-blob-container/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-web-app-diagnostics-logs-blob-container/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-web-app-diagnostics-logs-blob-container/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-web-app-diagnostics-logs-blob-container/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-web-app-diagnostics-logs-blob-container/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-web-app-diagnostics-logs-blob-container%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-web-app-diagnostics-logs-blob-container%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a Web App with diagnostics logging to Storage Account Blob Container.

This template uses the `listAccountSas` function to retrieve Storage Account SAS and then connect Storage Account (and its blob container) with Web App ([ARM function reference](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource#listaccountsas-listkeys-listsecrets-and-list), [API endpoint reference](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/listaccountsas)). By using `listAccountSas` whole solution can be deployed in a single step - there is no need for getting and providing Storage Account SAS explicitly by the user.

`Tags: App Service, Web Application, Storage Account, Diagnostics Logs, Blob Container`

