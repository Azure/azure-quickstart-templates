---
description: This template allows you to deploy a VM using a Managed Disk image.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sap-2-tier-user-image-md
languages:
- json
---
# SAP NW 2-tier compatible custom MD image

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-2-tier-user-image-md/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-2-tier-user-image-md/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-2-tier-user-image-md/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-2-tier-user-image-md/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-2-tier-user-image-md/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-2-tier-user-image-md/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-2-tier-user-image-md%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-2-tier-user-image-md%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-2-tier-user-image-md%2Fazuredeploy.json)

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using a private Managed Disk image.
This is a template for a 2-tier configuration. It deploys 1 server on either Standard or Premium Storage.

There is no suitable configuration for X-Large with Standard Storage. If you select this configuration, the template will deploy a Large configuration.

<table>
	<tr>
		<th>Size</th>
		<th>Premium Storage</th>
		<th>Standard Storage</th>
	</tr>
	<tr>
		<td>Small < 2.000 SAPS</td>
		<td>1xDS11 (2xP20 1xP10)</td>
		<td>1xD11</td>
	</tr>
	<tr>
		<td>Medium < 9.000 SAPS</td>
		<td>1xDS13 (3xP20 1xP10)</td>
		<td>1xD13</td>
	</tr>
	<tr>
		<td>Large < 18.000 SAPS</td>
		<td>1xDS14 (3xP30 + 1xP20)</td>
		<td>1xD14</td>
	</tr>
	<tr>
		<td>X-Large < 40.000 SAPS</td>
		<td>1xGS5 (4xP30 1xP20)</td>
		<td>1xD14</td>
	</tr>
</table>				

`Tags: Microsoft.Resources/deployments, Microsoft.Network/networkInterfaces`
