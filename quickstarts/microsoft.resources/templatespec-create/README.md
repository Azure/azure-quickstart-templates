# Create and Deploy a TemplateSpecs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-create/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Ftemplatespec-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Ftemplatespec-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Ftemplatespec-create%2Fazuredeploy.json)

This sample shows how to create and deploy templatesSpecs from a template.  There are 2 steps to complete the use of this sample.  The steps are disctinct because the lifecycle of the two steps are different.  Typically, a templateSpec version is created/updated a few times but will be deployed many times.

1. Create the templateSpec by deploying the template in the prereqs folder, this creates the templateSpec version and makes it available to the tenant.  You can deploy the prereq template using the deploy buttons in the [prereq readme](./prereqs/README.md).
1. Deploy the templateSpec using azuredeploy.json.  This deploys the template stored in the indicated version of the templateSpec, creating the resources defined in the templateSpec's template.

When you create the templateSpec (using the prereq template) note the name of the subscription, resourceGroup, templateSpec name and templateSpec version.  This information creates the resourceId and is needed for deployment.

If you create and deploy the templateSpec in the same resourceGroup clean up will be simple, but in practice templateSpecs (create) and resources created by them (deploy) will be placed in separate resourceGroups.

See the [templateSpec documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs) for more information on how to use templateSpecs in Azure.
