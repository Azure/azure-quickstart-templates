# SAP NetWeaver 2-tier compatible template using a custom managed disk

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-disk-md/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-disk-md/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-disk-md/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-disk-md/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-disk-md/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-disk-md/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-2-tier-user-disk-md%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-2-tier-user-disk-md%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using a spezialized i.e. not generalized os disk.
This is a template for a 2-tier configuration. It deploys 1 server on Premium Storage.
This template uses Managed Disks.

<table>
	<tr>
		<th>Size</th>
		<th>Premium Storage</th>
	</tr>
	<tr>
		<td>Small < 2.000 SAPS</td>
		<td>1xDS11_v2 (2xP20 1xP10)</td>
	</tr>
	<tr>
		<td>Medium < 9.000 SAPS</td>
		<td>1xDS13_v2 (3xP20 1xP10)</td>
	</tr>
	<tr>
		<td>Large < 18.000 SAPS</td>
		<td>1xDS14_v2 (3xP30 + 1xP20)</td>
	</tr>
	<tr>
		<td>X-Large < 40.000 SAPS</td>
		<td>1xGS5 (4xP30 1xP20)</td>
	</tr>
</table>				

