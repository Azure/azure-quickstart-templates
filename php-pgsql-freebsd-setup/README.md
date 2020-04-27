# Deployment of PHP based Web Site using FreeBSD

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/php-pgsql-freebsd-setup/CredScanResult.svg)

This template deploys a group of open source software that is typically used together to enable FreeBSD servers to host dynamic website and web apps. Here FreeBSD is the core of the platform which will sustain the other components.

1. Reverse proxy, with nginx and round-robin load balancing - It has 2 NICs – One NIC in subnet1 with both public and private IPs and the other NIC in subnet2 with a private IP.

2. PHP application servers, with nginx and php-fpm - Each one has 2 NICs – One NIC with a private IP in subnet 2 and the other NIC with a private IP in subnet3.

3. Database server, with postgreqsql and pgbouncer - It has 1 NIC with a private IP in subnet3.
