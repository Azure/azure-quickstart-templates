# Parity Ethereum node for development

A Microsoft Azure template for deploying an Ethereum node running a sandboxed, permissioned (Proof of Authority) blockchain.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fethcore%2Fazure-quickstart-templates%2Fmaster%2Fparity-ubuntu%2Fazuredeploy.json)

Click the button and wait for about 15 minutes. Once the automated deployment is complete, you will have a sandbox environment with an Ethereum node (Parity), running and ready to accept transactions via the JSON-RPC interface on port 8545.

## Template parameters
* `vmDnsPrefix`: the public DNS name for the VM that you will use interact with your geth console. You just need to specify a unique name.
* `adminUsername`: the linux account name you will use for connecting to the host.
* `adminPassword`: your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `vmSize`: the size of the VM to use. It is by default set to A2.
* `ethAccountPass`: the password for your Ethereum account. This does not need to be secure, as this is a development-only deployment.

## Why should I use it?
Setting up an Ethereum test network can be tedious, especially if you want to share it with a few other people. Sometimes, you just need an Ethereum client, that you can easily connect to from any machine, that has access to the Internet.

With this template, you can start playing with Ethereum, without having to install any software on your machine. On top of this, as this deployment uses the Proof of Authority sealing mecanism, it does not need to make use of mining, which means, that transactions get validated and confirmed near-instantaneously.

## How do I use it?

Once the deployment is complete, you will be able to interact with the node via the JSON-RPC interface by sending HTTP requests to http://\<host IP address\>:8545 (you will need to find out what the host IP address is). You can find the JSON-RPC specification here: https://github.com/ethereum/wiki/wiki/JSON-RPC

It's worth keeping in mind that the Ethereum JSON-RPC interface is quite low-level. There are tools that make interacting with it much easier, e.g. [Web3.js](https://github.com/ethereum/web3.js/), or the [Online Solidity Compiler](http://ethereum.github.io/browser-solidity/#version=soljson-latest.js)

**Tip**: to connect the Online Solidity Compiler to your node, click the icon that looks like a little cube, in the upper right. Then select the "Web3 Provider" option and fill in the Web3 Provider Endpoint input with http://\<host IP address\>:8545

## What is Ethereum?

The one and only, ultra-awesome blockchain technology for curing cancer and exploring parallel universes (... at some point in the future, maybe). Find out all about it at https://ethereum.org, or just google it - it has made a lot of media noise over the last few years.

## What is Parity?

[Parity](https://github.com/ethcore/parity) is a fully-featured Ethereum client implementation, by [Ethcore](https://ethcore.io/), built in the Rust programming language. It is meant to be enterprise-oriented and is optimised for speed and performance. Parity has full support for private chains, as well as, the main Ethereum Homestead network.

## What is Proof of Authority?

[Proof of Authority](https://github.com/ethcore/parity/wiki/Proof-of-Authority-Chains) is a block sealing mechanism, used, as an alternative to Proof of Work, in private test networks. It does not rely on the hashing power to produce blocks, but instead, uses an explicitly-identified list of nodes ("authorities"), that can validate transactions. This allows for sub-second block times, while not affecting any other Ethereum compatibility features - all of the transactions and smart contracts, that you run on a PoA-enabled client will be just as valid on the main Ethereum network.
