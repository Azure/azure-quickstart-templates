# Create a Namespace and NotificationHub  using a template

This template will create a Namespace of type NotificationHub and help create NotificationHubs within this namesapace


## Deploying from PowerShell

For details on how to install and configure Azure Powershell see [here].(https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

Launch a PowerShell console

Ensure that you are in Resource Manager Mode

```PowerShell

Switch-AzureMode AzureResourceManager

```
Change working folder to the folder containing this template

```PowerShell

New-AzureResourceGroup -Name "<new resourcegroup name>" -Location "<new resourcegroup location>"  -TemplateParameterFile .\azuredeploy-parameters.json -TemplateFile .\azuredeploy.json

```

You will be prompted for the following parameters

+ notificationHubNamespace : Name of the namespace you want to create
+ notificationHubName : Name of the NotificationHub you want to create within the namespace

