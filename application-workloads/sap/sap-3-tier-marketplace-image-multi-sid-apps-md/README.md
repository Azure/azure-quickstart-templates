# SAP NetWeaver 3-tier multi SID AS (managed disks)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-multi-sid-apps-md/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-multi-sid-apps-md/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-multi-sid-apps-md/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-multi-sid-apps-md/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-multi-sid-apps-md/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-multi-sid-apps-md/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-marketplace-image-multi-sid-apps-md%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-marketplace-image-multi-sid-apps-md%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-marketplace-image-multi-sid-apps-md%2Fazuredeploy.json)

This template is one of three templates for a 3-tier Multi SID SAP depoyment.

* [ASCS/SCS servers template](https://github.com/Azure/azure-quickstart-templates/tree/master/sap-3-tier-marketplace-image-multi-sid-xscs-md)
* [Database servers Template](https://github.com/Azure/azure-quickstart-templates/tree/master/sap-3-tier-marketplace-image-multi-sid-db-md)
* Application servers template (this template)

It takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using the latest patched version of the selected operating system. This is a template for a 3-tier Multi SID configuration. It deploys multiple application servers for one SAP system. The application servers are placed in an Availability Set.
This template uses Managed Disks.

## Virtual Machine configuration

<table>
	<tr>
		<th>Size</th>
		<th>HA</th>
		<th>Non-HA</th>
	</tr>
	<tr>
		<td>Demo</td>
		<td>2xDS2_v2 DI (1xP10)</td>
		<td>1xDS2_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>Small < 30.000 SAPS</td>
		<td>2xDS2_v2 DI (1xP10)</td>
		<td>1xDS2_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>Medium < 70.000 SAPS</td>
		<td>4xDS13_v2 DI (1xP10)</td>
		<td>4xDS13_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>Large < 180.000 SAPS</td>
		<td>6xDS14_v2 DI (1xP10)</td>
		<td>6xDS14_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>X-Large < 250.000 SAPS</td>
		<td>10xDS14_v2 DI (1xP10)</td>
		<td>10xDS14_v2 DI (1xP10)</td>
	</tr>
</table>


