---
description: This template creates an Azure Local cluster with external iSCSI SAN storage using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster-san-iscsi
languages:
- json
---
# Create an Azure Local cluster with iSCSI SAN storage

This template allows you to create an Azure Local cluster with external iSCSI SAN storage. First, deploy the template with `deploymentMode` set to `Validate` to validate the configuration on the devices. Once validation passes, redeploy the template with `deploymentMode` set to `Deploy`.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-san-iscsi%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-san-iscsi%2Fazuredeploy.json)

## Prerequisites

To deploy this template, you must have Arc-enabled the servers and installed the mandatory extensions. Complete the following prerequisites:

- Register these resource providers: `Microsoft.HybridCompute`, `Microsoft.GuestConfiguration`, `Microsoft.HybridConnectivity`, `Microsoft.AzureStackHCI`, `Microsoft.KeyVault`, and `Microsoft.Storage`.
- Make a note of the HCI resource provider service principal's object ID in the tenant.
- Prepare the Active Directory domain, deployment account, and organizational unit.
- Configure the external iSCSI SAN, infrastructure LUNs, and per-node iSCSI networking. If using CHAP, provide credentials that match the SAN configuration.
- Replace the dummy values in `azuredeploy.parameters.json` with your environment's configuration.

`Tags: Microsoft.AzureStackHCI/clusters, hci, SAN, iSCSI`
