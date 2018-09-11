# Azure Application Gateway Log Analyzer using GoAccess

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template configures the <a href="https://goaccess.io">GoAccess log analyzer</a> for Azure Application Gateway access logs. Using GoAccess, users can quickly analyze and view their Application Gateway statistics in real time using their browser through generated HTML reports.

The template creates an Ubuntu VM, installs Apache2 as well as GoAccess log analyzer and then connects the VM with the customer’s Blob container to periodically fetch incremental access logs of Application Gateway. 
 
<b>Pre-requisites:</b>
1.	Access to an Azure subscription to deploy a Virtual machine with a Public DNS name.
2.	Enable access logging and store logs in desired storage account as specified <a href="https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics#diagnostic-logging">here</a>.
 
Once the deployment is successful, the user can view the real time analytics by accessing the link <u>http://Public-DnsNameOfVM/report.html</u> where Public-DnsNameOfVM is the DNS name entered as input to the template.

User can view the logs based on the parameters available in the Application Gateway’s access logs. The GoAccess <a href="https://goaccess.io/man">statistics</a> that can be observed for Application Gateway are General Statistics, Unique Visitors, Requested files, Requested statics files, 404 or Not Found, Hosts, Operating Systems, Browsers, Visit Times, Virtual Hosts, Geo Location and HTTP Status Codes.

Please note following aspects related to this template:
<ul>
    <li>This solution may result in increased data, network, or compute resource usage in Azure. The solution may increase a customer’s Azure license or subscription costs.</li>
    <li>The time duration of logs that can be analyzed depends on the size of the RAM and disc capacity configured for the underlying VM.</li>
</ul>
