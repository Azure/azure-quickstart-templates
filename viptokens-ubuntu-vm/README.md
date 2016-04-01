# vipcoin Blockchain Node on Ubuntu VM

This template delivers the vipcoin network to your VM in about 20 minutes.  Everything you need to get started using the vipcoin blockchain from the command line is included. 
You may build from source.  Once installed, 'vipcoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'vipcoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvipcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvipcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is vipcoin?

ALGO: NIST5
One of the best mining algo for GPU cards. GPU Temperatures around 60-65.

TICKER: VIP Block Size: 2MB POW + POS SUPPLY: 90 Millions BLOCK TIME: 30 seconds ALGORITM: NIST5 (BLAKE - Grøstl - JH - Keccak - Skein) MATURITY: 40 Blocks

POS: 8% Annually POS: Start from block 100000 Min Stake Age: 24 Hours Max Stake Age: Unlimited

PoW: Approx 69 Days Mining

Blocks:

Blocks: 0-20 : Airdrop Block: 20-100: 0 VIP Block: 100-1000: 500 VIP Block: 1000-30000: 450 VIP Block: 30000-60000: 300 VIP Block: 60000-100000: 250 VIP Block: 100000-150000: 150 VIP Block: 150000-200000: 110 VIP


http://viptokens.club
https://twitter.com/VipTokens
http://coinmarketcap.com/currencies/vip-tokens/

Viptokens Exchange:
https://yobit.net/en/trade/VIP/BTC



# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your vipcoin host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install vipcoin from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch vipcoind `sudo vipcoind`
* `vipcoind` will run automatically on restart

# Licensing

vipcoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
