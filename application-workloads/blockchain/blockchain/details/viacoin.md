# Viacoin-blockchain-ubuntu
Viacoin Blockchain Node on Ubuntu VM

This template delivers the Viacoin network to your VM in about 20 minutes.  Everything you need to get started using the Viacoin blockchain from the command line is included. 
You may build from source.  Once installed, 'viacoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'viacoind' to interface with the blockchain.

# What is Viacoin?

Viacoin is a digital currency similar to Bitcoin that allows the creation of applications on top of the Viacoin blockchain 
in a similar way that email and web are built on top of the internet protocol.

This allows the building of fully decentralized exchanges, issuing of new currencies, asset tracking, betting, 
digital voting, reputation management and even form the basis of fully decentralized market places. Our protocol for this will be called ClearingHouse.

+ Technology: Proof of Work
+ Total supply: ~23,000,000 (92MM)
+ Algorithm: Scrypt (POW)
+ Block time: 24 seconds
+ Difficulty retarget: AntiGravityWave (every block)
+ Fast Transactions: 25x faster than Bitcoin
+ CHECKLOCKTIMEVERIFY support: Microtransactions & payment channels
+ ClearingHouse: Decentralized settlement and meta transaction protocol
+ Embedded Consensus: Extended OP_RETURN 120 byte support
+ Blockchain Notary: Proof-of-publication

## Unique

Viacoin Decentralized settlement and meta transaction protocol.:

The ClearingHouse project which enables decentralized, p2p trading directly on the blockchain. 
You can create your own coins and assets and it enables a host of features to be built on top of the blockchain.

ClearingHouse is based on on the counterparty protocol with the immediate advantages of being faster, cheaper and free of bitcoin politics.

For more information see https://viacoin.org

# Getting Started Tutorial 

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch viacoind `sudo viacoind`
* `viacoind` will run automatically on restart
