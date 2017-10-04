# DNS Zones and records for Office 365

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdns-records-office365%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdns-records-office365%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## Solution overview and deployed resources

This template allows you to deploy a DNS Zone to Azure DNS with the appropriate records needed for Office 365. This template allows the user to choose what records to create, they are broken down by mail, mobile device management, and Skype for Business.

The following resources are deployed as part of the solution

### DNS Zone

A DNS zone is created to host the records for Office 365. Various record-sets are created depending on the services you use and are listed below.

#### Exchange (mail)

+ **MX Record**: Routes email from your domain to Office 365
+ **autodiscover CNAME record**: Email (Exchange) Autodiscover CNAME record.
+ **msoid CNAME record**: Directs authenticated to the correct platform

#### Skype for Business (sfb)

+ **lyncdiscover CNAME record**: Skype for Business Online Autodiscover CNAME record.
+ **sip CNAME record**: Directs VOIP calls
+ **SPF TXT record**: Prevents spam
+ **sipdir SRV record**: Service record for SIP communications
* **sipfed SRV record**: Service record for SIP communications

#### Mobile Device Management (mdm)

* **enterprise enrollment CNAME record**: Eases enrollment process for mobile devices
* **enterprise registration CNAME record**: Workplace join (device registration discovery)

