# VM-Redhat - JBoss EAP 7 standalone mode

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jboss/jboss-eap-standalone-rhel7/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jboss/jboss-eap-standalone-rhel7/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jboss/jboss-eap-standalone-rhel7/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jboss/jboss-eap-standalone-rhel7/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jboss/jboss-eap-standalone-rhel7/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jboss/jboss-eap-standalone-rhel7/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjboss%2Fjboss-eap-standalone-rhel7%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjboss%2Fjboss-eap-standalone-rhel7%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjboss%2Fjboss-eap-standalone-rhel7%2Fazuredeploy.json)

This template deploys a web applicaton deployed on JBoss EAP 7 running on RHEL 7. 

`Tags: JBoss, EAP, Red Hat,EAP7`

To obtain a rhsm account go to: www.redhat.com and sign in.

## Solution overview and deployed resources
This template creates all of the compute resources to run JBoss EAP 7 on top of RHEL 7.2, deploying the following components:
- RHEL 7.2 VM 
- Public DNS 
- Private Virtual Network 
- Security Configuration 
- JBoss EAP 7
- Sample application deployed to JBoss EAP 7

To learn more about JBoss Enterprise Application Platform, check out:
https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/

## Before you Deploy to Azure

To create the VM, you will need to:

1. Choose an admin user name and password for your VM.  

2. Choose a name for your VM. 

3. Choose a EAP user name and password to enable the EAP manager UI and deployment method. 

4. Choose a Pass phrase to use with your SSH certificate.  This pass phrase will be used as the Team Services SSH endpoint passphrase.

## After you Deploy to Azure

Once you create the VM, open a web broser and got to http://<PUBLIC_HOSTNAME>:8080/dukes/ and you should see the application running
If you want to access the administration console go to http://<PUBLIC_HOSTNAME>:8080 and click on the link Administration Console 

## Notes

If you don't have a Red Hat subscription to install a JBoss EAP, you can go through WildFly(JBoss EAP Upstream project) instead of EAP:

*  <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/wildfly-standalone-centos7" target="_blank"> [Red Hat WildFly 16 on an Azure VM] - Standalone WildFly 16 with a sample web app on a CentOs 7 Azure VM.



