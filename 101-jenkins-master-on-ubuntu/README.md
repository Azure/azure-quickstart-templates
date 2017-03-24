# Azure hosted Jenkins Master on Ubuntu

<a href="https://aka.ms/azdeployjenkinsonubuntu" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://aka.ms/azvisualizejenkinsonubuntu" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to host an instance of Jenkins on a DS1_v2 size Linux Ubuntu 14.04 LTS VM in Azure.

After the deployment is completed, get the Jenkins DNS from the “Public IP address/DNS name label” field in the Essentials section of your Jenkins VM in the Azure portal. You can now now browse to the Jenkins instance in your browser by going to http://< your_jenkins_vm_dns >:8080.

The first time you do this, you will be asked to get the login token from /var/lib/jenkins/secrets/initialAdminPassword. To get this token, SSH into the VM using the admin user name and password you provided and run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword. Copy the token provided. Go back to the Jenkins instance in the browser and paste the token provided.

Your Jenkins instance is now ready to use! Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## Questions/Comments? azdevopspub@microsoft.com