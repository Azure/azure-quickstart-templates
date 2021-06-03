# Create a Time Series Insights Environment and IoT Hub Event Source

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-payg-with-iothub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-payg-with-iothub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-payg-with-iothub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-payg-with-iothub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-payg-with-iothub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-payg-with-iothub/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.timeseriesinsights%2Ftimeseriesinsights-environment-payg-with-iothub%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.timeseriesinsights%2Ftimeseriesinsights-environment-payg-with-iothub%2Fazuredeploy.json)

This template creates a Time Series Insights environment using the Pay As You Go Sku (referred to as 'longterm' in the template), a child event source configured to consume events from an IoT Hub, a storage account to hold data, and access policies that grant access to the environment's data. For more information, go to: <https://docs.microsoft.com/azure/time-series-insights/>.
