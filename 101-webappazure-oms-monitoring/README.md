# Web App Monitoring

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webappazure-oms-monitoring%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webappazure-oms-monitoring%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This solution (currently in private preview) will allow you to capture your Azure WebApps metrics (across subscriptions) and visualize them in Operations Management Suite (Log Analytics). This solution currently leverages an automation runbook in Azure Automation, the Log Analytics Ingestion API, together with Log Analytics to present data about all your WebApps in a single log analytics workspace.

![alt text](images/WebAppPaaS.png "Web App Monitoring")

