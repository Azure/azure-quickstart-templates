# VM-Redhat - JBoss EAP 7 cluster mode
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fjboss-eap-clustered-rhel7%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fjboss-eap-clustered-rhel7%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a web applicaton deployed on JBoss EAP 7 cluster running on RHEL 7.

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

1. Input an admin username and password for your VM.  

2. Input a name for your VM.

3. Input EAP username and password to enable the EAP manager UI and deployment method.

4. Input username and password to registry Red Hat Subscription for JBoss EAP Installation.

5. Input a passphrase to use with your SSH certificate.  This pass phrase will be used as the Team Services SSH endpoint passphrase.

6. Input the number of JBoss EAP instances to cluster across multiple VMs.

The deployment will take about 70 minutes. Once completed, the notification will display:

## After you Deploy to Azure

Once you create the VM, open a web broser and got to http://<PUBLIC_HOSTNAME>:8080/eap-session-replication/ and you should see the applicaiton running

## Notes