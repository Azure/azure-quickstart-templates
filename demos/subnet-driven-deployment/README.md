# Subnet-driven test lab 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/subnet-driven-deployment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/subnet-driven-deployment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/subnet-driven-deployment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/subnet-driven-deployment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/subnet-driven-deployment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/subnet-driven-deployment/CredScanResult.svg)

This template creates an environment with multiple subnets and the servers (one DC and two members) associated with. If the number of subnets varies, the servers are adjusted automatically.
 

The purpose of this template is to illustrate:

* Use of array structures in order to maximize the reuse of the linked templates. 

  * Subnet definition inside the vNet is done this way

  * The Window server template (WinServ.json) can accommodate any number of data disks because it receives them as a parameter 

* Use of outputs to get back unique IDs such as storage (instead of passing them as parameters).

* A single template for **all** domain controllers. The CreateADC template with indx=0 creates the forest, with indx!=0 will add domain controllers.

* Custom script extensions usage: Each server has **chocolatey** installed, in order to get diagnostics tools installed quickly, without changing IE protected mode, if the need arises.

* BGinfo extension is installed on both domain controllers and member servers.

## Changelog summary

**2016-02-28:** 
* A couple of dependancies optimizations (inspired by <A href="https://github.com/Azure/azure-quickstart-templates/tree/master/sharepoint-server-farm-ha">Simon's Sharepoint HA template</A>, a must-see). Better decomposition of the templates.

* Simplified parameters in the azuredeploy template. Internal names (such as VNet, loadbalancers) are generated automatically

* New parameters

  * Number of subnets (no need to change the subnets array in the variables section anymore)

  * Number of member servers per subnet parameter added.
  
* Premium storage option, for thoses who are in a hurry.

## Notes

* A minimum of two subnets is needed for this template to work

* Distinction of the PDC from the BDCs when calling the DSC template (ConfigDC.json), is done by leveraging the function (n+2)%(n+1), which returns 0 if n==0, 1 if not. The suffix is appended to the base DSC function name, branching effectively between the two DSC configurations (CrateADC\_0 & CreateADC\_1)

* If premium storage option is selected, the VMs are DS series

* Created subnets are C class (==> 172.16.X.0/24) 

## Deploying the template

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsubnet-driven-deployment%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsubnet-driven-deployment%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsubnet-driven-deployment%2Fazuredeploy.json)
    

<a href="http://armviz.io/#/?load=https%3A%2F%2Fgithub.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fsubnet-driven-deployment%2Fazuredeploy.json" target="_blank">

## Parameters

<table>
<colgroup><col/><col/><col/></colgroup>
<tr><th>Name</th><th>Description</th><th>DefaultValue</th></tr>
<tr><td>adminPassword</td><td>Admin password</td><td></td></tr>
<tr><td>adminUsername</td><td>Admin username</td><td></td></tr>
<tr><td>assetLocation</td><td>The location of resources such as templates and DSC modules that the script is dependent</td><td>https://raw.githubusercontent.com/Azure/azure-quickstart-
templates/master/301-subnet-driven-deployment/</td></tr>
<tr><td>dnsLabelPrefix</td><td>Unique public DNS label for the deployment. The fqdn will look something like &#39;dnsname.region.cloudapp.azure.com&#39;. Up to 62 chars, digits or dashes, lo
wercase, should start with a letter: must conform to &#39;^[a-z][a-z0-9-]{1,61}[a-z0-9]$&#39;.</td><td></td></tr>
<tr><td>domainName</td><td>Domain to create for the Lab</td><td>fabrikam.com</td></tr>
<tr><td>memberServersPerSubnet</td><td>Member servers for each subnet. Must be between 1 and 20</td><td>1</td></tr>
<tr><td>storageCategory</td><td>Storage type. Can be either Standard (HDD) or Premium (SSD)</td><td>Standard</td></tr>
</table>



