# Create an Azure Log Aanlytics workspace and some datasources

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-log-analytics-workspace%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-log-analytics-workspace%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an Azure OMS Log Analytics workspace and configure a single datasource for each of Windows Performance Counters and Windows Event Logs. These datasources can be used as models for adding other datasources. The workspace name needs to be unique. Note that Log Analytics workspaces location is not available in all regions so the location is explicitly called out as a parameter.
