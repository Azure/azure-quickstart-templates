# Azure Application Gateway Log Analyzer using GoAccess

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-logviewer-goaccess/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-logviewer-goaccess/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-logviewer-goaccess/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-logviewer-goaccess/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-logviewer-goaccess/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-logviewer-goaccess/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json)

<h2>Introduction</h2>
This template configures the <a href="https://goaccess.io">GoAccess log analyzer for Azure Application Gateway access logs. Using GoAccess, users can quickly analyze and view their Application Gateway statistics in real time using their browser through generated HTML reports.
 
The template creates an Ubuntu VM under your (customer) subscription, installs Apache HTTP web server as well as the GoAccess log analyzer, and then connects the VM with the customer’s Blob container to periodically fetch incremental access logs of Application Gateway. GoAccess will parse the access logs and display rich statistics on traffic.

By default, GoAccess installed by this template will parse and display traffic stats for the past 3 days’ worth of logs, if present. 
 
<h2>Pre-requisites:</h2>
    <ol type="1">
    <li>Access to an Azure subscription to deploy a Virtual machine with a Public DNS name.</li>
    <li>Enable access logging and store logs in desired storage account as specified <a    href="https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics#diagnostic-logging">here. Please also note the following:    
    <ol type="a">
        <li>Only the ApplicationGatewayAccessLog will be used by GoAccess</li>
        <li>You want to make sure you are sending and storing your ApplicationGatewayAccessLog to a storage account (select the “Archive to a storage account” check box if using the Portal to enable Application Gateway logging).</li>
        <li>In your storage account container, ensure you have Shared Access Signature key configured. The expiry date time needs to be set to a date much further out in the future (eg: 1 year out from now). Also, only the Read and List permissions are needed for GoAccess. Make sure to generate the connection string as well.  The Blob Container Service SAS URL connection string is what you need to input to the ARM template.
        <p>You can generate Service-level SAS URL for the Blob Container "insights-logs-applicationgatewayaccesslog" using <a href="https://azure.microsoft.com/en-in/features/storage-explorer/">Azure Storage Explorer for your operating system. Storage Explorer is available for Windows, MacOS and Linux.<br /><br />
          For example, the blob container SAS URL should look like this - <blockquote>https://[your-blob-url]/insights-logs-applicationgatewayaccesslog?st=2019-02-08T12%3A55%3A14Z&se=2020-02-09T12%3A55%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=jcfAjefo3TitH7kl9YC15COaSdfgMmPFnO8QTI6oY9c%3D</blockquote> <br /><br />
<img src="https://user-images.githubusercontent.com/6194147/52483050-f2ec1800-2bd8-11e9-8982-224ddd37dfa9.png" width="1000" title="Container SAS token generation using Azure Storage Explorer">
            <br /><br />Alternatively, you can generate the Service-level SAS using REST API. Read more about it <a href="https://docs.microsoft.com/en-us/rest/api/storageservices/constructing-a-service-sas">here.
          </li>
    </ol>
    </li>
    </ol>

<h2>Running the ARM template</h2>

Click on “Deploy to Azure” button in the template Readme.md in the ARM template. 

The template will require a set of parameters input from you as the user:
    <ol type="1">
        <li><b>adminUsername:</b> Username you want to use for the VM the template creates</li>
        <li><b>adminPassword:</b> Password you want to use to log in to the VM</li>
        <li><b>dnsNameForPublicIP:</b> The DNS name (prefix) you want to use for the VM to map against its public IP</li>
        <li><b>appGwAccessLogsBlobSasUri:</b> The SAS URL connection string (see 2(iii) in the Pre-requisites list above) for the storage account blog where your Application Gateway Access Logs are stored</li>
        <li><b>FilterRegexForAppGwAccessLogs:</b> A regex to use to filter the Application Gateway Access Logs to a specific subset. For example, if you have multiple application gateways publishing logs to the same storage account blob, and you only want GoAccess to surface traffic stats for say one of the Application Gateways, you can provide a regex for this field to filter to just that instance.</li>
        <li><b>Region:</b> The Azure region where you would like the VM to be created</li>
    </ol>

<h2>Viewing Analytics</h2>

Once the template deployment is successful, you can view the real time analytics by accessing the link <u>http://Public-DnsNameOfVM/report.html</u> where Public-DnsNameOfVM is the DNS name entered as input to the template.
 
User can view the logs based on the parameters available in the Application Gateway’s access logs. The GoAccess <a href="https://goaccess.io/man">statistics that can be observed for Application Gateway are General Statistics, Unique Visitors, Requested files, Requested statics files, 404 or Not Found, Hosts, Operating Systems, Browsers, Visit Times, Virtual Hosts, Geo Location and HTTP Status Codes. For more details on these statistics please see the <a href="https://goaccess.io/man">GoAccess man page. 

Please note following aspects related to this template:
    <ul>
    <li>There may be up to 5 minutes delay (beyond the latency in pushing logs from Application Gateways to Storage account) in seeing statistics updated on GoAccess.</li>
    <li>This solution may result in increased data, network, or compute resource usage in Azure. The solution may increase a customer’s Azure license or subscription costs.</li>
    <li>The time duration of logs that can be analyzed depends on the size of the RAM and disc capacity configured for the underlying VM.</li>
    <li>This VM periodically (every 24 hour) reports the health of the VM to the Microsoft.  The heartbeat contains the compute metadata of the VM published by Azure's <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service">instance metadata service.
    </ul>

<h2>Securing Access</h2>

By default, the GoAccess dashboard and associated data are unsecured. Since the web server is Apache HTTP Webserver, you can secure access by following the <a href="https://httpd.apache.org/docs/2.4/howto/auth.html">Apache Auth documentation.

Also, since it is a Virtual Machine, you can use <a href="https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic">Network Security Groups to allow/deny IP addresses to restrict access, but make sure that outbound internet connectivity is allowed to reach the storage account.

<h2>Getting Help</h2>

For any issues with running this template, please file an issue in GitHub under Azure/azure-quickstart-templates repository: <u>https://github.com/Azure/azure-quickstart-templates/issues</u>

At this time no SLA is offered for support – this is strictly for use as-is, but we will do our best in responding to issues raised. 

For any feature requests or general help with GoAccess itself, please file an issue in GitHub under the GoAccess repository: <u>https://github.com/allinurl/goaccess/issues</u>

<h2>License</h2>

GoAccess is distributed under the MIT License. For details of the licensing terms, please refer to the <a href="https://github.com/allinurl/goaccess/blob/master/COPYING">GoAccess License terms.

Apache HTTP Web Server is distributed under the Apache 2.0 License. For details of the licensing terms, please refer to <a href="http://www.apache.org/licenses/LICENSE-2.0">the Apache 2.0 License terms.


