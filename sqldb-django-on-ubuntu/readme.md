# Deploy a Django app on Ubuntu.


| Deploy to Azure  | Author                          | Template Name   | Description     |
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://azuredeploy.net/" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [meet-bhagdev](https://github.com/meet-bhagdev) | [Deploy a Python Django app on Ubuntu which use SQL databases](https://github.com/madhana/azure-quickstart-templates/tree/master/django-app) | This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application. The template also creates a SQL Database, with a sample table with some sample data which displayed in the web browser using a query|

This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application. The template also creates a SQL Database, with a sample table with some sample data which displayed in the web browser using a query

Once the template is deployed, just grab the FQDN of the VM and open it in a browser and you'll see the sample data displayed on your screen. Make sure you wait 10-15 minutes after the tempalate is deployed before you access the DNS name. There might be a lag when accessing the dns in your browser. Please refresh your browser a few times to mitigate it.