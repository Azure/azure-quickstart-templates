# Deploy Open edX Dogwood on multiple Ubuntu VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenedx-scalable-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenedx-scalable-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys Open edX Dogwood on multiple Ubuntu VMs. The deployment creates a scale set of application VMs behind a load balancer, plus backend VMs for Mongo and MySQL. A default server-vars.yml is saved to */edx/app/edx_ansible*.

Note the database VM names, accessible within the virtual network:
- MySQL VM: openedx-mysql
- Mongo VM: openedx-mongo

Installation can take 2+ hours after the deployment succeeds. An installation log is available on openedx-app0 at */var/log/azure/openedx-install.log*.

Connect to application VMs with `ssh {adminUsername}@{dnsLabelPrefix}.{region}.cloudapp.azure.com -p PORT`, where PORT range starts at 50000

You can learn more about Open edX here:
- [Open edX](https://open.edx.org)
- [Installation Options](https://openedx.atlassian.net/wiki/display/OpenOPS/Open+edX+Installation+Options)
- [Running FullStack](https://openedx.atlassian.net/wiki/display/OpenOPS/Running+Fullstack)
- [Source Code](https://github.com/edx/edx-platform)

*Note that this template uses a different license than the [Open edX](https://github.com/edx/edx-platform/blob/master/LICENSE) platform.*