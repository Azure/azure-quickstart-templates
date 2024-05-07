---
description: This template creates an empty logic app that you can use to define workflows.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: logic-app-create
languages:
- bicep
- json
---
# Create a Consumption logic app

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-create%2Fazuredeploy.json)

Azure Logic Apps is a cloud service that automates the execution of your business processes. You can create a workflow by using a visual designer to arrange prebuilt components into the sequence that you need. When you save your workflow, the designer sends the workflow's definition to the Azure Logic Apps execution engine. When the conditions for the workflow's trigger are met, the engine launches the workflow and manages the compute resources that the workflow needs to run. If you're new to Azure Logic Apps, see [What is Azure Logic Apps?](https://learn.microsoft.com/azure/logic-apps/logic-apps-overview).

This quickstart template creates a basic [Consumption logic app workflow](https://learn.microsoft.com/azure/logic-apps/logic-apps-overview#resource-environment-differences) that runs in multi-tenant Azure Logic Apps and connects to the status update feed for Azure services at https://azure.status.microsoft/status/feed, which is displayed at https://azure.status.microsoft/status.

For information about using this template, see [Create Azure Resource Manager templates for Azure Logic Apps](https://learn.microsoft.com/azure/logic-apps/logic-apps-create-deploy-template). To learn more about how to deploy the template, see the [quickstart article](https://learn.microsoft.com/azure/logic-apps/quickstart-create-deploy-azure-resource-manager-template).

- [Azure Logic Apps](https://azure.microsoft.com/services/logic-apps/)
- [Azure Logic Apps documentation](https://learn.microsoft.com/azure/logic-apps/logic-apps-overview)
- [Azure Logic Apps Learn modules](https://learn.microsoft.com/learn/browse/?term=logic%20app)

`Tags: recurrence, Microsoft.Logic/workflows, [variables('type')], [variables('actionType')]`
