# Configure FHIR service to enable $import

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/fhir-import/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/fhir-import/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/fhir-import/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/fhir-import/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/fhir-import/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/fhir-import/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Ffhir-import%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Ffhir-import%2Fazuredeploy.json)

This template will allow you to toggle the `[$import operation](https://docs.microsoft.com/azure/healthcare-apis/fhir/import-data)` on a FHIR service inside a Azure Health Data Services workspace. 


### Template Input Parameters


| Parameter | Required | Description |
| --- | --- | --- |
| workspaceName | Yes | The name of the Azure Health Data Services workspace containing the FHIR service to toggle import. |
| fhirName | Yes | The name of the FHIR service to toggle import. |
| storageName | Maybe | The name of the storage account to pull data from for import. This is required for enabling import but not disabling. The storage account must exist. |
| enableImport | Yes | `true` to enable import and `false` to disable import. |

## Deployment via azure cli

You can deploy the Bicep template directly with this azure cli command.

```sh
az deployment group create \
    --name main \
    --resource-group "rg-name" \
    --template-file "toggle_import.bicep" \
    --parameters workspaceName="ahds-workspace-name" \
    --parameters fhirName="fhir-service-name" \
    --parameters storageName="storage-account-name" \
    --parameters enableImport=true \
    --output table
```
