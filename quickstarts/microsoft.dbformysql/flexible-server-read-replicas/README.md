# Deploy Azure Database for MySQL - Flexible Server and 1 to 10 Read Replicas

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.dbformysql/flexible-server/read-replicas/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dbformysql%2Fflexible-server%2Fread-replicas%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dbformysql%2Fflexible-server%2Fread-replicas%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.dbformysql%2Fflexible-server%2Fread-replicas%2Fazuredeploy.json)

This template creates a Azure Database for MySQL - Flexible Server, and provisions 1 to 10 read replicas.

## Deploying the template

1. Update the parameters.json file by replacing the parameter values with your own.

1. Deploy the templates from Azure Powershell, Azure CLI or through the Azure portal.

    Deploy the templates from Azure Powershell using the below block of code.

    ```azurepowershell-interactive
    $resourceGroupName = <sample-rg-name>
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
        -TemplateFile "<your path to template.json file>" `
        -TemplateParameterFile "<your path to parameters.json file>"
    ```

    Alternatively, deploy the templates from Azure CLI using the below block of code.

    ```azurecli-interactive
    az deployment group create \
      --name mysql-deployment \
      --resource-group sample-rg-name \
      --template-file <your path to template.json file> \
      --parameters '@<your path to parameters.json file>'
    ```
