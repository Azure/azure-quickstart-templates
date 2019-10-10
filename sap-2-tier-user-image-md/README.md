# SAP NetWeaver 2-tier compatible template using a Managed Disk image

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-image-md/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-image-md/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-image-md/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-image-md/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-image-md/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-user-image-md/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-2-tier-user-image-md%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-2-tier-user-image-md%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

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

