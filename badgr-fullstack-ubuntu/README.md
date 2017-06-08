# Deploy Open edX FullStack (Dogwood) on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/azuredeploy.json

This template deploys the Open edX full stack (Dogwood) on Ubuntu. A default server-vars.yml is saved to */edx/app/edx_ansible*.

Connect to the virtual machine with SSH: `ssh {adminUsername}@{dnsNameForPublicIP}.{region}.cloudapp.azure.com`. Installation log can be found under */var/log/azure*.

You can learn more about Open edX and fullstack here:
-- TODO --

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*