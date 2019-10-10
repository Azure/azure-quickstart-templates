# VM-Redhat - JBoss EAP 7 standalone mode

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jboss-eap-standalone-rhel7/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jboss-eap-standalone-rhel7/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jboss-eap-standalone-rhel7/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jboss-eap-standalone-rhel7/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jboss-eap-standalone-rhel7/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jboss-eap-standalone-rhel7/CredScanResult.svg" />&nbsp;
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fvsts-tomcat-redhat-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fvsts-tomcat-redhat-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

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

Once you create the VM, open a web broser and got to http://<PUBLIC_HOSTNAME>:8080/dukes/ and you should see the applicaiton running
If you want to access the administration console go to http://<PUBLIC_HOSTNAME>:8080 and click on the link Administration Console 

## Notes

If you don't have a Red Hat subscription to install a JBoss EAP, you can go through WildFly(JBoss EAP Upstream project) instead of EAP:

*  <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/wildfly-standalone-centos7" target="_blank"> [Red Hat WildFly 16 on an Azure VM]</a> - Standalone WildFly 16 with a sample web app on a CentOs 7 Azure VM.


