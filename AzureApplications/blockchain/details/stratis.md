# Stratis Blockchain Node on Ubuntu VM

This template delivers the Stratis network to your VM in 10-15 minutes.  Everything you need to get started using the Stratis blockchain from the command line is included. 
You will be building from source.  Once installed, 'stratisd' will begin syncing the public blockchain. 
You may then connect via SSH to the VM and launch 'stratisd' to interface with the blockchain.

# What is Stratis?

Stratis is a flexible and powerful Blockchain Development Platform designed for the needs of real-world financial services businesses and other organisations that want to access the benefits of Blockchain technologies without the overheads inherent in running their own network infrastructure. Stratis offers a turnkey solution that enables developers and businesses to develop, test and deploy blockchain-based applications quickly and easily, and without the costs and security concerns that would otherwise arise from an in-house implementation. Get more information at http://stratisplatform.com.

# Template Parameters

When you click the Deploy to Azure icon above, you need to specify the following template parameters:

* `adminUsername`: This is the account for connecting to your Stratis host.
* `adminPassword`: This is your password for the host.  Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `dnsLabelPrefix`: This is used as both the VM name and DNS name of your public IP address.  Please ensure an unique name.
* `installMethod`: This tells Azure to install Stratis from source.
* `vmSize`: This is the size of the VM to use.  Recommendations: Use the D series for installations from source.

# Getting Started Tutorial

* Click the `Deploy to Azure` icon above
* Complete the template parameters, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Connect to the VM via SSH using the DNS name assigned to your Public IP
* If you wish to relaunch stratisd `sudo stratisd`
* stratisd will run automatically on restart

# Licensing

Stratis is released under the terms of the MIT license. See `COPYING` for more information or see http://opensource.org/licenses/MIT.
