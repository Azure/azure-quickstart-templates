# Configure FHIR service to enable $import

This template will allow you to toggle the `[$import operation](https://docs.microsoft.com/azure/healthcare-apis/fhir/import-data)` on a FHIR service inside a Azure Health Data Services workspace. 

## Deployment via portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmikaelweave%2Fazure-health-scripts%2Fmain%2Ffhir-import-toggle%2Ftoggle_import.json)

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