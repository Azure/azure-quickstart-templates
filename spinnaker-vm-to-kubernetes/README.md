# Host Spinnaker in an Azure VM targeting Kubernetes

<a href="https://aka.ms/azspindeployk8sqs" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://aka.ms/azspinvizk8sqs" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template allows you to deploy an instance of Spinnaker on a Linux Ubuntu 14.04 LTS VM automatically configured to target a Kubernetes cluster. This will deploy a D2_v2 size VM and a Kubernetes cluster in the resource group location and return the FQDN of both.

## A. Deploy Spinnaker VM
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the Spinnaker VM and Kubernetes cluster, as well as a user name and [ssh public key](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to both.
1. Create a [service principal](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory) for your Kubernetes cluster and enter the client id and key.

## B. Setup SSH port forwarding
You need to setup port forwarding to view the Spinnaker UI on your local machine.

### If you are using Windows:
1. Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).
1. Launch Putty and navigate to Change Settings > SSH > Tunnels
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for ports: 8087 and 9000, until you have all three listed in the text box for Forward ports.
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

## C. Connect to Spinnaker

1. After you have started your tunnel, navigate to `http://localhost:9000/` on your local machine.
1. Follow steps [here](http://www.spinnaker.io/docs/kubernetes-source-to-prod) to deploy a sample pipeline. The kubeconfig file has already been copied over to your Spinnaker instance, and it has been configured to use the [docker repository](https://hub.docker.com/r/lwander/spin-kub-demo/) in the example.
1. Check the [Troubleshooting Guide](http://www.spinnaker.io/docs/troubleshooting-guide) if you have any issues.

## Questions/Comments? azdevopspub@microsoft.com