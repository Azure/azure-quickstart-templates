---
description: This template creates an Azure Payment HSM, to provide cryptographic key operations for real-time, critical payment transactions in the Azure cloud.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: payment-hsm-create
languages:
- json
---
# Create an Azure Payment HSM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hardwaresecuritymodules/payment-hsm-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hardwaresecuritymodules%2Fpayment-hsm-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hardwaresecuritymodules%2Fpayment-hsm-create%2Fazuredeploy.json)

This template creates an Azure Payment HSM.

## Overview

Azure Payment HSM is a "BareMetal" service delivered using [Thales payShield 10K payment hardware security modules (HSM)](https://cpl.thalesgroup.com/encryption/hardware-security-modules/payment-hsms/payshield-10k) -- physical devices that provide cryptographic key operations for real-time, critical payment transactions in the Azure cloud. Azure Payment HSM is designed specifically to help a service provider and an individual financial institution accelerate their payment system's digital transformation strategy and adopt the public cloud. For more information, see [Azure Payment HSM: Overview](/azure/payment-hsm/overview).

This template demonstrates a simple use case for creating an payment HSM. For more information see [Quickstart: Create an Azure Payment HSM with an ARM template](/azure/payment-hsm/quick-template).

`Tags: microsoft.HardwareSecurityModules/dedicatedHSMs`
