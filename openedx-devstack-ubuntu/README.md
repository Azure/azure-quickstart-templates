# Deploy Open edX DevStack on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenedx-devstack-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenedx-devstack-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys the Open edX developer stack on Ubuntu.

Connect to the virtual machine with SSH: `ssh vagrant@{dnsNameForPublicIP}.{region}.cloudapp.azure.com`. Installation log can be found under */var/log/azure*.

You can learn more about Open edX and devstack here:
- [Open edX](https://open.edx.org)
- [Running DevStack](https://openedx.atlassian.net/wiki/display/OpenOPS/Running+Devstack)
- [Source Code](https://github.com/edx/edx-platform)

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*