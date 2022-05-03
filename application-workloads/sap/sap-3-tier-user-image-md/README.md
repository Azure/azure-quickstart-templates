# SAP NetWeaver 3-tier compatible template using a custom image

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-user-image-md/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-user-image-md/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-user-image-md/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-user-image-md/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-user-image-md/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-user-image-md/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-user-image-md%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-user-image-md%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-user-image-md%2Fazuredeploy.json)

    

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using a private OS image. This is a template for a 3-tier configuration. It deploys 1 (no HA) or 2 (HA) ASCS/SCS servers, 1 (no HA) or 2 (HA) database servers and serveral virtual machines that can host dialog instances. In case of a HA deployment, the ASCS/SCS and DB servers are placed in Availability Sets and a Load Balancer is added to the ASCS/SCS and DB server to allow HA configurations in the operating system (e.g. Windows Failover Cluster).
This template uses Managed Disks.

## ASCS/SCS Internal Load Balancer ports

* Windows specific ports 445, 5985
* ASCS Ports (instance number 00): 3200, 3600, 3900,  8100, 50013, 50014, 50016
* SCS Ports (instance number 01): 3201, 3301, 3901, 8101, 50113, 50114, 50116
* ASCS ERS ports on Linux (instance number 02): 3302, 50213, 50214, 50216
* SCS ERS ports on Linux (instance number 03): 3303, 50313, 50314, 50316

ASCS/SCS Internal Load Balancer probe port: **62000**

ERS Internal Load Balancer probe port: **62102**

## DB Internal Load Balancer ports

* DB Internal Load Balancer ports: **1433**

DB Internal Load Balancer probe port: **62504**

<table>
	<tr>
		<th>Size</th>
		<th>HA</th>
		<th>Non-HA</th>
	</tr>
	<tr>
		<td>Demo</td>
		<td>2xDS12_v2 DB Server (1xP10) + 2xDS2_v2 ASCS/SCS (1xP10) + 2xDS2_v2 DI (1xP10)</td>
		<td>1xDS12_v2 DB Server (1xP10) + 1xDS2_v2 ASCS/SCS (1xP10) + 1xDS2_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>Small < 30.000 SAPS</td>
		<td>2xDS13_v2 DB Server (4xP20 1xP20) + 2xDS11_v2 ASCS/SCS (1xP10) + 2xDS13_v2 DI (1xP10)</td>
		<td>1xDS13_v2 DB Server (4xP20 1xP20) + 1xDS11_v2 ASCS/SCS (1xP10) + 1xDS13_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>Medium < 70.000 SAPS</td>
		<td>2xDS14_v2 DB Server (6xP20 1xP20) + 2xDS11_v2 ASCS/SCS (1xP10) + 4xDS13_v2 DI (1xP10)</td>
		<td>1xDS14_v2 DB Server (6xP20 1xP20) + 1xDS11_v2 ASCS/SCS (1xP10) + 4xDS13_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>Large < 180.000 SAPS</td>
		<td>2xGS4 DB Server (5xP30 1xP20) + 2xDS11_v2 ASCS/SCS (1xP10) + 6xDS14_v2 DI (1xP10)</td>
		<td>1xGS4 DB Server (5xP30 1xP20) + 1xDS11_v2 ASCS/SCS (1xP10) + 6xDS14_v2 DI (1xP10)</td>
	</tr>
	<tr>
		<td>X-Large < 250.000 SAPS</td>
		<td>2xGS5 DB Server (6xP30 1xP30) + 2xDS11_v2 ASCS/SCS (1xP10) + 10xDS14_v2 DI (1xP10)</td>
		<td>1xGS5 DB Server (6xP30 1xP30) + 1xDS11_v2 ASCS/SCS (1xP10) + 10xDS14_v2 DI (1xP10)</td>
	</tr>
</table>


