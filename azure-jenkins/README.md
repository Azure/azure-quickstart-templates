# Host Jenkins in an Azure VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an instance of Azure Jenkins. Azure Jenkins is a fully functional instance of Jenkins 2.7.2 pre-configured to use Azure resources. The current version of this image lets you use Azure as a package repository to upload and download your application and it's dependencies to Azure as part of a Jenkins continuous deployment v2 pipeline.

## Deploy Azure Jenkins VM
A1. Click "Deploy to Azure" button. If you haven't got an Azure subscription, it will guide you on how to signup for a free trial.
A2. Enter a valid name for the VM, as well as a user name and password that you will use to login remotely to the VM via SSH.
A3. Remember these. You will need this to access the VM next.

## Login remotely to the VM via SSH
Once the VM has been deployed, note down the IP generated in the Azure portal for the VM with the name you supplied. To login -
- If you are using Windows client you can use Putty or any bash shell on Windows to login to the VM with the username and password you supplied.
- If you are using Linux or Mac use Terminal to login to the VM with the username and password you supplied.

## Configure placehoder Jenkins jobs
B1. Once you are logged into the VM, run /opt/azure_jenkins_config/config_azure.sh. This script will guide you to set up the storage account needed for Azure Storage Jenkins plugin.
   > Note 1: If the script doesn't exist inside the above directory, download it using below command.

   ```bash
   sudo wget -O /opt/azure_jenkins_config/config_azure.sh "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/azure-jenkins/setup-scripts/config_azure.sh"
   ```
   > Note 2: You can always run /opt/azure_jenkins_config/clear_storage_config.sh to reset configurations of Azure Storage for Jenkins and then run #1 again.

B2. Login to your Azure account using the live id you used when creating your Azure subscription or with any valid user in your Azure subscription.
B3. Select the subscription you want to use if you have more than one.
B4. Select the storage account you want to use if you have more than one.
B5. Select the destination container you will upload files to if you have more than one.
B6. Select a subscription to set up service principal. Remember the returned subscription ID, client ID, client secret and OAuth 2.0 Token Endpoint. You'll need them for Azure slave plugin configuration.

## Configure [Azure slave plugin](https://github.com/jenkinsci/azure-slave-plugin/tree/ARM-dev) : Azure profile configuration
C1. Within the Jenkins dashboard, click Manage Jenkins --> Configure System --> Scroll to the bottom of the page
   and find the section with the dropdown "Add new cloud" --> click on it and select "Microsoft Azure"
C2. Enter the subscription ID, Client ID, Client Secret and the OAuth 2.0 Token Endpoint.
C3. Click on “Verify configuration” to make sure that the profile configuration is done correctly.
C4. Save and continue with the template configuration (See instructions below)

## Configure [Azure slave plugin](https://github.com/jenkinsci/azure-slave-plugin/tree/ARM-dev) : Template configuration.
D1. Click on the "Add" option to add a template. A template is used to define an Azure slave configuration, like
   its VM  size, its region, or its retention time.
D2. Provide a name for your new template. This field is not used for slave provisioning.
D3. For the description, provide any remarks you wish about this template configuration. This field is not
   used for slave provisioning.
D4. For the label, provide any valid string. E.g. “windows” or “linux”. The label defined in a template can be
   used during a job configuration.
D5. Select the desired region from the combo box.
D6. Select the desired VM size.
D7. Specify the Azure Storage account name. Alternatively you can leave it blank to let Jenkins create a storage
   account by using the default name "jenkinsarmst".
D8. Specify the retention time in minutes. This defines the number of minutes Jenkins can wait before automatically
   deleting an idle slave. Specify 0 if you do not want idle slaves to be deleted automatically.
D9. Select a usage option:
  * If "Utilize this node as much as possible" is selected, then Jenkins may run any job on the slave as long as it
    is available.
  * If "Leave this node for tied jobs only" is selected, Jenkins will only build a project (or job) on this node
    when that project specifically was tied to that node.This allows a slave to be reserved for certain kinds of jobs.
D10. Specify your Image Family. Choose between two possible alternatives:
  * use a custom user image (provide image URL and os type - note, your custom image has to be available into the same storage account in which you are going to create slave nodes);
  * give an image reference (provide image reference by publisher, offer, sku and version).
D11. For the launch method, select SSH or JNLP.
  * Linux slaves can be launched using SSH only.
  * Windows slaves can be launched using SSH or JNLP. For Windows slaves, if the launch method is SSH then
    image needs to be custom-prepared with an SSH server pre-installed.<br>


  When using the JNLP launch option, ensure the following:
  * Jenkins URL (Manage Jenkins --> configure system --> Jenkins Location)
    * The URL needs to be reachable by the Azure slave, so make sure to configure any relevant                                      firewall rules accordingly.
  * TCP port for JNLP slave agents (Manage Jenkins --> configure global security --> Enable security --> TCP port for JNLP slaves).
    * The TCP port needs to be reachable from the Azure slave launched using JNLP. It is recommended to use a fixed port so         that any necessary firewall exceptions can be made.

      If the Jenkins master is running on Azure, then open an endpoint for "TCP port for JNLP slave agents" and, in case of
      Windows, add the necessary firewall rules inside virtual machine (Run --> firewall.cpl).
