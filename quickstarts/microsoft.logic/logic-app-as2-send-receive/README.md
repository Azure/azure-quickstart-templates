# Azure Logic Apps - AS2 Send Receive

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-as2-send-receive/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-as2-send-receive/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-as2-send-receive/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-as2-send-receive/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-as2-send-receive/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-as2-send-receive/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-as2-send-receive%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-as2-send-receive%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-as2-send-receive%2Fazuredeploy.json)

This template creates an AS2 Send Receive workflow by using Azure Logic Apps to create the following Azure resources:

- Integration accounts for two partners, Contoso and Fabrikam, along with the necessary artifacts, which are partners and agreements.

- Logic apps between Fabrikam Sales and Contoso, which demonstrate Sync AS2 Send Receive.

- Logic apps between Fabrikam Finance and Contoso, which demonstrate ASync AS2 Send Receive.

**Important**: This template creates and deploys two Standard-tier integration accounts, which incur costs. For more information, see [Azure Logic Apps pricing](https://azure.microsoft.com/pricing/details/logic-apps/) and [Pricing and billing models for Azure Logic Apps](https://docs.microsoft.com/azure/logic-apps/logic-apps-pricing).

`Tags: AS2, Logic Apps, Integration Account, Enterprise Integration`

## Deployment steps

Either select the **Deploy to Azure** button at the top of this page or follow the instructions for command line deployment by using the scripts in the root of this repo.

## Usage

To test your logic apps after deployment completes, you can perform these steps:

1. In the Azure portal, open the resource group page that shows where you deployed all the resources.

   ![Screenshot that shows Azure resources](images/azure-resources.png"Azure resources")

   The logic apps, FabrikamSales-AS2Send and Contoso-Receive, show the sync send receive scenario. 
  
1. Open the logic app for FabrikamSales-AS2Send. On the logic app's **Overview** page, and select **Run Trigger**.

   ![Screenshot that shows FabrikamSales-AS2Send logic app](images/fabrikamsales-as2send.png"Run FabrikamSales-AS2Send Logic App")

1. On the **Overview** page, you can also review the run history, inputs, and outputs for each action in these logic apps:

   ![Screenshot that shows Contoso-AS2Receive run history](images/contoso-as2receive-runhistory.png"Contoso-AS2Receive run history")

   The logic apps, FabrikamFinance-AS2Send and Contoso-Receive, show the async send receive scenario.
   
1. Open the logic app for FabrikamFinance-AS2Send. On the logic app's **Overview** page, and select **Run Trigger**.

   The async MDN is received by the logic app, FabrikamFinance-AS2ReceiveMDN.

   ![Screenshot that shows FabrikamFinance-AS2ReceiveMDN run history](images/fabrikamfinance-as2receivemdn-runhistory.png"FabrikamFinance-AS2ReceiveMDN run history")

1. Again, you can review the run history, inputs, and outputs for each action in these logic apps.

**Important**: The logic apps, FabrikamSales-AS2Send and FabrikamFinance-AS2Send, start with a Recurrence trigger that runs every hour. To run the logic apps more or less often, you can change the trigger's frequency and interval as appropriate by using the Logic App Designer.

## Next steps

Learn more about Azure Logic Apps:

* [Azure Logic Apps](https://docs.microsoft.com/azure/logic-apps/logic-apps-overview)
* [B2B Processing capabilities in Logic Apps](https://docs.microsoft.com/azure/logic-apps/logic-apps-enterprise-integration-overview)
