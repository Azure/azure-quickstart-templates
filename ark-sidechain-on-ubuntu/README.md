# Deployment of Ark.io Sidechain

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdavepinkawa%2Fazure-quickstart-templates%2Fmaster%2Fark-sidechain-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdavepinkawa%2Fazure-quickstart-templates%2Fmaster%2Fark-sidechain-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<p>This template creates an Ubuntu VM with user-specified credentials. It then sets the PublicDNS name, runs a script to install Ark dependencies, and creates a network security group for firewall settings.</p>
<p>FQDN:  PublicDNSname.datacenter-region.cloudapp.azure.com</p>
<p>Once the server is fully deployed, run: <p> 
```curl -o- https://raw.githubusercontent.com/davepinkawa/azure-quickstart-templates/master/ark-sidechain-on-ubuntu/Script/arksidechaindeploy.sh | bash```

<p>To Do:</p>
<ul style="list-style-type:circle">
    <li>nodejs must be user-level for this to run, unfortunately. Therefore it is not possible for me to run the full installation as part of a script at this time</li
</ul>




