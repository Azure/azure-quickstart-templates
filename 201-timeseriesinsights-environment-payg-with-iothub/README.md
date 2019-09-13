# Create a Time Series Insights Environment and IoT Hub Event Source

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-timeseriesinsights-environment-payg-with-iothub%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-timeseriesinsights-environment-payg-with-iothub%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Time Series Insights environment using the Pay As You Go Sku (refered to as 'longterm' in the template), a child event source configured to consume events from an IoT Hub, a storage account to hold data, and access policies that grant access to the environment's data. For more information, go to: <https://docs.microsoft.com/azure/time-series-insights/>.