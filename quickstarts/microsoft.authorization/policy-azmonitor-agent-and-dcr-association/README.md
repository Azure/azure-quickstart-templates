# DeployIfNotExists (DINE) Azure Monitor Agent and Data Collection Rule (DCR) Association

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/policy-azmonitor-agent-and-dcr-association/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fpolicy-azmonitor-agent-and-dcr-association%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fpolicy-azmonitor-agent-and-dcr-association%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fpolicy-azmonitor-agent-and-dcr-association%2Fazuredeploy.json)

> Based on work done by [Pierre Roman](https://twitter.com/wiredcanuck) for the [ITOps Talk Blog](https://techcommunity.microsoft.com/t5/itops-talk-blog/building-a-policy-to-deploy-the-new-azure-monitor-agent/ba-p/2234423)

### Deployment Summary

Resources Deployed | Bicep File
:----------|:-----
1x Policy Definition with DeployIfNotExists effect for an [Azure Monitor Agent and Data Collection Rule association](https://docs.microsoft.com/en-gb/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent) | policyDefinition.bicep
1x Policy Initiative (policyset) | policyDefinition.bicep
1x Policy Assignment + 1x Role Assignment | policyAssignment.bicep
------------------------

### Input Summary

Parameter | Type | Default Value
:----------|:-----|:--------
assignmentIdentityLocation | string |
assignmentEnforcementMode | string | 'Default'
dcrResourceID | string |

-----------------------------

### Authored & Tested with

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.20.0
* bicep cli version 0.3.126 (a5e4c2e567)
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) 0.3.126 vscode extension

### Example Deployment Steps

```
# optional step to view the JSON/ARM template
az bicep build -f ./main.bicep

# required steps
az login
az deployment sub create -f ./main.bicep -l australiaeast

# optional step to trigger a subscription-level policy compliance scan 
az policy state trigger-scan
```

TODO: Clean up README

