# Create a Time Series Insights Environment and Event Source

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-timeseriesinsights-create-environment-with-eventsource%2azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-timeseriesinsights-create-environment-with-eventsource%2azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Time Series Insights environment and a child event source configured to consume events from an Event Hub. For more information, go to: https://docs.microsoft.com/azure/time-series-insights/.

The shared access key for the event hub must be stored as a secret in a Key Vault.
