# Deploy Badgr-Server FullStack on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsatyarapelly%2Fazure-quickstart-templates%2Fmaster%2Fbadgr-fullstack-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fsatyarapelly%2Fazure-quickstart-templates%2Fmaster%2Fbadgr-fullstack-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys the Badgr Server web application (concentricsky) on Ubuntu. 

Connect to the virtual machine with SSH: `ssh {adminUsername}@{dnsNameForPublicIP}.{region}.cloudapp.azure.com`. Installation log can be found under */var/log/azure*.

You can learn more about Badgr Server here:
- [Badgr Server](https://badgr.io)
- [Source Code](https://github.com/concentricsky/badgr-server)
- [Concentric Sky](https://concentricsky.com)

*Note that this template uses a different license than the [ConcentricSky](https://github.com/concentricsky/badgr-server/blob/master/LICENSE) platform.*