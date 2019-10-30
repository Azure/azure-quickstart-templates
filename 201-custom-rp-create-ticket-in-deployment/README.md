<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjjbfour%2Fazure-quickstart-templates%2Fmaster%2F201-custom-rp-create-ticket-in-deployment%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fjjbfour%2Fazure-quickstart-templates%2Fmaster%2F201-custom-rp-create-ticket-in-deployment%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This sample Azure Resource Manager template deploys a custom resource provider to Azure that extends the Azure Resource Manager API. This sample shows how to extend existing resources that are outside the resource group where the custom provider instance lives. In this sample, the custom resource provider is powered by an Azure Logic App, but any public API endpoint can be used.

The custom resource provider is a hidden Azure resource so to confirm that the custom resource provider has been deployed you will have to check the box that says *Show hidden types* in the Azure portal Overview page for the resource group.

![](images/showhidden.png)

## Details on the custom resource provider created

This sample deployment creates the following apis on the resource.

1) An Azure Resource Manager extended API called "associations".

### Associations

If you are unfamiliar with "associations" or custom providers, this sample builds off of the [custom provider existing resource deployment sample](../101-custom-rp-existing-resource-deployments\README.md), which has more information. In this sample, existing resource deployments will be expanded to work with an external service. In this case, the custom provider creates a connection to service now. However, any service or public HTTP endpoint can be used as an extension.

### Starting from scratch

If you don't have an existing custom provider with logic deployed, you can deploy the custom provider infrastructure by providing the service now template parameter information. If you don't have a service now account, you can create a free test account:

![](images/customprovidertemplateparameters.PNG)

The resulting deployment should consist of two parts: the custom provider infrastructure and the association resource. The custom provider infrastructure deploys the web connector to service now, logic app, and custom provider. The association triggers the custom provider to perform an action. In this sample, the action is creating a service now record.

![](images/createdcustomprovider.PNG)

### Existing custom provider

Once the sample is initially deployed, instead of recreating everything from scratch, it can just use an existing custom provider resource. When deploying with an existing custom provider resource, the "Custom Resource Provider Id" and "Association Name" are the only required fields. This will only deploy the "associations" resource.

![](images/createdassociationresource.PNG)

The outputs section of the template deployment also will display the created resource, which can be accessed through the *reference* template function.
![](images/customresourcetemplateoutput.png)

In addition, you can navigate to the deployed Azure Logic App resource in the template resource group and check the *run history* tab to see the HTTP calls.
![](images/logicapprun.png)

Additional "associations" can be created through deploying another Azure Resource Manager Template or directly interfacing with the Azure REST API.