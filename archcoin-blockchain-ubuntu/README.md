# Archcoin Blockchain Node on Ubuntu VM

This template delivers the Archcoin network to your VM in about 20 minutes.  Everything you need to get started using the Archcoin blockchain from the command line is included. 
You may build from source.  Once installed, 'archcoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'archcoind' to interface with the blockchain.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Farchcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Farchcoin-blockchain-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/></a>

# What is Archcoin?

The original ARCH whitepaper focused on the concept of controlling the flow of information within a decentralized autonomous corporation (DAC) in an effort to promote financial stability and growth within a DAC and protecting sensible information. While most cryptocurrencies are created as an alternative to bitcoin, ARCH was created as a startup holding DAC whose equity is represented by a cryptographic token. The goal is to test new applications of blockchain technology as well as to model an investor-token relationship in a use-case scenario involving a real startup with palpable products and services. To improve equity fungibility, revenue from any of the holding company's products or services is to be used to purchase more tokens from the market, thereby making the holding DAC's equity token exponentially more valuable with each additional revenue stream. Although no substantial revenue has been injected into ARCH's fungibility yet, its tiered conditional access levels have created a natural self-audit system that has proven very effective when it comes to managing this pseudo-corporate setup and its investors. Value in information is trusted to investors according to their own responsibility in the pseudo-corporate structure. In this tiered setup, the amount of tokens held serves as a basis of evaluating trust and involvement with the DAC itself. This system promotes unbiased transparency by the developers and corporate responsibility on behalf of the investors. This system alone, without any major revenue stream, has already proven itself as the backbone of the current stable growth in the ARCH equity token's market cap.

This unique approach opens doors for a new generation of DACs, fusing decentralized communities with traditional corporate structures using tiered conditional access levels to secure the flow of information. Although tailored to our specific ventures and “community” needs, the ARCH wallet concept is an outstanding, first-of-its-kind example for other future DACs looking to combine all relevant information and tools regarding the DAC's and its equity token in one place. ARCH is taking that concept even further and seeks to integrate the whole corporate structure into its wallet as the DAC grows. 

In a nutshell, Arch rearranged how investors interacted in DACs to establish healthier lines of communication while changing the financial structure so that FIAT revenue would be injected directly into the tokens fungibility instead of being distributed through dividends.

Our products, services and software are inspired by bitcoin, disruptive and innovative but not interdependent.
Learn more https://bitcointalk.org/index.php?topic=831777.0

# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Archcoin host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Archcoin from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch archcoind `sudo archcoind`
* `archcoind` will run automatically on restart

# Licensing

Archcoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
