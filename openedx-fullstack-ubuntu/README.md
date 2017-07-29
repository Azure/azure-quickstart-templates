# Deploy Open edX FullStack (Ficus) on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenedx-fullstack-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenedx-fullstack-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys the Open edX full stack (Ficus) on Ubuntu. A default server-vars.yml is saved to */edx/app/edx_ansible*.

Connect to the virtual machine with SSH: `ssh {adminUsername}@{dnsNameForPublicIP}.{region}.cloudapp.azure.com`. Installation log can be found under */var/log/azure*.

You can learn more about Open edX and fullstack here:
- [Open edX](https://open.edx.org)
- [Running FullStack](https://openedx.atlassian.net/wiki/display/OpenOPS/Running+Fullstack)
- [Source Code](https://github.com/edx/edx-platform)

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*
