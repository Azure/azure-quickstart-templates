# Django app with SQL Databases

| Deploy to Azure  | Author                          | Template Name   | Description     |
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmeet-bhagdev%2Fazure-quickstart-templates%2Fmaster%2Fsqldb-django-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [meet-bhagdev](https://github.com/meet-bhagdev) | [Deploy a Python Django app on Ubuntu which use SQL databases](https://github.com/meet-bhagdev/azure-quickstart-templates/tree/master/sqldb-django-on-ubuntu) | This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application. The template also creates a SQL Database, with a sample table with some sample data which is displayed in the web browser using a query|

This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application. The template also creates a SQL Database, with a sample table with some sample data which is displayed in the web browser using a query

Once the template is deployed, just grab the FQDN of the VM and open it in a browser and you'll see the sample data displayed on your screen. Make sure you wait 10-15 minutes after the template is deployed before you access the DNS name. There might be a lag when accessing the dns in your browser. Please refresh your browser a few times to mitigate it.


Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName    | Name of the storage account to create    |
| location  | Location where to deploy the resource  |
| adminUsername | Admin username for the VM |
| adminPassword | Admin password for the VM |
| imagePublisher | Image Publisher for the OS disk, eg., Canonical |
| imageOffer | Image Offer for the OS disk eg., UbuntuServer |
| imageSKU | Image SKU for the OS disk  eg., 14.10-DAILY|
| vmDnsName | DNS Name |
| administratorLogin | Admin username for SQL Database |
| administratorLoginPassword | Admin password for SQL Database |
| databaseName | Name of your SQL Database |
| serverLocation | Location of your server - for example West US |
| serverName | Unique name of your SQL Server |
| firewallStartIp | Start IP for your firewall rule, for example 0.0.0.0 |
| firewallEndIp | End IP for your firewall rule, for example 255.255.255.255 | 