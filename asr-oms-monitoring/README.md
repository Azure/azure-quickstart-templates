# OMS ASR Monitoring

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fasr-oms-monitoring%2F%2Fazuredeploy.json) 
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fasr-oms-monitoring%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This solution (currently in private preview) will allow you to capture your Azure Site Recovery operations (across subscriptions and Recovery Vaults) and visualize them in Operations Management Suite (Log Analytics). This solution currently leverages an automation runbook in Azure Automation, the Log Analytics Ingestion API, together with Log Analytics to present data about all your ASR Recovery Vaults in a single log analytics workspace.

![alt text](images/OMSASR.png "OMS ASR Monitoring")
                      