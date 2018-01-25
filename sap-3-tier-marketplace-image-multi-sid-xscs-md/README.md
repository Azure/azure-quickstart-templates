# SAP NetWeaver 3-tier multi SID (A)SCS (managed disks)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-marketplace-image-multi-sid-xscs-md%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-marketplace-image-multi-sid-xscs-md%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template is one of three templates for a 3-tier Multi SID SAP depoyment.

* ASCS/SCS servers template (this template)
* [Database servers Template](https://github.com/Azure/azure-quickstart-templates/tree/master/sap-3-tier-marketplace-image-multi-sid-db)
* [Application servers template](https://github.com/Azure/azure-quickstart-templates/tree/master/sap-3-tier-marketplace-image-multi-sid-apps)

It takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using the latest patched version of the selected operating system. This is a template for a 3-tier Multi SID configuration. It deploys 1 (no HA) or 2 (HA) ASCS/SCS servers on which multiple ASCS/SCS instances for multiple SAP system can be deployed. In case of a HA deployment, the ASCS/SCS servers are placed in an Availability Set and a Load Balancer is added to the ASCS/SCS servers to allow HA configurations in the operating system (e.g. Windows Failover Cluster).
This template uses Managed Disks.

## ASCS/SCS Internal Load Balancer ports
The template deploys one Azure Loadbalancer that supports multiple SAP systems. 

* The ASCS instances are configured for instance number 00, 10, 20... 
* The SCS instances are configured for instance number 01, 11, 21... 
* The ASCS ERS (Linux only) instances are configured for instance number 02, 12, 22... 
* The SCS ERS (Linux only) instances are configured for instance number 03, 13, 23... 

The Load Balancer contains 1 (2 for Linux) VIP(s), 1x VIP for ASCS/SCS and 1x VIP for ERS (Linux only)

The following list contains all load balancing rules (where x is the number of the SAP system, e.g. 1,2,3...)

* Windows specific ports for every SAP System 445, 5985
* ASCS Ports (instance number x0): 32x0, 36x0, 39x0,  81x0, 5x013, 5x014, 5x016
* SCS Ports (instance number x1): 32x1, 33x1, 39x1, 81x1, 5x113, 5x114, 5x116
* ASCS ERS ports on Linux (instance number x2): 33x2, 5x213, 5x214, 5x216
* SCS ERS ports on Linux (instance number x3): 33x3, 5x313, 5x314, 5x316

The Load Balancer will be configured to use the following probe ports  (where x is the number of the SAP system, e.g. 1,2,3...)

ASCS/SCS Internal Load Balancer probe port: **620x0**
ERS Internal Load Balancer probe port (Linux only): **621x2**

## Virtual Machine configuration

<table>
	<tr>
		<th>SAP System count</th>
		<th>HA</th>
		<th>Non-HA</th>
	</tr>
	<tr>
		<td>2-3 (Small)</td>
		<td>2xDS2_v2 ASCS/SCS Server (1xP10 per SAP System)</td>
		<td>1xDS2_v2 ASCS/SCS Server (1xP10 per SAP System)</td>
	</tr>
	<tr>
		<td>4-7 (Medium)</td>
		<td>2xDS3_v2 ASCS/SCS Server (1xP10 per SAP System)</td>
		<td>1xDS3_v2 ASCS/SCS Server (1xP10 per SAP System)</td>
	</tr>
	<tr>
		<td>8-10 (Large)</td>
		<td>2xDS4_v2 ASCS/SCS Server (1xP10 per SAP System)</td>
		<td>1xDS4_v2 ASCS/SCS Server (1xP10 per SAP System)</td>
	</tr>
</table>