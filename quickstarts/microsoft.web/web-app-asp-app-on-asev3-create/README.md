# Create an App Service Plan and an App in an App Service Environment v3

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/PublicLastTestDate.svg)

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/PublicDeployment.svg)

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/FairfaxLastTestDate.svg)

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/FairfaxDeployment.svg)

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/BestPracticeResult.svg)

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/CredScanResult.svg)

![](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-asp-app-on-asev3-create/BicepVersion.svg)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-asp-app-on-asev3-create%2Fazuredeploy.json)

[![](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-asp-app-on-asev3-create%2Fazuredeploy.json)

This template deploys an **App Service Environment v3 (ASEv3).** 

## Overview and deployed resources

This solution provides 2 scenarios to create ASEv3 with ARM or Bicep templates:

- **Scenario 1**: Create a new vNET, subnet, NSG and ASEv3, this solution will create the following Azure resources:
  - A Network Security Group
  - A Virtual Network include a Subnet
  - An App Service Environment v3
  - An App Service Plan(*)
  - An App Service (*)
- **Scenario 2**: To use existing vNET and subnet to create an ASEv3, this solution will create the following Azure resources:
  - An App Service Environment v3
  - An App Service Plan(*)
  - An App Service (*)

(*) Currently, the App Service Plan and App Service need to be deployed separately.

### Microsoft.Network/networkSecurityGroups

This template will create a Network Security Group with an empty Network Security Group Rule. *<u>If you are using external load balancer, please add an allow HTTPS inbound rule in the NSG.</u>*

### Microsoft.Network/virtualNetworks

This template will create a Virtual Network, and a /24 Subnet will be created for the ASEv3 environment, where the Subnet needs to be delegated and assigned to HostingEnvironments for Subnet configuration.

### Microsoft.Web/hostingEnvironments

In the HostingEnvironments section of this template, an App Service Environments will be created with following properties**:**

- **aseName (string)**: Required. ASEv3 name.
- **dedicatedHostCount (string)**: Required. Configure dedicated host count (Value : **"0"** means no dedicated host will be deployed).
- **zoneRedundant (bool)**: Required. Configure zone redundant (Value: **false** means no zone redundant will be deployed).
- **internalLoadBalancingMode (int)**: Required. Load balancer mode: **0** - external load balancer, **3** - internal load balancer for ASEv3.
- **createPrivateDNS (bool)**: Optional, a custom defined parameter. Only when this properties set to **true** and **internalLoadBalancingMode** set to **3**. It will create a Private DNS zone.
- **useExistingVnetandSubnet (bool)**: Optional, a custom defined parameter. When set to **true**, will deploy to existing vnet and subnet.
- **vNetResourceGroupName (string)**: Optional, a custom defined parameter. Only when the virtual network resides in different resource group.

### Microsoft.Web/serverfarms

In this template, an application service environment will be created in the ASEv3. This example will be created with the following default values. You can adjust the parameter settings upon your requirements.

- **hostingPlan (string)**: Required. App Service Plan name.
- **hostingEnvironmentProfile** (string): Required. The ASEv3 name where App service the reside.
- **sku (string)**: Required. App service plan sku. Default value is **"IsolatedV2"**.
- **skuCode (string)**: Required. App service plan sku code. Default value is **"I1V2"**.

### Microsoft.Web/sites

In this template, an application service environment will be created in the App service plan. This example will be created with the following default values. You can adjust the parameter settings upon your requirements.

- **appName (string)**: Required. App service name.
- **phpVersion (string)**: Required. Enable php of App service. Default value is **"OFF"**.
- **netFrameworkVersion (string)**: Required. .NET Framework version of App service, Default value is **"v5.0"**
- **alwaysOn (bool)**: Required. Enable Always-on of App service. Default value is **true**.  

## Prerequisites

The prerequisites for the deployment is creating a resource group that ASEv3 is available. Be aware that zone redundant is available in some region. If you don't have any resource group exist, you can use following PowerShell or Az cli to create one.

**PowerShell:**

```powershell
New-AzResourceGroup -Name "rg-asev3-templates-demo" -location "West US 2"
```

**Az cli:**

```bash
az group create --name rg-asev3-templates-demo --location westus2
```

## Usage

### From Az cli
- ARM

```bash
az deployment group create --name asev3-deployment-2021081102 -f azuredeploy.json --parameters azuredeploy.parameters.json -g rg-asev3-templates-demo

az deployment group create --name asev3-appserviceplan-deployment-2021081106 -f nested/azuredeploy.site.json --parameters nested/azuredeploy.site.parameters.json -g rg-asev3-templates-demo
```

- Bicep

```bash
az deployment group create --name bicep-asev3-deployment-2021081104 -f main.bicep --parameters azuredeploy.parameters.json -g rg-asev3-templates-demo

az deployment group create --name bicep-asev3-appserviceplan-deployment-2021081108 -f modules/site.bicep --parameters nested/azuredeploy.site.parameters.json -g rg-asev3-templates-demo
```

### From PowerShell

- ARM

```powershell
New-AzResourceGroupDeployment -Name "asev3-deployment-2021081101" -ResourceGroupName "rg-asev3-templates-demo" -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json"

New-AzResourceGroupDeployment -Name "asev3-appserviceplan-deployment-2021081105" -ResourceGroupName "rg-asev3-templates-demo" -TemplateFile ".\nested\azuredeploy.site.json" -TemplateParameterFile ".\nested\azuredeploy.site.parameters.json"
```

- Bicep

```powershell
New-AzResourceGroupDeployment -Name "bicep-asev3-deployment-2021081103" -ResourceGroupName "rg-asev3-templates-demo" -TemplateFile ".\main.bicep" -TemplateParameterFile ".\azuredeploy.parameters.json"

New-AzResourceGroupDeployment -Name "bicep-asev3-appserviceplan-deployment-2021081107" -ResourceGroupName "rg-asev3-templates-demo" -TemplateFile ".\modules\site.bicep" -TemplateParameterFile ".\nested\azuredeploy.site.parameters.json"
```

------

For more details on App Service Environments v3, see the [App Service Environment overview](https://docs.microsoft.com/en-us/azure/app-service/environment/overview).

