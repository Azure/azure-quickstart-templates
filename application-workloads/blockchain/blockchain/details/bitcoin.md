![Bitcoin-Azure](../images/bitcoin.png)

# Bitcoin Core Blockchain Node on Ubuntu VM

This template delivers the Bitcoin network to your VM in about 15 minutes. Everything you need to get started using the Bitcoin blockchain from the command line is included. Once installed, 'bitcoind' will begin syncing the public blockchain. You may then connect via SSH to the VM and launch 'bitcoind' to interface with the blockchain.

# What is Bitcoin?

Bitcoin is an experimental digital currency that enables instant payments to
anyone, anywhere in the world. Bitcoin uses peer-to-peer technology to operate
with no central authority: managing transactions and issuing money are carried
out collectively by the network. Bitcoin Core is the name of open source
software which enables the use of this currency.

For more information, as well as an immediately usable, binary version of
the Bitcoin Core software, see https://bitcoincore.org/en/download/, or read the
[original whitepaper](https://bitcoincore.org/bitcoin.pdf).


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch bitcoind `sudo bitcoind`
* bitcoind will run automatically on restart

# Licensing

Bitcoin Core is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
