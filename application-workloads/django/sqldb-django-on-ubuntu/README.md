# Django app with SQL Databases

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/django/sqldb-django-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/django/sqldb-django-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/django/sqldb-django-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/django/sqldb-django-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/django/sqldb-django-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/django/sqldb-django-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdjango%2Fsqldb-django-on-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdjango%2Fsqldb-django-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdjango%2Fsqldb-django-on-ubuntu%2Fazuredeploy.json)

This template uses the Azure Linux CustomScript extension to deploy a Django application by creating an Ubuntu VM, doing a silent install of Python and Apache, then creating a simple Django application. The template also creates a SQL Database, with a sample table with some sample data which is displayed in the web browser using a query

Once the template is deployed, just grab the FQDN of the VM and open it in a browser and you'll see the sample data displayed on your screen. Make sure you wait 10-15 minutes after the template is deployed before you access the DNS name. There might be a lag when accessing the dns in your browser. Please refresh your browser a few times to mitigate it.


