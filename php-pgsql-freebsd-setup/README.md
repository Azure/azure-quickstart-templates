# Deployment of PHP based Web Site using FreeBSD

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fphp_pgsql-freebsd-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fphp_pgsql-freebsd-setup%2Fazuredeploy.json" target="_blank"></a>

This template deploys a group of open source software that is typically used together to enable FreeBSD servers to host dynamic website and web apps. Here FreeBSD is the core of the platform which will sustain the other components. 

1.	Reverse proxy, with nginx and round-robin load balancing - It has 2 NICs – One NIC in subnet1 with both public and private IPs and the other NIC in subnet2 with a private IP. 

2.	PHP application servers, with nginx and php-fpm - Each one has 2 NICs – One NIC with a private IP in subnet 2 and the other NIC with a private IP in subnet3. 

3.	Database server, with postgreqsql and pgbouncer - It has 1 NIC with a private IP in subnet3.


