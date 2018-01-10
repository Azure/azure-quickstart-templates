# SAP NetWeaver 3-tier multi SID AS (managed disks)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-marketplace-image-multi-sid-apps-md%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-marketplace-image-multi-sid-apps-md%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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