# Azure Container Service (AKS) with autoscaling (VMSS) - PREVIEW

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aks%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aks%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys an **AKS cluster** with autoscaling using Virtual Machine Scale Sets (VMSS).

See https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler for more information.

Please note that this is a preview feature. Previews are made available to you on the condition that you agree to the supplemental terms of use. Some aspects of this feature may change prior to general availability (GA). More information: https://azure.microsoft.com/support/legal/preview-supplemental-terms/

Please note that before using this template you will need to register the following providers:

```json
az feature register --name VMSSPreview --namespace Microsoft.ContainerService
```

```json
az provider register -n Microsoft.ContainerService
```
