# Create Attestation Provider

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-attestation-provider-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-attestation-provider-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-attestation-provider-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-attestation-provider-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-attestation-provider-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-attestation-provider-create/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-attestation-provider-create%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-attestation-provider-create%2Fazuredeploy.json)

This template creates a Attestation Provider.
<h4>Overview</h4>
<p>
Enclaves allow software to execute in a manner that excludes all (or large portions) of the host and VM OS from the TCB. Keys can be released to enclaves by relying parties (such as Azure Key Vault), as long as these relying parties can be convinced that the recipient is in fact an enclave matching the key release policy. 
Multiple technologies provide enclave functionality. SGX is hardware-level isolation supported on Intel CPUs. The processor itself ensures memory accesses to sensitive regions of memory are constrained to an enclave’s execution context. VSM is a Microsoft software solution in which the hypervisor is responsible for protecting enclave memory.
</p>

Microsoft.Attestation/attestationProvider is the resource that users should create if they want to manage the attestation requirements
<h4>Attestation Scenarios</h4>
<ul>
<br>SGX Attestation
<br>VSM Attestation
</ul>


