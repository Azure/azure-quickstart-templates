# OPNsense Firewall on FreeBSD VM

<a href="" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template allows you to deploy an OPNsense Firewall VM using the opnsense-bootsrtap installation method. It creates an FreeBSD VM, does a silent install of OPNsense using a modified version of opnsense-bootstrap.sh with the settings provided.

The login credientials are set during the installation process to:

user: root

pass: opnsense


Please change the default password and update the Network Security Group to remove access via public ip!

After deployment, you can go to https://PublicIP-DNSName:443 , then input the user and password, to configure the OPNsense firewall.