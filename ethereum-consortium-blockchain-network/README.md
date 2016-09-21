# Ethereum Consortium Network Deployments Made Easy

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fethereum-consortium-blockchain-network%2Fazuredeploy.json)  [![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fethereum-consortium-blockchain-network%2Fazuredeploy.json)

## Overview
The next phase of our support of blockchain on Microsoft Azure is the release of the Ethereum Consortium Blockchain Network solution template in the Azure Quick Start Templates that simplifies the infrastructure and protocol substantially.  This template deploys and configures a private Ethereum network from the Azure Portal or cmdline with a single click.  While there are many valuable scenarios for the public Ethereum network, we expect in many enterprise scenarios, you will want to configure Ethereum to build out and deploy your own consortium network.

## Getting Started
To begin, you will need an Azure subscription that can support deploying several virtual machines and standard storage accounts.  By default, most subscription types will support a small deployment topology without needing to increase quota.
During the deployment process, you will be prompted for a set of simple inputs to configure the network properly.  One of the parameters needed is a private key for the prefunded Ethereum account specified in the genesis block.  This private key can be any 32-byte hexadecimal string.  The following powershell can be used to generate such a string - replace the "passphrase" string with a string of your choice: 
`[System.BitConverter]::ToString([System.Security.Cryptography.HashAlgorithm]::Create("SHA256").ComputeHash([System.Text.Encoding]::UTF8.GetBytes("passphrase"))) -replace '-',''`.  
In unix, you can run the following command: 
`echo "passphrase" | sha256sum`
There are also online tools to generate ethereum private keys. 

Once you have specified all parameters, specify a resource group and region to which to deploy all resources.  We recommend using a new separate resource group for ease of management and deletion.  Finally, acknowledge legal terms and click to ‘Create.’  Depending on the number of VMs being provisioned, deployment time can vary from a few minutes to tens of minutes.

## Ethereum consortium network architecture on Azure
While there is no single canonical architecture for a consortium network, this template provides a sample architecture to use to get started quickly.  Fundamentally, the network consists of a set of shared transaction nodes with which an application can interact to submit transactions and a set of mining nodes per consortium member to record transactions.  All nodes are within the same virtual network, though each consortium member’s subnet can be easily pulled into individual VNets communicating through application gateways.  The network is illustrated in the figure below:

![consortium network](images/eth-network.png)

## Mining Nodes
Each consortium member is given a separate, identical subnet containing one or more mining nodes, backed by a storage account.  The first default VM in the subnet is configured as a boot node to support dynamic discoverability of the nodes in the network.  Mining nodes communicate with other mining nodes to come to consensus on the state of the underlying distributed ledger.  There is no need for your application to be aware of or communicate with these nodes.  Since we are focused on private networks, these nodes are isolated from the public internet adding a secondary level of protection.  While each member’s VMs are in a separate subnet, the individual nodes are still connected and communicating with one another via Ethereum’s discovery protocol.
All nodes have the latest stable Go Ethereum (Geth) client software and are configured to be mining nodes.  All nodes have an Ethereum account (Ethereum address and key pair) that is protected by the Ethereum account password.  The public private key pair is stored on each of the Geth nodes.  As mining nodes mine, they collect fees that are added to this account.

## Transaction Nodes
All consortium members share a set of load-balanced transaction nodes.  These nodes are reachable from outside the virtual network so that applications can use these nodes to submit transactions or execute smart contracts within the blockchain networks.  All nodes have the latest stable Go Ethereum (Geth) client software and are configured to maintain a complete copy of the distributed ledger.  
We have explicitly separated the nodes that accept transactions from the nodes that mine transactions to ensure that the two actions are not competing for the same resources.  We have also load-balanced the transaction nodes to maintain high availability.

## Ethereum configuration
Besides the infrastructural footprint and configuration of nodes, the blockchain network itself is created.  The genesis block is configured with the desired Ethereum network id, an appropriate mining difficulty, and a pre-configured account.  The mining difficult varies depending on the number of mining nodes deployed to ensure mining time remains short even in the beginning.  The pre-configured account contains 1 trillion Ether to seed the consortium network with enough gas (Ethereum’s fuel) to handle millions of transactions.  Since the mining nodes use this account, their collected fees feed back into the account ensure continual funds.  

## Administrator page
Once the deployment has completed successfully and all resources have been provisioned, you can go to the administrator page to get a simple view of your blockchain network.  
The admin site URL is the DNS name of the load balancer; it is also the first output of the template deployment.  To find the template output, select the resource group just deployed.  Select the Overview tab, then Last Deployment.  

![consortium network](images/deployment.png)

Finally, select Microsoft.Template and look for the outputs section.

![consortium network](images/output.png)

You can get a high level overview of the topology you just deployed by reviewing the Ethereum Node Status section.  This section includes all node hostnames and the participant to which the node belongs.  It also displays node connectivity with the peer count.  Peer count is the minimum of the number of mining nodes in the network and twenty-five where twenty-five is the configured maximum peer count, as in the public Ethereum network.  Note, that peer count does not restrict the number of nodes that can be deployed within the network.  Occasionally, you will see peer count fluctuate and be less for certain nodes.  This is not always a sign that the nodes are unhealthy, since forks in the ledger can cause minor changes in peer count.  Finally, you can inspect the latest block seen by each node in the network to determine forks or lags in the system.

![consortium network](images/admin-site.png)

For additional information about blockchain, consortium architecture, and Ethereum account management, visit the [detailed walkthrough](http://aka.ms/blockchain-consortium-networks).
