# SAP NetWeaver 2-tier compatible template using a Marketplace image

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-marketplace-image-md/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-marketplace-image-md/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-marketplace-image-md/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-marketplace-image-md/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-marketplace-image-md/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sap-2-tier-marketplace-image-md/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-2-tier-marketplace-image-md%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-2-tier-marketplace-image-md%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using the latest patched version of the selected operating system. 
This is a template for a 2-tier configuration. It deploys 1 server on Premium Storage.
This template uses Managed Disks.

There is not suitable configuration for X-Large with Standard Storage. If you select this configuration, the template will deploy a Large configuration.

<table>
	<tr>
		<th>Size</th>
		<th>Premium Storage (Data Log)</th>
	</tr>
	<tr>
		<td>Demo</td>
		<td>1xStandard_D2s_v3 (1xP10 1xP10)</td>
	</tr>
	<tr>
		<td>Small < 2.000 SAPS</td>
		<td>1xStandard_E2s_v3 (2xP20 1xP10)</td>
	</tr>
	<tr>
		<td>Medium < 9.000 SAPS</td>
		<td>1xStandard_E8s_v3 (3xP20 1xP10)</td>
	</tr>
	<tr>
		<td>Large < 18.000 SAPS</td>
		<td>1xStandard_E16s_v3 (3xP30 + 1xP20)</td>
	</tr>
	<tr>
		<td>X-Large < 40.000 SAPS</td>
		<td>1xStandard_E64s_v3 (4xP30 1xP20)</td>
	</tr>
</table>				

