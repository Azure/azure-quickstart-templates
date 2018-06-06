# Provision jsreport service in Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fjsreport-linux-appservice-docker%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fjsreport-linux-appservice-docker%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy jsreport, an elegant service for drawing PDF Reports using HTML and handlebars Templates. You can pick from a variety of recipes aka algorithms to generate PDF using engines like PhantomPDF, Electron,Chromium,WkhtmltoPDF etc. This Template will create a Linux App Service, StorageAccount and shall pull jsreport 2.1.0-full version from Docker Registry, configure authentication and embed all the settings required to connect to a Storage Account in order to Persist the templates.

You can read my blog to know more about the usage of this template [Here](https://medium.com/@rajkumarb/continuous-integration-for-js-reports-on-azure-appservice-part-1-2a81aa55e06) 

For more information about Running jsreport in Azure, [Click Here](https://jsreport.net/blog/render-reports-using-azure-app-service).