D12. For the Init script, provide a script to install at least a Java runtime if the image does not have Java
      pre-installed.

      For the JNLP launch method, the init script must be in PowerShell.
      If the init script is expected to take a long time to execute, it is recommended to prepare custom images with the            necessary software pre-installed.<br>

      For more details about how to prepare custom images, refer to the below links:
      * [Capture Windows Image](http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-capture-image-windows-server/)
      * [Capture Linux Image](http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-capture-image/)

D13. Specify a user name and a password as per the rules explained in the help text.
D14. Make sure to validate the template configuration by clicking on the link “Verify Template”. This will connect
      to your Azure account to verify the correctness of the supplied information.

## Template Configuration for Ubuntu images.
D14.A1. Configure an Azure profile and Template as per the above instructions.
D14.A2. If the init script is expected to take a long time to complete, it is recommended to use a custom-prepared Ubuntu
   image that has the required software pre-installed, including a Java runtime
D14.A3. For platform images, you may specify an Init script as below to install Java, Git and Ant:

```
      #Install Java
      sudo apt-get -y update
      sudo apt-get install -y openjdk-7-jdk
      sudo apt-get -y update --fix-missing
      sudo apt-get install -y openjdk-7-jdk

      # Install Git
      sudo apt-get install -y git

      #Install Ant
      sudo apt-get install -y ant
      sudo apt-get -y update --fix-missing
      sudo apt-get install -y ant
```

## Create a Jenkins job that runs on a Linux slave node on Azure
D14.C1. In the Jenkins dashboard, click New Item/Job.
D14.C2. Enter a name for the task/Job you are creating.
D14.C3. For the project type, select Freestyle project and click OK.
D14.C4. In the task configuration page, select Restrict where this project can be run.
D14.C5. In the Label Expression field, enter label given during template configuration.
D14.C6. In the Build section, click Add build step and select Execute shell.
D14.C7. In the text area that appears, paste the following script.

 ````
  # Clone from git repo
  currentDir="$PWD"
  if [ -e sample ]; then
    cd sample
    git pull origin master
  else
    git clone https://github.com/snallami/sample.git
  fi

 # change directory to project
 cd $currentDir/sample/ACSFilter

 #Execute build task
 ant
 ````
D14.C8. Save Job and click on Build now.
D14.C9. Jenkins will create a slave node on Azure cloud using the template created in the previous section and
   execute the script you specified in the build step for this task.
D14.C10. Logs are available @ Manage Jenkins --> System logs --> All Jenkins logs.
D14.C11. Once the node is provisined in Azure, which typically takes about 5 to 7 minutes, node gets added to Jenkins.

## Configure [Azure Container Service Plugin](https://github.com/Microsoft/azure-acs-plugin)
Jenkins Plugin to create an Azure Container Service cluster with a DC/OS orchestrator and deploys a marathon config file to the cluster.

## Pre-requirements
Register and authorize your client application and retrieve and use Client ID and Client Secret to be sent to Azure AD during authentication. This should have been done by running the script in B6

## How to install the Azure Container Service Plugin
E1. Download the azure-acs-plugin.hpi file from [here](https://github.com/Microsoft/azure-acs-plugin/blob/master/install/azure-acs-plugin.hpi)
E2. Within the Jenkins dashboard, click Manage Jenkins.
E3. In the Manage Jenkins page, click Manage Plugins.
E4. Click the Advanced tab.
E5. Click on the Choose file button in the Upload Plugin section and choose the azure-acs-plugin.hpi file.
E6. Click the Upload button in the Upload Plugin section.
E6. Click either “Install without restart” or “Download now and install after restart”.
E8. Restart Jenkins if necessary.

## Configure the plugin
F1. Within the Jenkins dashboard, Select a Job then select Configure
F2. Scroll to the "Add post-build action" drop down.  
F3. Select "Azure Container Service Configuration" 
F4. Enter the subscription ID, Client ID, Client Secret and the OAuth 2.0 Token Endpoint in the Azure Profile Configuration section.
F5. Enter the Region, DNS Name Prefix, Agent Count, Agent VM Size, Admin Username, Master Count, and SSH RSA Public Key in the Azure Container Service Profile Configuration section.
F6. Enter the Marathon config file path, SSH RSA private file path, and SSH RSA private file password in the Marathon Profile Configuration section.
F7. Save Job and click on Build now.
F8. Jenkins will create an Azure Container Service cluster and deploy the marathon file to the cluster upon cluster creation if cluster doesn't exist.  Otherwise, the marathon file will be deployed to the existing Azure Container Service cluster. 
F9. Logs are available in the builds console logs.

## Note
This template use a base Azure Marketplace image which will be updated regularly to describe to use Azure resources with Jenkins. Readme instructions will be updated accordingly.

## Known Issue
Deployment failure due to not-unique dns name or password/admin name/resource group name doesn't follow the azure standard.  

## Contact us – azdevopspub@microsoft.com
