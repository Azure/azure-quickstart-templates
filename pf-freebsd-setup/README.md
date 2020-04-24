# NAT firewall with round-robin load balancing using FreeBSD's pf

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/pf-freebsd-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/pf-freebsd-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/pf-freebsd-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/pf-freebsd-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/pf-freebsd-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/pf-freebsd-setup/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)]("https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json")  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)]("http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpf-freebsd-setup%2Fazuredeploy.json")
    


    


This template can help you deploy a NAT firewall with round-robin load balancing using FreeBSD's pf on Azure for common web server scenario where 2 FreeBSD virtual machines install the Nginix web server.

Since the front-end VM acting as the NAT has 2 NICs, please refer [**HERE**](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes) to choose satisfied VM size.

After the template deploys successfully, you can access Nginx using the public IP of front-end VM from the explorer.

