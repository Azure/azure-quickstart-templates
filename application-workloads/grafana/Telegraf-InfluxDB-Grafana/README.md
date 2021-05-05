# Telegraf-influxDB-Grafana in Azure 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/grafana/Telegraf-InfluxDB-Grafana/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/grafana/Telegraf-InfluxDB-Grafana/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/grafana/Telegraf-InfluxDB-Grafana/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/grafana/Telegraf-InfluxDB-Grafana/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/grafana/Telegraf-InfluxDB-Grafana/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/grafana/Telegraf-InfluxDB-Grafana/CredScanResult.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fgrafana%2FTelegraf-InfluxDB-Grafana%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fgrafana%2FTelegraf-InfluxDB-Grafana%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fgrafana%2FTelegraf-InfluxDB-Grafana%2Fazuredeploy.json)

    

This template allows you to deploy an instance of Telegraf-InfluxDB-Grafana on a Linux Ubuntu 14.04 LTS VM. This will deploy a VM in the resource group location and return the FQDN of the VM and installs the components of Telegraf, InfluxDB and Grafana. The template provides configuration for telegraf with plugins enabled for Docker,container host metrics.

## A. Deploy TIG VM
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the VM, as well as a user name and [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to the VM via SSH.

## B. Login remotely to the VM via SSH
Once the VM has been deployed, note down the DNS Name generated in the Azure portal for the VM. To login:
- If you are using Windows, use Putty or any bash shell on Windows to login to the VM with the username and password you supplied.
- If you are using Linux or Mac, use Terminal to login to the VM with the username and password you supplied.

## C. Setup SSH port forwarding
Once you have deployed the TIG ARM template, you need to setup port forwarding to view the Grafana UI and InfluxDB UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -i <path to private key file> -L 3000:localhost:3000 -L 8083:localhost:8083 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to Change Settings > SSH > Tunnels
1. In the Options controlling SSH port forwarding window, enter 8083 for Source port. Then enter 127.0.0.1:8083 for the Destination. Click Add.
1. Repeat this process for port 3000
1. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -i <path to private key file> -L 3000:localhost:3000 -L 8083:localhost:8083 <User name>@<Public DNS name of instance you just created>
```
> NOTE: Port 3000 and 8083 correspond to Grafana and InfluxDB UI interfaces, respectively.

## E. Connect to Grafana and InfluxDB

1. After you have started your tunnel, navigate to http://localhost:3000/ on your local machine, to view Grafana UI. Username: admin, Password: YOUR_PASSWORD
2. After you have started your tunnel, navigate to http://localhost:8083/ on your local machine, to view InfluxDB UI. Username: root,Password : root. Give the host name as the full DNS name of your instance and save. Select the database "TIG".  


