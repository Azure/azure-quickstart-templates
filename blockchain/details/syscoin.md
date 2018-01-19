# Syscoin Blockchain Node on Ubuntu VM

This template delivers the Syscoin network to your VM in about 15 minutes (PPA install).  Everything you need to get started using the Syscoin blockchain from the command line is included. 
You may select to build from source or install from the community provided Personal Package Archive (PPA).  Once installed, 'syscoind' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'syscoind' to interface with the blockchain.

# What is Syscoin?

What is Syscoin?
----------------

Syscoin is a merge-minable scrypt coin which provides an array of useful services
which leverage the bitcoin protocol and blockchain technology.

 - 1 minute block targets
 - Merge mining with Bitcoin network (SHA)


Services include:

- Alias reservation, ownership & exchange. Public/Private profile information.
- Data storage
- Digital document storage, ownership & exchange
- Distributed marketplate & exchange
- Digital Certificates
- Integrated Escrow with Arbitration
- Distributed encrypted communication

For more information, as well as an immediately useable, binary version of
the Syscoin client sofware, see http://www.syscoin.org.


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch syscoind `sudo syscoind`
* syscoind will run automatically on restart

# Licensing

Syscoin is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.