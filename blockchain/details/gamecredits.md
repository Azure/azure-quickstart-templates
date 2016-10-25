# Gamecredits Blockchain Node on Ubuntu VM

This template delivers the Gamecredits network to your VM in about 15 minutes (PPA install).  Everything you need to get started using the Gamecredits blockchain from the command line is included. 
You may select to build from source or install from the community provided Personal Package Archive (PPA).  Once installed, 'gamecreditsd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'gamecreditsd' to interface with the gaming blockchain.

# What is Gamecredits?

[![GameCredits](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/blockchain/images/gamecredits.png)

A new and exciting Open Source Gaming currency that will revolutionize in-game purchases and bring game developers a monetization based on fair-play rules.
Purchase in-game goods and services with utmost ease.
Having security and speed in your online transactions is crucial. GameCredits is delivering those in spades! With a secure yet convenient login system and unparalelled transparency in real cost of your in-game purchases GameCredits has no competition when it comes to user satisfaction.
GameCredits strives to become the premier in-game monetization option. Be a part of that story!
Providing game developers with a fair-use monetization option
Building games is a massive undertaking and game developers need to spend time making games and not fighting with elaborate in-game monetization techniques. This is where GameCredits comes in. Ease of "GAME" implementation lets game developers focus on things that matter in the game - quality of content and playable mechanics.
GameCredits API provides a seamless and easy way to implement a monetization option that provides a secure experience for developers and users alike. GameCredits comes with zero implementation cost and low fees when purchase volume increases.

Big or small, gamer or game developer - we’ve got a solution when you need it. Our support personnel will contact you as quickly as possible.

P.O. Box
406 Broadway #134,
Santa Monica, CA 90401
USA

contact@gamecredits.com
info@gamecredits.net

GameCredits is a lite version of Bitcoin using scrypt as a proof-of-work algorithm.
 - 1.5 minute block targets
 - subsidy halves in 840k blocks
 - ~84 million total coins
 - 1 blocks to retarget difficulty

For more information, as well as an immediately useable, binary version of
the Gamecredits client sofware, see https://onlinegames.credit/.


# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Gamecredits host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure how to install the software.  The default is using the community provided PPA.  You may choose to install from source, but be advised this method takes substantially longer to complete.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the A series for PPA installs, and D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch gamecreditsd `sudo gamecreditsd`
* gamecreditsd will run automatically on restart

# Licensing

Gamecredits is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
