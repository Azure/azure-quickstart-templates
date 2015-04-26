# Deploy a Django app on Ubuntu.


| Deploy to Azure  | Author                          | Template Name   | Description     |
|:-----------------|:--------------------------------| :---------------| :---------------|
| <a href="https://azuredeploy.net/" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [madhana](https://github.com/madhana) | [Deploy a Python Django app on Ubuntu](https://github.com/azurermtemplates/azurermtemplates/tree/master/deploy-lamp-app) | This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application.|

This template uses the Azure Linux CustomScript extension to deploy an application. This example creates an Ubuntu VM, does a silent install of Python, Apache, then creates a simple Django app.It is essentially the template for the tutorial that can be found here -> http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-python-django-web-app-linux/

Once the template is deployed, just grab the public IP address of the VM and open it in a browser and you'll see the hello world app running.
