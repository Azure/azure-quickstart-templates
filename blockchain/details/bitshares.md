# BitShares Blockchain Node on Ubuntu VM

This template delivers the BitShares network to your VM in about 15 mintues (PPA install).  Everything you need to get started using the BitShares blockchain from the command line is included. 
You may select to build from source or install from the community provided Personal Package Archive (PPA).  Once installed, the 'witnes_node' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch the 'cli-wallet' to interface with the blockchain.

# What is BitShares?

```
BitShares is an industrial-grade financial blockchain smart contracts platform.  Built using the latest in
industry research, BitShares delivers a decentralized financial platform with speeds approaching NASDAQ. 
```

# Getting Started Tutorial

* Click the `Deploy to Azure` icon for this template
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the bits
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* Launch the cli-wallet: `sudo /usr/bin/cli_wallet --wallet-file=/usr/local/bitshares-2/programs/cli-wallet/wallet.json`
* Assign a secure password `>set_password use_a_secure_password_but_check_your_shoulder_as_it_will_be_displayed_on_screen`
* `ctrl-d` will save the wallet and exit the client
* View your wallet: `nano /usr/local/bitshares-2/programs/cli-wallet/wallet.json`
* Learn more: [http://docs.bitshares.eu](http://docs.bitshares.eu)   

# Licensing

BitShares is offered under the MIT License as [documented here](https://github.com/bitshares/bitshares-2/blob/bitshares/LICENSE.md). 

# More About BitShares

Please review [BitShares documentation](https://docs.bitshares.eu) to learn more. 
