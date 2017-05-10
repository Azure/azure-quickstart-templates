# powercoin Blockchain Node on Ubuntu VM

This template delivers the powercoin network to your VM in about 20 minutes.  Everything you need to get started using the powercoin blockchain from the command line is included. 
You may build from source.  Once installed, 'powercoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'powercoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpowercoin-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpowercoin-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is powercoin?

What is powercoin?
----------------

POWERCOIN (PWR)

Ticker: PWR Powercoin Maturity: 30 Blocks Block Size: 8MB Block time: 60 seconds Algo: Nist5 (Quite,Low Consumption,GPU Optimized with BLAKE - Grøstl - JH - Keccak - Skein) Pow supply: 50021000 (25 Millions Distribuited by Airdrop Form Application)+ Dpos (Power Stages) with 3200000 PWR minted first 60 days Dpos + Fixed Pos subsidy at 5% Yearly Pos: 5% Annually - Minimum Stake Age: 8 Hours - Max Stake Age: Unlimited Powercoin Distribution: 50% Airdrop Form Application + 50% PoW Port: 4504 Rpcport: 4502

Block Reward: Blocks 0-10: Airdrop PWR Blocks 10-100 0 PWR 350 PWR first 43100 Blocks 230 PWR until PoW end,Block 86400

PowerPos: Blocks: 86000-86400: 5 PWR (Warm-Up) Blocks: 86400-100800: 10 PWR (1 Stage) Blocks: 100800-115200: 25 PWR (2 Stage) Blocks: 115200-129600: 50 PWR (3 Stage) Blocks: 129600-144000: 100 PWR (Full Power) Blocks: 144000-158400: 20 PWR (5 Stage) Blocks: 158400-172800: 15 PWR (6 Stage) Blocks: 172800 > 5% Fixed Yearly Approx: 2 Months PowerPoS

Website: Powercoin.pw Twitter: twitter.com/Powercoin_PWR


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your powercoin host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install powercoin from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch powercoind `sudo powercoind`
* powercoind will run automatically on restart

# Licensing

powercoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.

