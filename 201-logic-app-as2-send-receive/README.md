# Azure Logic Apps - AS2 Send Receive

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-as2-send-receive%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-as2-send-receive%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template demonstrates AS2 Send Receive using Logic Apps. It creates Integration Accounts for two partners (Contoso and Fabrikam) and adds Partners and Agreements into them. It creates Logic Apps between Fabrikam Sales and Contoso which demonstrate Sync AS2 Send Receive. It also creates Logic Apps between Fabrikam Finance and Contoso which demonstrate ASync AS2 Send Receive.
`Tags: AS2, Logic Apps, Integration Account, Enterprise Integration`

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

Once the deployment is completed, you can perform below steps to test your Logic Apps:
- Open the resource group blade in Azure Portal where you deployed all resources.
![Image of Azure resources](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-as2-send-receive/images/azure-resources.png "Azure resources"))
- The FabrikamSales-AS2Send and Contoso-Receive Logic Apps demonstrate sync send receive scenario. Open the FabrikamSales-AS2Send Logic App blade and click on Run Trigger to run it.
![Image of FabrikamSales-AS2Send Logic App](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-as2-send-receive/images/fabrikamsales-as2send.png "Run FabrikamSales-AS2Send Logic App"))
-- You can look into the run history and input/output for each action for these logic apps.
![Image of Contoso-AS2Receive run history](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-as2-send-receive/images/contoso-as2receive-runhistory.png "Contoso-AS2Receive run history"))
- The FabrikamFinance-AS2Send and Contoso-Receive Logic Apps demonstrate async send receive scenario. Open the FabrikamFinance-AS2Send Logic App blade and click on Run Trigger to run it.
-- The async MDN is received by the FabrikamFinance-AS2ReceiveMDN Logic App.
![Image of FabrikamFinance-AS2ReceiveMDN run history](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-as2-send-receive/images/fabrikamfinance-as2receivemdn-runhistory.png "FabrikamFinance-AS2ReceiveMDN run history"))
-- Again, you can look into the run history and input/output for each action for these Logic Apps.

### Note: ###
Please note that the FabrikamSales-AS2Send and FabrikamFinance-AS2Send are based on a recurrence trigger which fires every hour. You can change it by going into advanced options for recurrence action in the Logic Apps Designer and modifying it as approriate.

## Notes

Learn more about: Azure Logic Apps
* **Azure Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-what-are-logic-apps/
* **Logic Apps Enterprise Integration Pack** - https://blogs.msdn.microsoft.com/logicapps/2016/06/30/public-preview-of-logic-apps-enteprise-integration-pack/
* **B2B Processing capabilities in Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-enterprise-integration-b2b/
