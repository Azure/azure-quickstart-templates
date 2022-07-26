# Create Azure Firewall, Firewall Policy with Explicit Proxy referencing IP Groups

![Azure Public Test Date]()
![Azure Public Test Result]()

![Azure US Gov Last Test Date]()
![Azure US Gov Last Test Result]()

![Best Practice Check]()
![Cred Scan Check]()

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-with-firewallpolicy-explicitproxy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-ipgroups%2Fazuredeploy.json)

This template deploys an Azure Firewall, Firewall Policy with Explicit Proxy and IP Groups in network  rules.

With explicit proxy, customers will have the ability to define proxy settings in the browser to point to the firewall ILB, either manually configuring the browser with the IP address of the proxy or with a PAC (Proxy Auto Config) file.  
In this mode, the traffic is sent to the Firewall using a UDR (user defined routing) configuration: the Firewall intercepts that traffic inline, and passes it to the destination.