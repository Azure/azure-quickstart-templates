![Groestlcoin-Azure](../images/groestlcoin.png)

# Groestlcoin Core Blockchain Node on Ubuntu VM

This template delivers the Groestlcoin network to your VM in about 15 minutes. Everything you need to get started using the Groestlcoin blockchain from the command line is included. You may select to build from source or install from the provided Personal Package Archive (PPA). Once installed, 'groestlcoind' will begin syncing the public blockchain. You may then connect via SSH to the VM and launch 'groestlcoind' to interface with the blockchain.

# What is Groestlcoin?

Groestlcoin is an experimental digital currency that enables instant payments to
anyone, anywhere in the world. Groestlcoin uses peer-to-peer technology to operate
with no central authority: managing transactions and issuing money are carried
out collectively by the network. Groestlcoin Core is the name of open source
software which enables the use of this currency.

For more information, as well as an immediately usable, binary version of
the Groestlcoin Core software, see https://www.groestlcoin.org/groestlcoin-core-wallet/.


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch groestlcoind `sudo groestlcoind`
* groestlcoind will run automatically on restart

# Licensing

Groestlcoin Core is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
