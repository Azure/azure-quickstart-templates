# Deployment of PHP based Web Site using FreeBSD

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/php-pgsql-freebsd-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/php-pgsql-freebsd-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/php-pgsql-freebsd-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/php-pgsql-freebsd-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/php-pgsql-freebsd-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/php-pgsql-freebsd-setup/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fphp-pgsql-freebsd-setup%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fphp-pgsql-freebsd-setup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fphp-pgsql-freebsd-setup%2Fazuredeploy.json)
This template deploys a group of open source software that is typically used together to enable FreeBSD servers to host dynamic website and web apps. Here FreeBSD is the core of the platform which will sustain the other components.

1. Reverse proxy, with nginx and round-robin load balancing - It has 2 NICs – One NIC in subnet1 with both public and private IPs and the other NIC in subnet2 with a private IP.

2. PHP application servers, with nginx and php-fpm - Each one has 2 NICs – One NIC with a private IP in subnet 2 and the other NIC with a private IP in subnet3.

3. Database server, with postgreqsql and pgbouncer - It has 1 NIC with a private IP in subnet3.
