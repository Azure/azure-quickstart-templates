# Create VM tutorial runbook, Automation credential, and start a job

This sample shows how you can deploy a runbook, a credential the runbook relies on, and how to start a job through an Azure Resource Manager template. 

It contains a sample script, Deploy-ThroughARM, that you can use to get you started with the deployment. 

##Resources Deployed
###Automation Account
This is the account that will contain your credentials. If you want to deploy to an existing account, make sure that the Resource Group, region, tags, and SKU in the template are all the same as your existing account, otherwise the properties will be overwritten. 

###Runbook
The runbook provides an example of how you can authenticate to Azure and use Azure cmdlets in a runbook. It uses an Azure AD organizational ID to connect to Azure. It then prints out the first 10 VMs in your account.

###Credential
The credential should contain the username and password of the Azure AD organizalation ID to connect to Azure.  To learn about how to create this user, see [Get set up to automate Azure]("http://aka.ms/getsetuptoautomate") and check out this blog post [Authenticating to Azure using Active Directory]("http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/").  

###Job
A job will be triggered once the other resources are deployed.  The job needs a unique GUID as the jobName.  You can use this to identify the job later in your script and to retrieve the job output.  
