# Azure Jenkins

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an instance of Azure Jenkins. Azure Jenkins is a fully functional instance of Jenkins 2.7+ pre-configured to use Azure resources. The current version of this image lets you use Azure as a package repository to upload and download your application and it's dependencies to Azure as part of a Jenkins continuous deployment v2 pipeline. It also lets you run Jenkins jobs on Azure Slave VMs.

## A. Deploy Azure Jenkins VM
1. Click "Deploy to Azure" button. If you haven't got an Azure subscription, it will guide you on how to signup for a free trial.
2. Enter a valid name for the VM, as well as a user name and password that you will use to login remotely to the VM via SSH.
3. Remember these. You will need this to access the VM next.

## B. Setup SSH port forwarding
**By default the Jenkins instance is using the http protocol and listens on port 8080. Users shouldn't authenticate over unsecured protocols!**

You need to setup port forwarding to view the Jenkins UI on your local machine.

### If you are using Windows:
1. Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8080 for Source port. Then enter 127.0.0.1:8080 for the Destination. Click Add.
1. Click Open to establish the connection.

### If you are using Linux or Mac:
1. Add this to your ~/.ssh/config
  ```
  Host jenkins-start
    HostName <Public DNS name of instance you just created>
    IdentityFile <Path to your key file>
    ControlMaster yes
    ControlPath ~/.ssh/jenkins-tunnel.ctl
    RequestTTY no
    LocalForward 8080 127.0.0.1:8080
    User <User name>

  Host jenkins-stop
    HostName <Public DNS name of instance you just created>
    IdentityFile <Path to your key file>
    ControlPath ~/.ssh/jenkins-tunnel.ctl
    RequestTTY no
  ```
1. Create a jenkins-tunnel.sh file with the following content and give it execute permission using `chmod +x jenkins-tunnel.sh`
  ```
  #!/bin/bash

  socket=$HOME/.ssh/jenkins-tunnel.ctl

  if [ "$1" == "start" ]; then
    if [ ! \( -e ${socket} \) ]; then
      echo "Starting tunnel to Jenkins..."
      ssh -f -N jenkins-start && echo "Done."
    else
      echo "Tunnel to Jenkins running."
    fi
  fi

  if [ "$1" == "stop" ]; then
    if [ \( -e ${socket} \) ]; then
      echo "Stopping tunnel to Jenkins..."
      ssh -O "exit" jenkins-stop && echo "Done."
    else
      echo "Tunnel to Jenkins stopped."
    fi
  fi
  ```
1. Call `./jenkins-tunnel.sh start` to start your tunnel
1. Call `./jenkins-tunnel.sh stop` to stop your tunnel

## C. Configure Sample Jobs and Azure Active Directory configuration
1. Once you are logged into the VM, run /opt/azure_jenkins_config/config_azure.sh and pick option 1 - "All of the below". This script will guide you to set up and configure the Azure Storage plugin to be used in the sample jobs to upload and download to Storage.
It will also provide a Service Principal to access Azure resources from Jenkins.
2. Remember the returned subscription ID, client ID, client secret and OAuth 2.0 Token Endpoint.

## D. Configure Azure plugins
Pre-requisite: Ensure you have executed the script in section C above and have the Azure AD secrets to configure below plugins.

1. Configure Azure VM Agents plugin using the parameters from C2 and follow the instructions [here](https://github.com/jenkinsci/azure-vm-agents-plugin/)
2. Configure Azure Container Service plugin using the parameters from C2 and follow the instructions [here](https://github.com/Microsoft/azure-acs-plugin)
3. Configure Azure Storage plugin following instructions [here](https://github.com/arroyc/windows-azure-storage-plugin/)

## E. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8080/ on your local machine.
1. Unlock the Jenkins dashboard for the first time with the initial admin password. To get this token, SSH into the VM and run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

## Note
This template uses a base Azure Marketplace image which will be updated regularly with the latest tools and plugins to access Azure resources. Readme instructions will be updated accordingly.

## Known Issue
Deployment failures due to non-unique dns name.

## Questions/Comments? azdevopspub@microsoft.com