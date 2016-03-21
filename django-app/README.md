# Deploy a Django app on Ubuntu.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdjango-app%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdjango-app%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template uses the Azure Linux CustomScript extension to deploy an application. This example creates an Ubuntu VM, does a silent install of Python, Apache, then creates a simple Django app.It is essentially the template for the tutorial that can be found here -> http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-python-django-web-app-linux/

Once the template is deployed, just grab the FQDN of the VM and open it in a browser and you'll see the hello world app running.
