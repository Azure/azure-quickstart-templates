# Azure Spinnaker to Kubernetes [![Build Status](http://devops-ci.westcentralus.cloudapp.azure.com/job/qs/job/spink8stest/badge/icon)](http://devops-ci.westcentralus.cloudapp.azure.com/blue/organizations/jenkins/qs%2Fspink8stest/activity)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspinnaker-vm-to-kubernetes%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspinnaker-vm-to-kubernetes%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy an instance of Spinnaker on a Linux Ubuntu 14.04 LTS VM automatically configured to target a Kubernetes cluster. This will deploy a D3_v2 size VM and a Kubernetes cluster in the resource group location and return the FQDN of both. It will also create an Azure Container Registry and return the full registry name.

> NOTE: The Spinnaker pipeline assumes your app is listening on port 8000. You can clone this template and modify the 'pipelinePort' variable in azuredepoy.json to target a different port.

## A. Deploy Spinnaker VM
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the Spinnaker VM, a user name, and a [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to both.
1. Create a [service principal](https://docs.microsoft.com/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory) for your Kubernetes cluster and enter the client id and key.

## B. Setup SSH port forwarding
You need to setup port forwarding to view the Spinnaker UI on your local machine.

### If you are using Windows:
1. Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for ports: 8087 and 9000.
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
    # Spinnaker/deck
    LocalForward 9000 127.0.0.1:9000
    # Spinnaker/gate
    LocalForward 8084 127.0.0.1:8084
    # Default port if running 'kubectl proxy' on Spinnaker VM
    LocalForward 8001 127.0.0.1:8001
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

## C. Connect to Spinnaker

1. After you have started your tunnel, navigate to `http://localhost:9000/` on your local machine.
1. If you included a Kubernetes Pipeline when creating the template, navigate to 'Applications -> {Application Name} -> Pipelines' to see your pipeline. Follow steps [here](http://www.spinnaker.io/docs/kubernetes-source-to-prod#section-1-create-a-spinnaker-application) to create a pipeline manually.
1. You can trigger the pipeline by pushing an image with a new tag to the configured repository or simply clicking 'Start Manual Execution' and selecting an existing tag.
  1. By default, Spinnaker has been targeted to use the [repository](https://hub.docker.com/r/lwander/spin-kub-demo/) in the sample pipeline. Follow steps [here](http://www.spinnaker.io/v1.0/docs/target-deployment-configuration#section-docker-registry) to target different repositories.
  1. If your Kubernetes pipeline targets your Azure Container Registry, follow steps [here](https://docs.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli) to push your first image. You can find the registry url in the portal at 'Resource Groups -> {Resource Group Name} -> Overview -> Deployments -> Microsoft.Template -> Outputs'.
1. Check the [Troubleshooting Guide](http://www.spinnaker.io/docs/troubleshooting-guide) if you have any issues.

## Questions/Comments? azdevopspub@microsoft.com