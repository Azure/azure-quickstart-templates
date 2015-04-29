# Deploy a Django app on Ubuntu.


| Deploy to Azure  | Author                          | Template Name   | Description     |
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdjango-app%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [madhana](https://github.com/madhana) | [Deploy a Python Django app on Ubuntu](https://github.com/Azure/azure-quickstart-templates/tree/master/django-app) | This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application.|

This template uses the Azure Linux CustomScript extension to deploy an application. This example creates an Ubuntu VM, does a silent install of Python, Apache, then creates a simple Django app.It is essentially the template for the tutorial that can be found here -> http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-python-django-web-app-linux/

Once the template is deployed, just grab the FQDN of the VM and open it in a browser and you'll see the hello world app running.

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
