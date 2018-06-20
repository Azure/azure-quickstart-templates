# Vcash Node on Ubuntu VM

This Microsoft Azure template deploys a Vcash public node that will connect to the main Vcash decentralised network.

# What is Vcash?
Vcash is a Proof-of-Work and Proof-of-Stake based cryptographic currency which provides a variety of services through blockchain decentralised ledger technology.
Services include:

* Incentivised Node Technology
* Short-Term Data Storage and Retrieval
* Lightweight SQL-like Query Protocol

For more information see: http://www.v.cash/


# Getting Started Tutorial
* Click the `Deploy to Azure` icon for this template.
* Complete the template parameters, choose your resource group, accept the Terms and click Create.
* Wait about 20 minutes for the VM to install the software.
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you need to relaunch vcashd `sudo vcashd`
* The vcashd daemon will  automatically run on system boot