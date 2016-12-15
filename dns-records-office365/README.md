<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgeorgewallace%2Fazure-quickstart-templates%2Fmaster%2Fdns-records-office365%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [georgewallace](https://github.com/georgewallace)

This template allows you to deploy a DNS Zone to Azure DNS with the appropriate records needed for Office 365. This template allows the user to choose what records to create, they are broken down by mail, mobile device management, and Skype for Business.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| dnsZoneName  | The name of the DNS Zone to use or create. |
| ttl | Time to live for the DNS Records. |
| artifactsBaseUrl  | URL for the additional template files.  |
| recordTypes  | The types of records to create (mail,sfb,mdm)   |
