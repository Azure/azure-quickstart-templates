# Subnet-driven test lab 

This template creates an environment with multiple subnets and the servers (one DC and two members) associated with. If the number of subnets varies, the servers are adjusted automatically.
 

The purpose of this template is to illustrate:

* Use of array structures in order to maximize the reuse of the linked templates. 

  * Subnet definition inside the vNet is done this way

  * The member server template can accomodate any number of data disks because it receives them as a parameter 

* Use of outputs to get back unique IDs such as storage (instead of passing them as parameters).

* A single template for **all** domain controllers. The CreateADC template with indx=0 creates the forest, with indx!=0 will add domain controllers.

* Custom script extensions usage: Each server has **chocolatey** installed, in order to get diagnostics tools installed quickly, without changing IE protected mode, if the need arises.

* BGinfo extension is installed on both domain controllers and member servers.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-subnet-driven-deployment%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fgithub.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-subnet-driven-deployment%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
