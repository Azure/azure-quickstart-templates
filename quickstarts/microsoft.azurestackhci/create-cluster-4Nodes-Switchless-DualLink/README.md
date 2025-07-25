---
description: This template creates a four nodes Azure Local instance using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster-4Nodes-Switchless-DualLink
languages:
- json
---
# creates a four nodes Azure Local instance in Switchless-Dual-link Networking mode

This template allows you to create a four nodes Azure Local instance in Switchless-Dual-link Networking mode using version 23H2. First you deploy the template in validate mode which does confirm the parameters at the device. Once passed you re-deploy the template with mode set to deploy.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, you must have Arc enabled the server(s) and installed the mandatory extensions. The following pre-requisites must be completed:
- Register these resource providers
    - Microsoft.HybridCompute
    - Microsoft.GuestConfiguration
    - Microsoft.HybridConnectivity
    - Microsoft.AzureStackHCI
- Make a note of the HCI Resource Provider SPNs Object ID in the tenant.


`Tags: Microsoft.AzureStackHCI/clusters, hci`