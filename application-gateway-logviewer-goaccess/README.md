# Azure Application Gateway Log Analyzer using GoAccess

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-gateway-logviewer-goaccess%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<h2>Introduction</h2>
This template configures the <a href="https://goaccess.io">GoAccess log analyzer</a> for Azure Application Gateway access logs. Using GoAccess, users can quickly analyze and view their Application Gateway statistics in real time using their browser through generated HTML reports.
 
The template creates an Ubuntu VM under your (customer) subscription, installs Apache HTTP web server as well as the GoAccess log analyzer, and then connects the VM with the customer’s Blob container to periodically fetch incremental access logs of Application Gateway. GoAccess will parse the access logs and display rich statistics on traffic.

By default, GoAccess installed by this template will parse and display traffic stats for the past 3 days’ worth of logs, if present. 
 
<h2>Pre-requisites:</h2>
    <ol type="1">
    <li>Access to an Azure subscription to deploy a Virtual machine with a Public DNS name.</li>
    <li>Enable access logging and store logs in desired storage account as specified <a    href="https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics#diagnostic-logging">here</a>. Please also note the following:    
    <ol type="a">
        <li>Only the ApplicationGatewayAccessLog will be used by GoAccess</li>
        <li>You want to make sure you are sending and storing your ApplicationGatewayAccessLog to a storage account (select the “Archive to a storage account” check box if using the Portal to enable Application Gateway logging).</li>
        <li>In your storage account settings, ensure you have Shared Access Signature key configured. The expiry date time needs to be set to a date much further out in the future (eg: 1 year out from now). Also, only the Read and List permissions are needed for GoAccess. Make sure to generate the connection string as well.  The Blob service SAS URL connection string is what you need to input to the ARM template.</li>
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
        <li><b>appGwAccessLogsBlobSasUri:</b> The SAS URL connection string (see 2(c) in the Pre-requisites list above) for the storage account blog where your Application Gateway Access Logs are stored</li>
        <li><b>FilterRegexForAppGwAccessLogs:</b> A regex to use to filter the Application Gateway Access Logs to a specific subset. For example, if you have multiple application gateways publishing logs to the same storage account blob, and you only want GoAccess to surface traffic stats for say one of the Application Gateways, you can provide a regex for this field to filter to just that instance.</li>
        <li><b>Region:</b> The Azure region where you would like the VM to be created</li>
    </ol>

<h2>Viewing Analytics</h2>

Once the template deployment is successful, you can view the real time analytics by accessing the link <u>http://Public-DnsNameOfVM/report.html</u> where Public-DnsNameOfVM is the DNS name entered as input to the template.
 
User can view the logs based on the parameters available in the Application Gateway’s access logs. The GoAccess <a href="https://goaccess.io/man">statistics</a> that can be observed for Application Gateway are General Statistics, Unique Visitors, Requested files, Requested statics files, 404 or Not Found, Hosts, Operating Systems, Browsers, Visit Times, Virtual Hosts, Geo Location and HTTP Status Codes. For more details on these statistics please see the <a href="https://goaccess.io/man">GoAccess man</a> page. 

Please note following aspects related to this template:
    <ul>
    <li>There may be up to 5 minutes delay in seeing statistics updated on GoAccess. This is by design, due to the underlying delays in logs published to Azure storage from your application gateways.</li>
    <li>This solution may result in increased data, network, or compute resource usage in Azure. The solution may increase a customer’s Azure license or subscription costs.</li>
    <li>The time duration of logs that can be analyzed depends on the size of the RAM and disc capacity configured for the underlying VM.</li>
    </ul>

<h2>Getting Help</h2>

For any issues with running this template, please file an issue in GitHub under Azure/azure-quickstart-templates repository: <u>https://github.com/Azure/azure-quickstart-templates/issues</u>

At this time no SLA is offered for support – this is strictly for use as-is, but we will do our best in responding to issues raised. 

For any feature requests or general help with GoAccess itself, please file an issue in GitHub under the GoAccess repository: <u>https://github.com/allinurl/goaccess/issues</u>

<h2>Licensing</h2>

<h3>GoAccess</h3>
GoAccess is distributed under the MIT License.

Copyright © 2018 Microsoft Azure Application Gateway team

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<h3>Apache HTTP Web Server</h3>
Apache HTTP Web Server is distributed under the Apache 2.0 License.

Copyright 2018 Microsoft Azure Application Gateway team

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
