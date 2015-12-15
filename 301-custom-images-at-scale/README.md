# Custom Images at Scale

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-custom-images-at-scale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This tempalte deploys custom images at scale with options to use VM Scale Sets, regular VMs, or regular VMs in an availability set.  It is designed so that it can be called from other templates, and you can build on top of it.  The individual VMs that get created do not have public IPs, but a machine that can be used as a jump box is available.  (You can delete the extra machine after deployment, but it is required as part of the process.)


