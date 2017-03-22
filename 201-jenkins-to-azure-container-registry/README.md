# Jenkins to Azure Container Registry

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-jenkins-to-azure-container-registry%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-jenkins-to-azure-container-registry%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The template allows you to host an instance of Jenkins on a DS1_v2 size Linux Ubuntu 14.04 LTS VM in Azure. It will also create an Azure Container Registry and return the full registry URL.

You can optionally include a basic Jenkins pipeline that will checkout a user-provided git repository with a Dockerfile embedded and it will build and push the Docker container in the provisioned Azure Container Registry.

## A. Deploy an Azure Container Registry and a Jenkins VM with an embedded Docker build and publish pipeline
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter the desired user name and password for the VM that's going to host the Jenkins instance. Also provide a DNS prefix for your VM.
1. Create a [service principal](https://docs.microsoft.com/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory).
1. Fill in the service principal client id and secret. These will be used by the Jenkins pipeline to push the built docker container.
1. Enter a public git repository. The repository must have a Dockerfile in its root.

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

## C. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8080/ on your local machine.
1. Unlock the Jenkins dashboard for the first time with the initial admin password. To get this token, SSH into the VM and run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
1. Your Jenkins instance is now ready to use! Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## Questions/Comments? azdevopspub@microsoft.com