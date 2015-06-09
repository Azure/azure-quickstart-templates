# Simple deployment of an Ubuntu VM with monitoring enabled through DataDog extension 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-simple-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [kmouss](https://github.com/kmouss)

This template allows you to deploy an Ubuntu VM with monitoring enabled through DataDog extension.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| location | The location where the Virtual Machine will be deployed |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| api_key  | API key is required by the Datadog Agent to submit metrics and events to Datadog. The key can be obtained from: https://app.datadoghq.com |

To get a DataDog account, you need to visit https://app.datadoghq.com, sign up for the service to get your API Key which you can use above for your deployment. For more details on DataDog integration with Azure, visit the documenation under: http://docs.datadoghq.com/integrations/azure/


