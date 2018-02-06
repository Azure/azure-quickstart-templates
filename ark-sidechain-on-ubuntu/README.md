# Deployment of Ark.io Sidechain

<p>These buttons DO NOT WORK AT THIS TIME. Place-holders from another linux-based template.</p>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdavepinkawa%2Fazure-quickstart-templates%2Fmaster%2Fark-sidechain-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdavepinkawa%2Fazure-quickstart-templates%2Fmaster%2Fark-sidechain-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<p>This template creates an Ubuntu VM with user-specified credentials. It then sets the PublicDNS name, runs a script to install Ark dependencies, and creates a network security group for firewall settings.</p>
<p>FQDN:  PublicDNSname.datacenter-region.cloudapp.azure.com</p>
<p>To Do:</p>
<ul style="list-style-type:circle">
    <li>Additional VM sizes to choose from</li>
    <li>Variables to run node installation / setup directly at template level before login</li>
    <li>nodejs must be user-level for this to run, unfortunately</li
</ul>




