![MonetaryUnit-on-Ubuntu](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/monetaryunit-on-ubuntu/images/monetaryunit-logo.png)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonetaryunit-on-ubuntu%2Fazuredeploy.json) [![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonetaryunit-on-ubuntu%2Fazuredeploy.json)

# MonetaryUnit Full Node on Ubuntu

The simplest way to get up-and-running with MonetaryUnit on Azure!

Once deployed, the script will start the MonetaryUnit full node daemon and begin importing the latest bootstrap blocks. This will take about an hour, depending on your Azure instance's connectivity, performance, and bandwidth.

## Monitoring and Interacting with the Node

The MonetaryUnit node runs as an Upstart service. It can be controlled using the service command, ie: sudo service monetaryunit restart
The datadir and wallet are located at /var/lib/monetaryunitd and the node can be accessed via monetaryunit-cli command:

`sudo -u muedaemon monetaryunit-cli -conf=/etc/monetaryunit/monetaryunit.conf -datadir=/var/lib/monetaryunitd getinfo`


In order to run monetaryunit-cli without sudo or the extra arguments, you need to do the following:

`mkdir ~/.monetaryunit`
`sudo cp /etc/monetaryunit/monetaryunit.conf ~/.monetaryunit`
`sudo chown $USER ~/.monetaryunit/monetaryunit.conf`


## System Configuration

Once your node is deployed, you need to set your VM's public ip address in the config:

`sudo echo "externalip=<YourMonetaryUnitPublicIP> "-e/etc/monetaryunit/monetaryunit.conf`
`sudo service monetaryunit restart`

You also need to remove your /var/lib/monetaryunitd/bootstrap.dat.old once your node is synced.
`sudo rm /var/lib/monetaryunitd/bootstrap.dat.old`

For security purposes the configuration script enables two things:

1. The Ubuntu UFW (Uncomplicated Firewall). It leaves the MonetaryUnit daemon port (29948) and the standard SSH port (22) open.
2. Ubuntu's automatic security updates are enabled. This ensures that critical libraries are not left outdated.


## Assistance and Troubleshooting

If you run into issues please reach out to the MonetaryUnit community for assistance using any of the following:

- IRC: [#monetaryunit](irc://chat.freenode.net/#monetaryunit) on Freenode
- [The MonetaryUnit Twitter](https://twitter.com/monetaryunit)
- [The MonetaryUnit Announcments Forum](https://bitcointalk.org/index.php?topic=778322.new#new)
