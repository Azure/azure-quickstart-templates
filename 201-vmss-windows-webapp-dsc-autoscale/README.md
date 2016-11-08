## Create/Upgrade a VM Scale Set Running IIS Configured For Autoscale ##

The following template deploys a Windows VM Scale Set (VMSS) running an IIS .NET MVC application integrated with Azure autoscale. This template can be used to demonstrate initial rollout and confiuguration with the VMSS PowerShell DSC extension, as well as the process to upgrade an application already running on a VMSS.

### VMSS Initial Deployment ###
The template deploys a Windows VMSS with a desired count of VMs in the scale set. Once the VMSS is deployed, the VMSS PowerShell DSC extension installs IIS and a default web app from a WebDeploy package. The web app is nothing fancy, it's just the default MVC web app from Visual Studio, with a slight modification that shows the version (1.0 or 2.0) on the landing page. 

The application URL will be http://\<vmsspublicip\>/MyApp. 

### VMSS Application Upgrade ###
This template can also be used to demonstrate application upgrades for VMSS leveraging ARM template deployments and the VMSS PowerShell DSC extension. The VMSS is configured with `"upgradePolicy : { "mode" : "Automatic" }` to perfom an automatic upgrade of the VMSS. If you'd like to have control over when running VMs are upgraded, change `Automatic` to `Manual`.

### Autoscale Rules ###
The Autoscale rules are configured as follows
- Sample for Percentage CPU in each VM every 1 Minute
- If the Percentage CPU is greater than 50% for 5 Minutes, then the scale out action (add more VM instances, one at a time) is triggered
- Once the scale out action is completed, the cool down period is 1 Minute

### Parameters ###
| Parameter | Definition | Default Value |
|---|---|---|
| vmSku | Size of VMs in the VM Scale Set | Standard_A1 |
| windowsOSVersion | The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter. | 2012-R2-Datacenter |
| vmssName | String used as a base for naming resources. Must be 3-61 characters in length and globally unique across Azure. A hash is prepended to this string for some resources, and resource-specific information is appended. ||
|instanceCount| Number of VM instances (100 or less). | 3 |
|adminUsername| Admin username on all VMs. | vmssadmin |
|adminPassword|Admin password on all VMs.||
|powershelldscZip|Full URI of the PowerShell DSC zip file||
|webDeployPackage|Full URI of the WebDeploy package zip file||
|powershelldscUpdateTagVersion|Version number of the DSC deployment. Changing this value on subsequent deployments will trigger the extension to run.|1.0|

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-webapp-dsc-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-webapp-dsc-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
