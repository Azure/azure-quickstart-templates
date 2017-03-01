# Deployment of PHP based Web Site using FreeBSD

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fleifei87%2Fazure-quickstart-templates%2Fmaster%2Fphp_pgsql-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fleifei87%2Fazure-quickstart-templates%2Fmaster%2Fphp_pgsql-freebsd-setup%2Fazuredeploy.json" target="_blank"></a>

This template deploys a group of open source software that is typically used together to enable FreeBSD servers to host dynamic website and web apps. Here FreeBSD is the core of the platform which will sustain the other components. 

1.	Nginix (E): One frontend VM with reversed proxy and load balancer configured. It has 2 NICs – One NIC in subnet1 with both public and private IPs and the other NIC in subnet2 with a private IP. 

2.	PHP against web server Nginx: One php VMs to process dynamic PHP content. Each one has 2 NICs – One NIC with a private IP in subnet 2 and the other NIC with a private IP in subnet3. 

3.	Postgresql: One postgresql VM handles database management with pgbouncer installed. It has 1 NIC with a private IP in subnet3. 
