# Jenkins and Spinnaker VM template

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fspinnaker-jenkins-to-vmss%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fspinnaker-jenkins-to-vmss%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will allow the automated deployment of Jenkins + Spinnaker in two different VMs in Azure.  This guide uses the Azure-Cli 2.0.  Instructions to install/update to the latest version can be found [here](https://docs.microsoft.com/en-us/cli/azure/install-az-cli2).
 
In order to deploy here are the steps to follow: 

## A. Create a Service Principal
1. Run `az login` to login to your subscription
1. Run the script ./setup-scripts/create_spn.sh passing in the name of your subscription as a parameter (-n parameter).  See script for usage documentation regarding optional parameters.
1. For more information or to follow manual steps, see [here](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory)

## B. Deploy Spinnaker and Jenkins VMs
Deploying with a browser on Azure portal 

1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the Spinnaker VM and Jenkins VM, as well as a user name a password you will use for both.
1. Enter the client id and key for your service principal created above.

Deploying from the command line

1. Create a resource group: 
` az group create -n spinnakergroup -l westus `
1. Fill in the parameters in your copy of the ` azuredeploy.parameters.json ` file. The Spinnaker VM and Jenkins VM will use the same username and password. The client id and key for your service principal are the once that have been created above.
1. Deploy the solution with the following command: 

` az group deployment create -g spinnakergroup -n deploy --template-file ./azuredeploy.json --parameters @./azuredeploy.parameters.json `

**Note**: If you use a local parameters file, you must prefix the path with the '@' signe as indicated in the sample above.

## C. Unlock Jenkins
1. SSH to the JenkinsVM and run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` to get the initial password.
1. Navigate to 'http://Jenkins_IP_Address:8080' and enter the password to unlock Jenkins for the first time.
1. Follow prompts to install the default plugins and create a jenkins user **with the same parameters as the ones entered at the deployment of the VM**.
1. SSH to Jenkins and run the following command: ``/opt/azure_jenkins_config/init_jenkins.sh -op "Password_of_your_oracle_account" `` 

## D. Setup SSH port forwarding to Spinnaker
You need to setup port forwarding to view the Spinnaker UI on your local machine.

### If you are using Windows:
1. Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for ports: 8087 and 9000, until you have all three listed in the text box for Forward ports.
1. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
1. Add this to your ~/.ssh/config
  ```
  Host spinnaker-start
    HostName <Public DNS name of instance you just created>
    IdentityFile <Path to your key file>
    ControlMaster yes
    ControlPath ~/.ssh/spinnaker-tunnel.ctl
    RequestTTY no
    LocalForward 9000 127.0.0.1:9000
    LocalForward 8084 127.0.0.1:8084
    LocalForward 8087 127.0.0.1:8087
    User <User name>

  Host spinnaker-stop
    HostName <Public DNS name of instance you just created>
    IdentityFile <Path to your key file>
    ControlPath ~/.ssh/spinnaker-tunnel.ctl
    RequestTTY no
  ```
1. Create a spinnaker-tunnel.sh file with the following content and give it execute permission using `chmod +x spinnaker-tunnel.sh`
  ```
  #!/bin/bash

  socket=$HOME/.ssh/spinnaker-tunnel.ctl

  if [ "$1" == "start" ]; then
    if [ ! \( -e ${socket} \) ]; then
      echo "Starting tunnel to Spinnaker..."
      ssh -f -N spinnaker-start && echo "Done."
    else
      echo "Tunnel to Spinnaker running."
    fi
  fi

  if [ "$1" == "stop" ]; then
    if [ \( -e ${socket} \) ]; then
      echo "Stopping tunnel to Spinnaker..."
      ssh -O "exit" spinnaker-stop && echo "Done."
    else
      echo "Tunnel to Spinnaker stopped."
    fi
  fi
  ```
1. Call `./spinnaker-tunnel.sh start` to start your tunnel
1. Call `./spinnaker-tunnel.sh stop` to stop your tunnel


## E. Connect to Spinnaker 

1. After you have started your tunnel, navigate to `http://localhost:9000/` on your local machine.
1. Follow steps [here](http://www.spinnaker.io/docs/hello-spinnaker) to deploy a sample pipeline.

## Questions/Comments? azdevopspub@microsoft.com
