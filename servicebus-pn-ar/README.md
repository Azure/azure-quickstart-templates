# Create a Service Bus Premium Namespace and AuthorizationRule

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkafka-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkafka-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

How to Run the scripts
----------------------

You can use the Deploy to Azure button or use the below methor with powershell

Creating a new deployment with powershell:

Create a resource group:

    PS C:\Users\azureuser1> New-AzureResourceGroup -Name "AZKFRKAFKAEA3" -Location 'EastAsia'

Start deployment

    PS C:\Users\azureuser1> New-AzureResourceGroupDeployment -Name "AZKFRGKAFKAV2DEP1" -ResourceGroupName "AZKFRGKAFKAEA3"  -TemplateFile "E:\azure-quickstart-templates\servicebus-pn-ar\azuredeploy.json" -TemplateParameterFile "E:\azure-quickstart-templates\servicebus-pn-ar\azuredeploy.parameters.json" -Verbose

On successful deployment results will be like this

DeploymentName    : AZKFRGKAFKAV2DEP1
ResourceGroupName : AZKFRGKAFKAEA3
ProvisioningState : Succeeded
Timestamp         : 3/18/2016 12:16:22 AM
Mode              : Incremental
TemplateLink      :
Parameters        :
                    Name              Type                       Value
                    ===============   =========================  ==========
                    premiumNamespaceName  String                 {}
                    namespaceSASKeyName   String                 {}

Outputs           :
                    Name             Type                       Value
                    ===============  =========================  ==========
                    namespaceDefaultConnectionString  String                     {}
                    defaultSharedAccessPolicyPrimaryKey  String                  {}
                    namespaceCustomConnectionString  String                      {}
                    customSharedAccessPolicyPrimaryKey  String                   {}

