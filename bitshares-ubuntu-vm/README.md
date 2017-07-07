# BitShares Blockchain Node on Ubuntu VM

This template delivers the BitShares network to your VM in about 15 mintues (PPA install).  Everything you need to get started using the BitShares blockchain from the command line is included. 
You may select to build from source or install from the community provided Personal Package Archive (PPA).  Once installed, the 'witnes_node' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch the 'cli-wallet' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbitshares-ubuntu-vm%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbitshares-ubuntu-vm%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is BitShares?

```
BitShares is an industrial-grade financial blockchain smart contracts platform.  Built using the latest in
industry research, BitShares delivers a decentralized financial platform with speeds approaching NASDAQ. 
```

# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your BitShares host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software bits.  The default is using the community provided PPA.  You may choose to install from source, but be advised this method takes substantially longer to complete.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the A series for PPA installs, and D series for installations from source.  Notice: Once the blockchain is synced, resize your VM to A1, as the BitShares witness_node requires a small resource footprint. 

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the bits
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* Launch the cli-wallet: `sudo /usr/bin/cli_wallet --wallet-file=/usr/local/bitshares-2/programs/cli-wallet/wallet.json`
* Assign a secure password `>set_password use_a_secure_password_but_check_your_shoulder_as_it_will_be_displayed_on_screen`
* `ctrl-d` will save the wallet and exit the client
* View your wallet: `nano /usr/local/bitshares-2/programs/cli-wallet/wallet.json`
* Learn more: [http://docs.bitshares.eu](http://docs.bitshares.eu)   

# Licensing

BitShares is offered under the MIT License as [documented here](https://github.com/bitshares/bitshares-2/blob/bitshares/LICENSE.md). 

# More About BitShares

Please review [BitShares documentation](https://docs.bitshares.eu) to learn more. 
