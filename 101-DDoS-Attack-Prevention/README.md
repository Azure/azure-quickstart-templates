# DDoS Protection attack on a Virtual Machine Scenario 
This repository contains DDoS attack detection on a Virtual Machine with public IP <p></p>

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-DDoS-Attack-Prevention%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/> 
</a>


<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-DDoS-Attack-Prevention%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/> 
</a>

# Table of Contents
1. [Objectives](#objectives)
2. [Overview](#overview)
3. [Pre-requisites](#prerequisites)
4. [Deploy](#deploy)
5. [Perform Attack](#attack)
6. [Detect and Mitigate Attack](#detect)
7. [References](#references)
8. [Configuration validation](#config)

<a name="objectives"></a>
# Objective of the POC  
Showcase DDoS Protection Standard on Azure resources with public IP

# Overview
It showcases following use cases
1. Perform DDoS attack on resources in a virtual network including public IP addresses associated with virtual machines by following configuration --> DDoS Protection Standard detects attack and mitigate the DDoS attack and send alert.
    * Virtual Network (VNet enabled DDoS Protection Standard)

<a name="important-notes"></a>

# Important Notes
DDoS Protection Standard protects resources in a virtual network including public IP addresses associated with virtual machines, load balancers, and application gateways. When coupled with the Application Gateway web application firewall, DDoS Protection Standard can provide full layer 3 to layer 7 mitigation capability.  
Refer [Azure DDoS Protection Standard](https://docs.microsoft.com/en-us/azure/virtual-network/ddos-protection-overview) for more details.



<a name="prerequisites"></a>

# Prerequisites
Access to Azure subscription to deploy following resources

1.  Virtual Machine with Virtual Network
2.  OMS (Monitoring)

<a name="deploy"></a>

# Deploy 
1. Deploy using "Deploy to Azure" button at the top 

Following steps are required to create email alert by metric level

1. Clone Azure quickstart templates repository using

    `git clone https://github.com/Azure/azure-quickstart-templates.git`

3. Open Windows PowerShell (Run as Administrator) and navigate to 101-DDoS-Attack-Prevention directory 
 
    `cd .\azure-quickstart-templates\101-DDoS-Attack-Prevention\`
3. Login to Azure by passing subscription id to execute script.

    `Login-AzureRmAccount -SubscriptionId "<subscription id>" `
4. Execute following command to create email alert rule

    `.\DSC\configure-metricrule.ps1 -ResourceGroupName "<ResourceGroupName>" -Location "<location>" -Email "<EmailID>" -Verbose`
    
5.  To manually configure IIS server on VM follow below steps <br />
    a. Go to Azure Portal --> Select Resource Groups services --> Select Resource Group - <ResourceGroupName> given during deployment <br />
    b. Select VM with name 'vm-with-ddos'


    ![](images/select-rg-and-vm.png)

    c. On Properties Page --> Click Connect to Download RDP file --> Save and Open RDP file.


    ![](images/click-on-connect.png)

    d. Enter login details (The VM login username and password is in deployment powershell output)
    
    e. Open Server Manager and install Web Server (IIS).


    ![](images/select-add-roles-and-feature.png)


    ![](images/install-iis-web-Server-on-VM.png)
               
    
6. To configure Azure Security Center, pass email address `<email id>` for notification

    `.\DSC\configure-azuresecuritycenter.ps1 -EmailAddressForAlerts <email id>`

7.  To create standard DDoS plan and configure with virtual network <br />

    a. Go to Azure Portal --> Click on "Create a resource" --> Search "DDoS Protection  plan"

      ![](images/ddos-standard-plan-1.png)
    
    b. Enter details 

      ![](images/ddos-standard-plan-2.png)

    c. Configure standard DDoS protection plan on VNet

      ![](images/select-standard-ddos-on-vnet.png)

<a name="attack"></a>

# Perform Attack 
 ### * Attack VM without DDoS protection & analyze <br />
Microsoft have partnered with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) to offer tooling for Azure customers to generate traffic load against DDoS Protection enabled public endpoints to simulate TCP SYN flood and DNS flood attack on the VM without DDoS Protection Standard. Create a  support request with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) for simulation of a DDoS attack on infrastructure. The team executed TCP SYN flood and DNS flood attack on the VM without DDoS Protection Standard  <br />

In this case DDoS attack can not be detected as shown in below images. <br />
To monitor from metrics to find public IP is under DDoS attack (Does not detect DDoS attack)  <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options  <br />
    - Select specific Public IP in resource option   <br />
    - "Under DDoS attack or not" in metrics filter  <br />
    

   ![](images/without-ddos-protection-under-attack.png)


To monitor from metrics to find public IP inbound packets status (Does not detect DDoS attack) <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options from metrics filter  <br />
    - inbound packets DDoS  <br />
    - inbound packets dropped DDoS  <br />
    - inbound packets forwarded DDoS  <br />


  ![](images/without-ddos-protection-inbound.png)

 ### * Attack on VM with DDoS Protection Standard <br />

Microsoft have partnered with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) to offer tooling for Azure customers to generate traffic load against DDoS Protection enabled public endpoints to simulate TCP SYN flood and DNS flood attack on the VM without DDoS Protection Standard. Create a  support request with [BreakingPoint Cloud](https://www.ixiacom.com/products/breakingpoint-cloud) for simulation of a DDoS attack on infrastructure. The team executed TCP SYN flood and DNS flood attack on the VM with DDoS Protection Standard <br />


<a name="detect"></a>

# Detect and mitigate attack
The DDoS attack on VM with DDoS Protection Standard is detected and mitigated as shown in below images. <br />
To monitor from metrics to find public IP is under DDoS attack (Detect DDoS attack)  <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options  <br />
    - Select specific Public IP in resource option   <br />
    - "Under DDoS attack or not" in metrics filter  <br />
 

   ![](images/monitoring-public-IP-under-DDoS-attack.png)


To monitor from metrics to find public IP inbound packets status (Detect DDoS attack) <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select below options from metrics filter  <br />
    - inbound packets DDoS  <br />
    - inbound packets dropped DDoS  <br />
    - inbound packets forwarded DDoS  <br />

  
   ![](images/monitoring-inbound-packets-DDoS.png)


The DDoS Protection Standard detects and mitigates the attack on VM. The below image of network metrics of VM while network in attack. <br />
To monitor network in and network out follow below steps <br />
    Azure Portal-->Resource Group --> VM --> Metrics --> Select VM name in resource --> select netork in / out in metrics filter

   ![](images/monitoring-network-in-out.png)
    

The email alert configured at metrics level, This will send the alert mail if VNet is under DDoS attack over last the 5 minutes <br />
  ( Note: Deployment UserName is used to get the email alert for DDoS attack )
  
    
   ![](images/ddoS-attack-mail-alert.png)

<a name="config"></a>
## Configuration Validation
* Distributed denial of service (DDoS) attacks are some of the largest availability and security concerns facing customers that are moving their applications to the cloud. A DDoS attack attempts to exhaust an application’s resources, making the application unavailable to legitimate users. Azure DDoS protection, combined with application design best practices, provide defense against DDoS attacks. Automatic detection and remediation procedure of such vulnerabilities can be easily done using the controls available in Cloudneeti.

* Cloudneeti is available on the Azure marketplace. Try out the free test drive here https://aka.ms/Cloudneeti 

<a name="references"></a>

**References** 


1.	 DDoS Blog: http://aka.ms/ddosblog
2.	DDoS Protection overview: http://aka.ms/ddosprotectiondocs
3.	DDoS Standard best practices & reference architecture : http://aka.ms/ddosbest 