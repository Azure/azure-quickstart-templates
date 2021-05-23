# Influx Blockchain Node on Ubuntu VM

This template delivers the Influx network to your VM in about 20 minutes.  Everything you need to get started using the Influx blockchain from the command line is included. 
You may build from source.  Once installed, 'Influxd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'Influxd' to interface with the blockchain.

# What is Influx?

What is Influx?
----------------

Influx is a minable X11 coin which provides an array of useful services
which leverage the bitcoin protocol and blockchain technology.

 - 4 minute block targets
 - Proof of Work/Proof of Stake Hybrid blockchain security model (X11)


Services include:

- SuperNET MGW Integration for decentralized storage of coins and decentralized trading on NXT's blockchain.
- Payment API for 3rd Party acceptance of Influx for remittance

For more information, as well as an immediately useable, binary version of
the Influx client software, see http://www.influxcoin.xyz.


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch Influxd `sudo Influxd`
* Influxd will run automatically on restart

# Licensing

Influx is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
