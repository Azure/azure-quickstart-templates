# Tabo

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftabo-hdinsight%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftabo-hdinsight%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo: (change the folder name below to match the folder name for this sample)

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'tabo-hdinsight'
```
```bash
azure-group-deploy.sh -a tabo-hdinsight -l eastus -u
```

This template deploys a **Tabo Solution**. The **Tabo Solution** is a **Predictive Maintenance & Prescriptive Guidance with IOT Using ERP and Real-time Streaming Data**

`Tags: v, vn, stor, sub, pip, nsg, nic, tab, sb`

## Solution overview and deployed resources

Predictive Maintenance & Prescriptive Guidance with IOT Using ERP and Real-time Streaming Data using Microsoft Azure's Big Data PaaS Stack

The following resources are deployed as part of the solution

#### Microsoft.Compute

Provides Compute Resources for Microsoft Azure

+ **VirtualMachines**: Azure Virtual Machine
+ **CustomScriptExtension**: Custom Script Extension for Azure Virtual Machine

#### Microsoft.Storage

Provides Storage Resources for Microsoft Azure

+ **storageAccount**: Azure Storage Accounts

#### Microsoft.Network

Provides Network Resources for Microsoft Azure

+ **networkInterfaces**: Azure Network Interfaces
+ **virtualNetworks**: Azure Virtual Networks
+ **publicIpAddresses**: Azure Public IP Address
+ **networkSecurityGroups**: Azure Network Security Groups
+ **virtualNetworks**: Azure Virtual Networks

#### Microsoft.EventHub

Provides Service bus resources for Microsoft Azure

+ **Namespaces**: Azure Service bus
+ **EventHub**: Azure Event Hub

#### Microsoft.StreamAnalytics

+ **StreamingJobs**: Azure Streaming jobs

#### Microsoft.HDInsight

+ **Clusters**: Azure HDInsight Cluster

## Prerequisites

Atleast 12 Cores Available in the region where the solution is deployed.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

To deploy Tabo on your own subscription follow this procedure
<a href="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/Documents/DeploymentGuide.md" target="_blank">Tabo Deployment Guide</a>

#### Management

To manage the solution follow this procedure
<a href="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tabo-hdinsight/Documents/ActivityGuide.md" target="_blank">Tabo Activity Guide</a>

