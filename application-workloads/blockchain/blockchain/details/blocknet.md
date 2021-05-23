# Blocknet Blockchain Node on Ubuntu VM

This template delivers the Blocknet network to your VM in about 20 minutes.  Everything you need to get started using the Blocknet blockchain from the command line is included. 
You may build from source.  Once installed, 'blocknetd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'blocknetd' to interface with the blockchain.

# What is Blocknet?

What is Blocknet?
----------------

The Blocknet is a revolutionary advancement in cryptographic technology:
a true peer-to-peer protocol between nodes on different blockchains. This 
is the foundation of a technology stack incorporating an API and an 
application platform, which enables open-ended application possibilities 
and vastly reduces development time.

Services include:

The Blocknet enables multi-blockchain services to be delivered to devices that only contain a single blockchain.
Thus, device and network resources are conserved, and a flexible, mobile, indefinitely extensible future is enabled.

For more information, as well as an immediately useable, binary version of
the Blocknet client software and network, see http://www.blocknet.co.


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch blocknetd `sudo blocknetd`
* `blocknetd` will run automatically on restart

# Licensing

Blocknet is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
