# Connect Logic app to an on premises data gateway

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-sendgrid%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-sendgrid%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a Logic app and sql connection to connect to an on premise data source. This template configures sql connection with the existing data gateway to connect on prem.

Before you deploy this template make sure you download and manually install the on-premises data gateway on a local computer or a vm. After you install the gateway on a local computer/vm, you need to create the gateway in portal and provide that gateway name in the template param. Reference Link https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-gateway-connection

