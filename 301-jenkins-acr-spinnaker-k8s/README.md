# Continuous Deployment to Kubernetes

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-jenkins-acr-spinnaker-k8s%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-jenkins-acr-spinnaker-k8s%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy and configure a DevOps pipeline from an Azure Container Registry to a Kubernetes cluster. It deploys an instance of Jenkins and Spinnaker on a D3_v2 size Linux Ubuntu 14.04 LTS VM.

The Jenkins instance will include a basic pipeline that checks out a user-provided git repository, builds the Docker container based on the Dockerfile at the root of the repo, and pushes the image to the provisioned Azure Container Registry. The Spinnaker instance will include a basic pipeline that is triggered by any new tag in the registry and deploys the image to the provisioned Kubernetes cluster.

> NOTE: The Spinnaker pipeline assumes your app is listening on port 8000. You can clone this template and modify the 'pipelinePort' variable in azuredepoy.json to target a different port.

## A. Deploy
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
2. Enter a valid name for the VM, as well as a user name and [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to the VM via SSH.
1. Create a [service principal](https://docs.microsoft.com/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory) and enter the client id and key. This will be used to login to your ACR and by your Kubernetes cluster to dynamically manage resources.
1. Leave the git repository as the [sample app](https://github.com/lwander/spin-kub-demo) or change it to target your own app's repository. The repo must have a Dockerfile in its root.
1. Leave the docker repository as the sample name or change it to the name you desire. A repo with this name will be created in your ACR.

## C. Setup SSH port forwarding
**By default the Jenkins instance is using the http protocol and listens on port 8080. Users shouldn't authenticate over unsecured protocols!**

You need to setup port forwarding to view the Jenkins and Spinnaker UI on your local machine.

### If you are using Windows:
1. Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8080 for Source port. Then enter 127.0.0.1:8080 for the Destination. Click Add.
1. Repeat this process for ports 8084, 8087, and 9000
1. Click Open to establish the connection.

### If you are using Linux or Mac:
1. Add this to your ~/.ssh/config
  ```
  Host devops-start
    HostName <Public DNS name of instance you just created>
    IdentityFile <Path to your key file>
    ControlMaster yes
    ControlPath ~/.ssh/devops-tunnel.ctl
    RequestTTY no
    # Jenkins dashboard
    LocalForward 8080 127.0.0.1:8080
    # Spinnaker/deck
    LocalForward 9000 127.0.0.1:9000
    # Spinnaker/gate
    LocalForward 8084 127.0.0.1:8084
    # Default port if running 'kubectl proxy' on the VM
    LocalForward 8001 127.0.0.1:8001
    User <User name>

  Host devops-stop
    HostName <Public DNS name of instance you just created>
    IdentityFile <Path to your key file>
    ControlPath ~/.ssh/devops-tunnel.ctl
    RequestTTY no
  ```
1. Create a devops-tunnel.sh file with the following content and give it execute permission using `chmod +x devops-tunnel.sh`
  ```
  #!/bin/bash

  socket=$HOME/.ssh/devops-tunnel.ctl

  if [ "$1" == "start" ]; then
    if [ ! \( -e ${socket} \) ]; then
      echo "Starting tunnel to DevOps VM..."
      ssh -f -N devops-start && echo "Done."
    else
      echo "Tunnel to DevOps VM running."
    fi
  fi

  if [ "$1" == "stop" ]; then
    if [ \( -e ${socket} \) ]; then
      echo "Stopping tunnel to DevOps VM..."
      ssh -O "exit" devops-stop && echo "Done."
    else
      echo "Tunnel to DevOps VM stopped."
    fi
  fi
  ```
1. Call `./devops-tunnel.sh start` to start your tunnel
1. Call `./devops-tunnel.sh stop` to stop your tunnel

## D. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8080/ on your local machine.
1. Unlock the Jenkins dashboard for the first time with the initial admin password. To get this token, SSH into the VM and run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
1. Your Jenkins instance is now ready to use! Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## E. Connect to Spinnaker

1. After you have started your tunnel, navigate to `http://localhost:9000/` on your local machine.
1. Navigate to 'Applications -> {Application Name} -> Pipelines' to see your pipeline. Follow steps [here](http://www.spinnaker.io/docs/kubernetes-source-to-prod#section-1-create-a-spinnaker-application) to create a pipeline manually.
1. Check the [Troubleshooting Guide](http://www.spinnaker.io/docs/troubleshooting-guide) if you have any issues.

## Questions/Comments? azdevopspub@microsoft.com