# bpok Blockchain Node on Ubuntu VM

This template delivers the bpok network to your VM in about 20 minutes.  Everything you need to get started using the bpok blockchain from the command line is included. 
You may build from source.  Once installed, 'bpokd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'bpokd' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbpok-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbpok-on-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is bpok?

What is bpok?
----------------

BitPokemonGo

Twitter: https://twitter.com/bitpokemongo

TRIBUTE COIN TO POKEMONGO FREE AIRDROP + FREE MINING PROMOTING POKEMON WORLD AS FAN AND SUPPORTER

RPCPORT: 22086 PORT: 22087 Maturity: 20 Blocks PoS: 8% Yearly @ block 50000 Ticker: BPOK

Supply: 33860000 Millions BPOK (40% airdrop approx + 1,4% premine for promotion and bounties) MIN STAKE AGE: 2 Hours MAX STAKE AGE: Unlimited

Daily Blocks approx: 2880 2880 * 120 days = 345600 Block Approx 4 Month PoW

BITPOKEMONGO IS PRO BTC CLASSIC FORK 2MB

Blocks: 0-20: 700000 BPOK Blocks: 20-120: 0 BPOK Blocks: 120-86400: 100 BPOK Blocks: 86400-172800: 60 BPOK Blocks: 172800-259200: 40 BPOK Blocks: 259200-345600: 30 BPOK



# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your bpok host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install bpok from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch bpokd `sudo bpokd`
* bpokd will run automatically on restart

# Licensing

bpok is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.

