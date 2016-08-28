# Ubuntu Apache2 Web server with your test page

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAlekseiPolkovnikov%2Fazure-quickstart-templates%2Falpolko%2Fubuntu-apache-test-page%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAlekseiPolkovnikov%2Fazure-quickstart-templates%2Falpolko%2Fubuntu-apache-test-page%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to quickly create an Ubuntu VM running Apache2 with the test page content you define as a parameter. This can be useful for quick validation/demo/prototyping.

## Static Test Page

To deploy a static test page:

#. Enter admin credentials for the new Web server.
#. Enter DNS name for the new Web server.
#. Enter page name, title and static HTML body markup.
#. Select resource group and location for it.
#. Deploy the template.

## PHP Test Page

To deploy a PHP test page:

#. Enter admin credentials for the new Web server.
#. Enter DNS name for the new Web server.
#. Enter page name, title and PHP body markup.
#. Set INSTALLPHP to "true".
#. Select resource group and location for it.
#. Deploy the template.

## After Deployment

Once your test Web server is created use domain name and page name you entered to access the Web page with your markup. 
Full URL to the test page will be: http://<DNS name entered>.<resource group location>.cloudapp.azure.com/<page name or none for index page>
(example: http://mytest.westeurope.cloudapp.azure.com)






