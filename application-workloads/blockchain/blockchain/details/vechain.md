![VeChain-Azure](../images/vechain.png)

# VeChain Blockchain Thor Node on Ubuntu VM

This template delivers the VeChain mainnet network to your VM in about 15-20 minutes. Everything you need to get started using the VeChain blockchain from the command line is included. Once installed, 'thor' will begin syncing the public blockchain. You may then connect via SSH to the VM and launch 'thor' to interface with the blockchain.

# What is VeChain?

The VeChain is a public blockchain that is designed for mass adoption of blockchain technology by enterprise users of all sizes. VeChainThor is intended to serve as a foundation for a sustainable and scalable enterprise blockchain ecosystem, supported in part by our novel governance and economic models and unique protocol enhancements.

It is not built from scratch; it expands upon some of the essential building blocks of Ethereum (e.g., the account model, the EVM, the modified Patricia tree, and the RLP encoding method) and provides innovative technical solutions that are powered by our novel governance and economic models, which, we believe, will push forward broader blockchain adoption and the creation of new business ecosystems with more efficiency and trust. VeChainThor is packed with technical features that are tailormade for the actual needs of enterprises, individuals, and developers.

For more information, as well as an immediately usable, see https://github.com/vechain/thor, or read the
[whitepaper](https://cdn.vechain.com/vechainthor_development_plan_and_whitepaper_en_v1.0.pdf).


# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15-20 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch thor `sudo $GOPATH/src/VeChain/thor/bin/thor --network main`
* thor will run automatically on restart

# Licensing

VeChain is released under the terms of the GNU Lesser General Public License. See `COPYING` for more information or see https://github.com/vechain/thor/blob/master/LICENSE.
