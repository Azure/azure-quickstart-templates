---
description: This templates creates an alert rule and user assigned MSI. It also assigns the MSI reader access to the subscription so that the alert rule has access to query the required protected items and latest recovery point details.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: business-continuity-latest-recovery-point-age-alerts
languages:
- json
---
# Create alert rule for azure business continuity items

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurebusinesscontinuity/business-continuity-latest-recovery-point-age-alerts/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurebusinesscontinuity/business-continuity-latest-recovery-point-age-alerts/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurebusinesscontinuity/business-continuity-latest-recovery-point-age-alerts/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurebusinesscontinuity/business-continuity-latest-recovery-point-age-alerts/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurebusinesscontinuity/business-continuity-latest-recovery-point-age-alerts/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurebusinesscontinuity/business-continuity-latest-recovery-point-age-alerts/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurebusinesscontinuity%2Fbusiness-continuity-latest-recovery-point-age-alerts%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurebusinesscontinuity%2Fbusiness-continuity-latest-recovery-point-age-alerts%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurebusinesscontinuity%2Fbusiness-continuity-latest-recovery-point-age-alerts%2Fazuredeploy.json)

This templates creates an alert rule and user assigned MSI. It also assigns the MSI reader access to the subscription so that the alert rule has access to query the required protected items and latest recovery point details.

## Deployment steps

You can click the **Deploy to Azure** button at the beginning of this document. You may alternatively download the template and [deploy it using PowerShell](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-powershell#deploy-local-template) or use your preferred method of ARM template deployment.


`Tags: `