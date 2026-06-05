---
description: This template creates a Confidential VM (CVM) ready Azure Stack HCI cluster using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cvm-configurable-cluster
languages:
- json
---
# Deploy a Confidential VM (CVM) ready Azure Stack HCI Cluster

## Introduction

Confidential VMs (CVM) offer strong security and confidentiality benefits over standard VMs. CVMs provide a robust hardware-based isolation between other virtual machines, the hypervisor, and host management code.

This template deploys an Azure Stack HCI cluster configured with the `confidentialVmIntent` parameter set to **Enable**, which is required for deploying Confidential VMs on Azure Local.

Without specifying this parameter, the creation of CVMs will fail. Additionally, setting this parameter may slightly impact the CPU performance for some workloads (both CVMs and standard VMs).

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cvm-configurable-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cvm-configurable-cluster%2Fazuredeploy.json)

## Prerequisites

### Hardware Requirements

CVM deployment has been validated on Lenovo servers with AMD Genoa Gen 4 CPU:

1. ThinkAgile MX455 V3 Edge PR
2. ThinkSystem SR665 V3 Validated Node

### BIOS/UEFI Settings (Lenovo)

Ensure the following BIOS/UEFI settings are applied to enable AMD SEV-SNP:

**Processor Settings:**
- SEV-SNP Support = Enabled
- SNP Memory (RMP Table) Coverage = Disabled

**Memory Settings:**
- SMEE = Enabled
- SEV-ES ASID Space Limit = 1007
- SEV Control = Enabled

### Azure Prerequisites

- Arc-enabled server(s) with mandatory extensions installed
- Register these resource providers:
    - Microsoft.HybridCompute
    - Microsoft.GuestConfiguration
    - Microsoft.HybridConnectivity
    - Microsoft.AzureStackHCI
- Note the HCI Resource Provider SPNs Object ID in the tenant

## Deployment

The ARM template includes the `confidentialVmIntent` parameter:

```json
"confidentialVmIntent": {
    "defaultValue": "Disable",
    "type": "string",
    "metadata": {
        "description": "Customer Intent to update the ConfidentialVm intent on the cluster or edgeDevice, can be Enable or Disable"
    }
}
```

The parameter file sets this to **Enable**:

```json
"confidentialVmIntent": {
    "value": "Enable"
}
```