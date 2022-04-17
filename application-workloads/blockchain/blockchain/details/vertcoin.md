![Vertcoin-Azure](../images/vertcoin.png)

# Vertcoin Core Blockchain Node on Ubuntu VM

This template delivers the Vertcoin network to your VM in about 15 minutes. Everything you need to get started using the Vertcoin blockchain from the command line is included. You may select to build from source or install from the provided Personal Package Archive (PPA). Once installed, 'vertcoind' will begin syncing the public blockchain. You may then connect via SSH to the VM and launch 'vertcoind' to interface with the blockchain.

# What is Vertcoin?

Vertcoin is an experimental digital currency that enables instant payments to
anyone, anywhere in the world. Vertcoin uses peer-to-peer technology to operate
with no central authority: managing transactions and issuing money are carried
out collectively by the network. Vertcoin Core is the name of open source
software which enables the use of this currency.

For more information, as well as an immediately usable, binary version of
the Vertcoin Core software, see https://github.com/vertcoin-project/vertcoin-core.


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch vertcoind `sudo vertcoind`
* vertcoind will run automatically on restart

# Licensing

Vertcoin Core is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
