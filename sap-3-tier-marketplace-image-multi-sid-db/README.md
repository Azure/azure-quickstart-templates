# SAP NetWeaver 3-tier compatible template using a Marketplace image (Multi SID - Database Servers)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-marketplace-image-multi-sid-db%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-marketplace-image-multi-sid-db%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template is one of three templates for a 3-tier Multi SID SAP depoyment.

* [ASCS/SCS servers template](https://github.com/Azure/azure-quickstart-templates/tree/master/sap-3-tier-marketplace-image-multi-sid-xscs)
* Database servers Template (this template)
* [Application servers template](https://github.com/Azure/azure-quickstart-templates/tree/master/sap-3-tier-marketplace-image-multi-sid-apps)

 It takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using the latest patched version of the selected operating system. This is a template for a 3-tier Multi SID configuration. It deploys 1 (no HA) or 2 (HA) database servers for one SAP system. In case of a HA deployment, the database servers are placed in an Availability Set and a Load Balancer is added to the database servers to allow HA configurations in the operating system (e.g. Windows Failover Cluster).

## DB Internal Load Balancer ports

* DB Internal Load Balancer ports (for SQL Server): 1433
* DB Internal Load Balancer ports (for SAP HANA): 30415, 30417 

DB Internal Load Balancer probe port: **62504**

## Virtual Machine configuration

<table>
	<tr>
		<th>Size</th>
		<th>HA</th>
		<th>Non-HA</th>
	</tr>
	<tr>
		<td>Demo</td>
		<td>2xDS12_v2 DB Server (1xP10)</td>
		<td>1xDS12_v2 DB Server (1xP10)</td>
	</tr>
	<tr>
		<td>Small < 30.000 SAPS</td>
		<td>2xDS13_v2 DB Server (4xP20 1xP20)</td>
		<td>1xDS13_v2 DB Server (4xP20 1xP20)</td>
	</tr>
	<tr>
		<td>Medium < 70.000 SAPS</td>
		<td>2xDS14_v2 DB Server (6xP20 1xP20)</td>
		<td>1xDS14_v2 DB Server (6xP20 1xP20)</td>
	</tr>
	<tr>
		<td>Large < 180.000 SAPS</td>
		<td>2xGS4 DB Server (5xP30 1xP20)</td>
		<td>1xGS4 DB Server (5xP30 1xP20)</td>
	</tr>
	<tr>
		<td>X-Large < 250.000 SAPS</td>
		<td>2xGS5 DB Server (6xP30 1xP30)</td>
		<td>1xGS5 DB Server (6xP30 1xP30)</td>
	</tr>
</table>