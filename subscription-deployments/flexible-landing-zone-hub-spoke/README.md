---
description: Deploys a flexible hub and spoke Azure landing zone with optional firewall, Bastion, VPN gateway, NAT gateway and monitoring.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: flexible-landing-zone-hub-spoke
languages:
- bicep
- json
---
# Flexible hub and spoke landing zone

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/flexible-landing-zone-hub-spoke/BicepVersion.svg)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fflexible-landing-zone-hub-spoke%2Fazuredeploy.json)

This template deploys a flexible Azure landing zone using a hub and spoke network topology, at subscription scope.

Every component that carries significant recurring cost is disabled by default, so the template can be deployed as a minimal, low cost foundation and expanded later without redesigning the landing zone.

## What gets deployed

With default parameters the template creates:

- A connectivity resource group containing the hub virtual network
- A production spoke virtual network and resource group
- A non-production spoke virtual network and resource group
- Frontend, application, database, management and private endpoint subnets in each spoke
- Network security groups for each subnet
- Hub to spoke and spoke to hub virtual network peerings, with gateway transit enabled on the hub side

## Optional components

Each of the following is controlled by an individual feature flag and is disabled by default:

| Parameter | Deploys |
| :-------- | :------ |
| `enableFirewall` | Azure Firewall in the hub |
| `enableBastion` | Azure Bastion in the hub |
| `enableVpnGateway` | VPN Gateway in the hub for hybrid connectivity |
| `enableNatGateway` | NAT Gateway for controlled outbound traffic from the spokes |
| `enableMonitoring` | Log Analytics workspace in a monitoring resource group |

Additional spoke environments can be added through the `spokeConfigurations` parameter without changing the template.

## Deployment

This is a subscription scope deployment, so it must be deployed with `az deployment sub` or `New-AzSubscriptionDeployment`.

### Azure CLI

```azurecli
az deployment sub create \
  --location southcentralus \
  --template-file main.bicep \
  --parameters @azuredeploy.parameters.json
```

### Azure PowerShell

```azurepowershell
New-AzSubscriptionDeployment `
  -Location southcentralus `
  -TemplateFile main.bicep `
  -TemplateParameterFile azuredeploy.parameters.json
```

Preview the changes before deploying:

```azurecli
az deployment sub what-if \
  --location southcentralus \
  --template-file main.bicep \
  --parameters @azuredeploy.parameters.json
```

## Cost considerations

Deploying Azure resources incurs charges in your subscription. Azure Firewall, Azure Bastion, VPN Gateway, NAT Gateway and Log Analytics are the components that contribute most to recurring cost, which is why each is disabled by default. Review the estimated cost with the Azure Pricing Calculator before enabling them.

`Tags: landing zone, hub and spoke, networking, virtual network, vnet peering, subscription deployment, governance`
