# Host Jenkins in an Azure VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an instance of Azure Jenkins. Azure Jenkins is a fully functional instance of Jenkins 2.7.2 pre-configured to use Azure resources. The current version of this image lets you use Azure as a package repository to upload and download your application and it's dependencies to Azure as part of a Jenkins continuous deployment v2 pipeline.

## Deploy Azure Jenkins VM
1. Click "Deploy to Azure" button. If you haven't got an Azure subscription, it will guide you on how to signup for a free trial.
2. Enter a valid name for the VM, as well as a user name and password that you will use to login remotely to the VM via SSH.
3. Remember these. You will need this to access the VM next.

## Login remotely to the VM via SSH
Once the VM has been deployed, note down the IP generated in the Azure portal for the VM with the name you supplied. To login -
- If you are using Windows client you can use Putty or any bash shell on Windows to login to the VM with the username and password you supplied.
- If you are using Linux or Mac use Terminal to login to the VM with the username and password you supplied.

## Configure placehoder Jenkins jobs
1. Once you are logged into the VM, run /opt/azure_jenkins_config/config_azure.sh. This script will guide you to set up the storage account needed for Azure Storage Jenkins plugin.
   > Note 1: If the script doesn't exist, download it using below command.

   ```bash
   sudo wget -O /opt/azure_jenkins_config/config_azure.sh "https://raw.githubusercontent.com/arroyc/azure-quickstart-templates/master/azure-jenkins/setup-scripts/config_azure.sh"
   ```
   > Note 2: You can always run /opt/azure_jenkins_config/clear_storage_config.sh to reset configurations of Azure Storage for Jenkins and then run #1 again.

2. Login to your Azure account using the live id you used when creating your Azure subscription or with any valid user in your Azure subscription.
3. Select the subscription you want to use if you have more than one.
4. Select the storage account you want to use if you have more than one.
5. Select the destination container you will upload files to if you have more than one.
6. Select a subscription for setting up service principal. Remember the returned subscription ID, client ID, client secret and OAuth 2.0 Token Endpoint. You'll need them for Azure slave plugin configuration.

## Configure [Azure slave plugin](https://github.com/jenkinsci/azure-slave-plugin/tree/ARM-dev) : Azure profile configuration
1. Within the Jenkins dashboard, click Manage Jenkins --> Configure System --> Scroll to the bottom of the page
   and find the section with the dropdown "Add new cloud" --> click on it and select "Microsoft Azure"
2. Enter the subscription ID, Client ID, Client Secret and the OAuth 2.0 Token Endpoint.
3. Click on “Verify configuration” to make sure that the profile configuration is done correctly.
4. Save and continue with the template configuration (See instructions below)

## Configure [Azure slave plugin](https://github.com/jenkinsci/azure-slave-plugin/tree/ARM-dev) : Template configuration.
1. Click on the "Add" option to add a template. A template is used to define an Azure slave configuration, like
   its VM  size, its region, or its retention time.
2. Provide a name for your new template. This field is not used for slave provisioning.
3. For the description, provide any remarks you wish about this template configuration. This field is not
   used for slave provisioning.
4. For the label, provide any valid string. E.g. “windows” or “linux”. The label defined in a template can be
   used during a job configuration.
5. Select the desired region from the combo box.
6. Select the desired VM size.
7. Specify the Azure Storage account name. Alternatively you can leave it blank to let Jenkins create a storage
   account by using the default name "jenkinsarmst".
8. Specify the retention time in minutes. This defines the number of minutes Jenkins can wait before automatically
   deleting an idle slave. Specify 0 if you do not want idle slaves to be deleted automatically.
9. Select a usage option:
  * If "Utilize this node as much as possible" is selected, then Jenkins may run any job on the slave as long as it
    is available.
  * If "Leave this node for tied jobs only" is selected, Jenkins will only build a project (or job) on this node
    when that project specifically was tied to that node.This allows a slave to be reserved for certain kinds of jobs.
10. Specify your Image Family. Choose between two possible alternatives:
  * use a custom user image (provide image URL and os type - note, your custom image has to be available into the same storage account in which you are going to create slave nodes);
  * give an image reference (provide image reference by publisher, offer, sku and version).
11. For the launch method, select SSH or JNLP.
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
12. For the Init script, provide a script to install at least a Java runtime if the image does not have Java
      pre-installed.

      For the JNLP launch method, the init script must be in PowerShell.
      If the init script is expected to take a long time to execute, it is recommended to prepare custom images with the            necessary software pre-installed.<br>

      For more details about how to prepare custom images, refer to the below links:
      * [Capture Windows Image](http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-capture-image-windows-server/)
      * [Capture Linux Image](http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-capture-image/)

13. Specify a user name and a password as per the rules explained in the help text.
14. Make sure to validate the template configuration by clicking on the link “Verify Template”. This will connect
      to your Azure account to verify the correctness of the supplied information.

## Template Configuration for Ubuntu images.
1. Configure an Azure profile and Template as per the above instructions.
2. If the init script is expected to take a long time to complete, it is recommended to use a custom-prepared Ubuntu
   image that has the required software pre-installed, including a Java runtime
3. For platform images, you may specify an Init script as below to install Java, Git and Ant:

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

## Template configuration for Windows images with launch method JNLP.
1. Make sure to follow the instructions specified above for JNLP.
2. If the Jenkins master does not have a security configuration, leave the Init script blank for the default
   script to execute on the slave.
3. If the Jenkins master has a security configuration, then refer to the script at
   https://gist.github.com/snallami/5aa9ea2c57836a3b3635 and modify the script with the proper
   Jenkins credentials.

   At a minimum, the script needs to be modified with the Jenkins user name and API token.
   To get the API token, click on your username --> configure --> show api token<br>

   The below statement in the script needs to be modified:
   $credentails="username:apitoken"

## Create a Jenkins job that runs on a Linux slave node on Azure
1. In the Jenkins dashboard, click New Item/Job.
2. Enter a name for the task/Job you are creating.
3. For the project type, select Freestyle project and click OK.
4. In the task configuration page, select Restrict where this project can be run.
5. In the Label Expression field, enter label given during template configuration.
6. In the Build section, click Add build step and select Execute shell.
7. In the text area that appears, paste the following script.

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
8. Save Job and click on Build now.
9. Jenkins will create a slave node on Azure cloud using the template created in the previous section and
   execute the script you specified in the build step for this task.
10. Logs are available @ Manage Jenkins --> System logs --> All Jenkins logs.
11. Once the node is provisined in Azure, which typically takes about 5 to 7 minutes, node gets added to Jenkins.

## Note
This template use a base Azure Marketplace image which will be updated regularly to describe to use Azure resources with Jenkins. Readme instructions will be updated accordingly.
