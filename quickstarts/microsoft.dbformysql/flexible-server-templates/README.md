# arm-templates

This repo contains ARM template samples for Azure Database for MySQL - Flexible Server.

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
