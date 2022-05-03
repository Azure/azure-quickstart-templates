# Alsid Syslog/Sentinel proxy
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alsid-syslog-proxy/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alsid-syslog-proxy/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alsid-syslog-proxy/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alsid-syslog-proxy/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alsid-syslog-proxy/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alsid-syslog-proxy/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Falsid-syslog-proxy%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Falsid-syslog-proxy%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Falsid-syslog-proxy%2Fazuredeploy.json)

This template deploys an **Alsid Syslog/Sentinel proxy**. The solution consists of a publicly addressable Ubuntu virtual machine with a **Syslog server** and a **Microsoft Azure Sentinel agent** ready to receive logs from **Alsid for AD**.

## Usage instructions

### Connect to the server
You can connect to the server through SSH on port 22.

### Configure Alsid Syslog alerting
On your **Alsid for AD** portal, go to *System*, *Configuration* and then *Syslog*.
From there you can create a new Syslog alert toward your Syslog server.

The Server is configured by default to listen on port 514 for UDP and 1514 for TCP (without TLS).

### Configure Sentinel log collection
The server gathers the log but you still need to configure log collection for your workspace on the azure portal because the Azure CLI doesn't support log collection yet.
To do this

Configure the agent to collect the logs.

1.  Under workspace advanced settings **Configuration**, select **Data** and then **Custom Logs**

2.  Select **Apply below configuration to my machines** and click **Add**.

4. Upload a sample AFAD Syslog file from the virtual machine running the **Syslog** server and click **Next**. Such a file can be found [here](https://github.com/Azure/azure-quickstart-templates/blob/master/demos/alsid-syslog-proxy/logs/AlsidForAD.log)

5. Set the record delimiter to **New Line** if not already the case and click **Next**.

6. Select **Linux** and enter the file path (by default it is /var/log/AlsidForAD.log) to the **Syslog** file, click **+** then **Next**.

7. Set the **Name** to *AlsidForADLog_CL* then click **Done** (Azure automatically adds *_CL* at the end of the name, there must be only one, make sure the name is not *AlsidForADLog_CL_CL*).

All of theses steps are showcased [here](https://www.youtube.com/watch?v=JwV1uZSyXM4&feature=youtu.be) as an example

`Tags: alsid, syslog, sentinel, proxy`
