# Template for a 3-tier configuration suitable for SAP NetWeaver

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-user-image%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-3-tier-user-image%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using a private OS image. This is a template for a 3-tier configuration. It deploys 1 (no HA) or 2 (HA) ASCS servers, 1 (no HA) or 2 (HA) database servers and serveral virtual machines that can host dialog instances. In case of a HA deployment, the ASCS and DB servers are placed in Availability Sets and a Load Balancer is added to the ASCS and DB server to allow HA configurations in the operating system (e.g. Windows Failover Cluster).

ASCS Internal Load Balancer ports: 445, 3200, 3300, 3600, 3900, 50013, 50014, 50016, 51013, 51014

ASCS Internal Load Balancer probe port: 62300

DB Internal Load Balancer ports: 1433

DB Internal Load Balancer probe port: 62300

<table>
	<tr>
		<th>Size</th>
		<th>HA</th>
		<th>Non-HA</th>
	</tr>
	<tr>
		<td>Small < 30.000 SAPS</td>
		<td>2xGS2 DB Server (4xP20 1xP20) + 3xD13 ASCS + DI</td>
		<td>1xGS2 DB Server (4xP20 1xP20) + 2xD13 ASCS + DI</td>
	</tr>
	<tr>
		<td>Medium < 70.000 SAPS</td>
		<td>2xGS3 DB Server (6xP20 1xP20) + 6xD13 ASCS + DI</td>
		<td>1xGS3 DB Server (6xP20 1xP20) + 5xD13 ASCS + DI</td>
	</tr>
	<tr>
		<td>Large < 180.000 SAPS</td>
		<td>2xGS4 DB Server (5xP30 1xP20) + 2xD11 ASCS + 6xDS14 DI</td>
		<td>1xGS4 DB Server (5xP30 1xP20) + 6xD14 ASCS + DI</td>
	</tr>
	<tr>
		<td>X-Large < 250.000 SAPS</td>
		<td>2xGS5 DB Server (6xP30 1xP30) + 2xD11 ASCS + 10xD14 DI</td>
		<td>1xGS5 DB Server (6xP30 1xP30) + 10xD14 ASCS + DI</td>
	</tr>
</table>				
