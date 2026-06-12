---
description: This template creates a Confidential VM (CVM) ready Azure Stack HCI cluster using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster-cvm-intent
languages:
- json
---
# Deploy a Confidential VM (CVM) ready Azure Stack HCI Cluster

## Introduction

Confidential VMs (CVM) offer strong security and confidentiality benefits over standard VMs. CVMs provide a robust hardware-based isolation between other virtual machines, the hypervisor, and host management code.

This template deploys an Azure Stack HCI cluster configured with the `confidentialVmIntent` parameter, set to **Enable** for deploying Confidential VMs on Azure Local.