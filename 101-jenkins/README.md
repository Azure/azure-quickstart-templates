# Azure hosted Jenkins Master on Ubuntu [![Build Status](http://devops-ci.westcentralus.cloudapp.azure.com/job/qs/job/101-jenkins/badge/icon)](http://devops-ci.westcentralus.cloudapp.azure.com/blue/organizations/jenkins/qs%2F101-jenkins/activity)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-jenkins%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-jenkins%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to host an instance of Jenkins on a DS1_v2 size Linux Ubuntu 14.04 LTS VM in Azure.

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
      ControlMaster yes
      ControlPath ~/.ssh/jenkins-tunnel.ctl
      RequestTTY no
      LocalForward 8080 127.0.0.1:8080
      User <User name>

    Host jenkins-stop
      HostName <Public DNS name of instance you just created>
      ControlPath ~/.ssh/jenkins-tunnel.ctl
      RequestTTY no
    ```
1. Create a jenkins-tunnel.sh file with the following content and give it execute permission using `chmod +x jenkins-tunnel.sh`
    ```bash
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