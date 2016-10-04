# Jumbucks Blockchain Node on Ubuntu VM

This template delivers the Jumbucks network to your VM in about 20 minutes.  Everything you need to get started using the Jumbucks blockchain from the command line is included. 
You may build from source.  Once installed, 'jumbucksd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'jumbucksd' to interface with the blockchain.

# What is Jumbucks?

What is Jumbucks?
----------------

Jumbucks is a Proof of Work/Proof of Stake scrypt coin which provides an array of useful services
which leverage the bitcoin protocol and blockchain technology.

 - 1 minute block targets
 - Proof of Work/Proof of Stake blockchain security model (scrypt)

For more information, as well as an immediately useable, binary version of
the Jumbucks client sofware, see http://www.getjumbucks.com.


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch jumbucksd `sudo jumbucksd`
* jumbucksd will run automatically on restart

# Licensing

Jumbucks is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
