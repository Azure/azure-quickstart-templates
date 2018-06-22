## Create/Upgrade a VM Scale Set Running IIS Configured For Autoscale ##

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-webapp-dsc-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-webapp-dsc-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The following template deploys a Windows VM Scale Set (VMSS) running an IIS .NET MVC application integrated with Azure autoscale. This template can be used to demonstrate initial rollout and confiuguration with the VMSS PowerShell DSC extension, as well as the process to upgrade an application already running on a VMSS.

### VMSS Initial Deployment ###
The template deploys a Windows VMSS with a desired count of VMs in the scale set. Once the VMSS is deployed, the VMSS PowerShell DSC extension installs IIS and a default web app from a WebDeploy package. The web app is nothing fancy, it's just the default MVC web app from Visual Studio, with a slight modification that shows the version (1.0 or 2.0) on the landing page. 

The application URL is an output on ARM template. It's http://\<vmsspublicipfqdn>\/MyApp or http://\<vmsspublicip\>/MyApp. 

### VMSS Application Upgrade ###
This template can also be used to demonstrate application upgrades for VMSS leveraging ARM template deployments and the VMSS PowerShell DSC extension. 

When performing the upgrade you'll want to do two things. First, change the path of the `webDeployPackage` to `DefaultASPWebApp.v2.0.zip`, this will ensure you get the updated version of the WebDeploy package. Second change the value of `powershelldscUpdateTagVersion` to `2.0`, this ensures the DSC extension is triggered and the WebDeploy package is deployed to the VMSS. Ensure all other parameters of the template are the same as your original deployment. Once deployed, visit the applicaion URL and confirm that the page shows version 2.0.

The VMSS is configured with `"upgradePolicy : { "mode" : "Automatic" }` to perfom an automatic upgrade of the VMSS. If you'd like to have control over when running VMs are upgraded, change `Automatic` to `Manual`. Automatic upgrades can incur downtime as all VMs are upgraded at the same time. For more information please see the Azure doc [Upgrade a virtual machine scale set](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-upgrade-scale-set). 

### Autoscale Rules ###
The Autoscale rules are configured as follows
- Sample for Percentage CPU in each VM every 1 Minute
- If the Percentage CPU is greater than 50% for 5 Minutes, then the scale out action (add more VM instances, one at a time) is triggered
- Once the scale out action is completed, the cool down period is 1 Minute


Tags: `VMSS, VM Scale Set, Windows, DSC Extension`


