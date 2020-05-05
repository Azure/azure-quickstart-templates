# Netki Wallet Name Server 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/netki-wns-api-server-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/netki-wns-api-server-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/netki-wns-api-server-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/netki-wns-api-server-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/netki-wns-api-server-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/netki-wns-api-server-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnetki-wns-api-server-on-ubuntu%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnetki-wns-api-server-on-ubuntu%2Fazuredeploy.json)

The Netki Wallet Name lookup API server allows you to quickly integrate the Wallet Name standard into your digital 
currency platform. Using the Wallet Name Service allows you to avoid difficult to remember Bitcoin, Ethereum, Factoid, 
etc. addresses and instead use a much more memorable naming scheme that runs on top of DNS using DNSSEC to keep the 
Chain-of-Trust unbroken.

This template deploys an Ubuntu image with the Docker extension. A Dockerfile is then fetched from the Netki Github, 
built, and run. After your template fully deploys, you will be able to perform a Wallet Name lookup by accessing the 
public instance name or IP of your VM. 

# Use
####Lookup Format
```
http://<AZUREPUBLICDNSNAME>/api/wallet_lookup/<WALLET_NAME>/<CURRENCY>
```

#### Example Request URL
```
http://netkiwnsapiserver.westus.cloudapp.azure.com/api/wallet_lookup/batman.tip.me/btc
```

#### Example Response
```
{
    "currency": "btc", 
    "message": "", 
    "wallet_name": "batman.tip.me", 
    "wallet_address": "1CHFXnewd2ZoMfEUAHELgmk8SEY6pjbpKu", 
    "success": true
}
```

To access the Docker container, review API server logs, or change the API server configuration SSH to the VM and run 
the following command:
```
docker exec -i -t netki-wns-api-server bash
```

# Additional Information
This template is useful in a development / testing capacity due to the lack of SSL enforcement on the API lookup call. 
Be sure to secure this deployment for production use.

Additionally, Namecoin lookups are performed against the Netki open API server to avoid the cost of running a Namecoin 
node in Azure. We have a Dockerfile [here](https://github.com/netkicorp/wns-api-server/blob/master/Dockerfile) that 
will setup and deploy an environment with a Namecoin node if you prefer that option.

For more information on supported currency types and their abbreviations, please visit the [Netki Apiary documentation]
(http://docs.netki.apiary.io/#reference/partner-api/wallet-name-management)

For more information on Wallet Names and additional open source software offerings, please visit our 
[Developers](https://www.netki.com/#/developers) page


