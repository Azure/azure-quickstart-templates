# Create a web app on Azure with GoLang extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a web app on azure with GoLang site extension, allowing you to run web applications developed on GoLang on Azure. Template was authored by Wade Wegner Of Microsoft. For more information about GoLang site extension see http://www.wadewegner.com/2015/01/creating-a-go-site-extension-and-resource-template-for-azure/

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| siteName  | Name of the Web App. |
| hostingPlanName  | Name for hosting plan  |
| siteLocation  | Site Location   |
| sku  | SKU ("Free", "Shared", "Basic", "Standard") |
| workerSize | Worker Size( 0=Small, 1=Medium, 2=Large ) |