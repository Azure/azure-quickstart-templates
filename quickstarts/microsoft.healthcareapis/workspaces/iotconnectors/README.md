# Deploy an instance of the Azure Health Data Services MedTech service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.healthcareapis/workspaces/iotconnectors/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.healthcareapis%2Fworkspaces%2Fiotconnectors%2Fazuredeploy.json)

This template deploys an instance of the Azure Health Data Services MedTech service.

## Sample overview and deployed resources

This template creates an instance of the Azure Health Data Services MedTech service. The MedTech service is an optional service of the Azure Health Data Services designed to ingest health data from multiple and disparate Internet of Medical Things (IoMT) devices and persist the health data in a Fast Healthcare Interoperable Resources (FHIR®) service within the Azure Health Data Services.

As a part of this solution, a MedTech service with the required resources and resource access permissions are created. The MedTech service will still require device and destination mapping files to be fully functional.

## Deployment steps

You can click the **Deploy to Azure** button at the beginning of this document to deploy an instance of the Azure API for FHIR®. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/healthcare-apis/fhir-paas-arm-template-quickstart?tabs=azure-portal) article.

During deployment, you can specify the service names and Azure region location (optional). By default, the deployment will use the region of the Resource Group that is select for the deployment as the default). All other parameters for deployment are automatically configured for you.
