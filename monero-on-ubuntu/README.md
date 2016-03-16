![Monero-on-Ubuntu](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/monero-on-ubuntu/images/monero-logo.png)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonero-on-ubuntu%2Fazuredeploy.json) [![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmonero-on-ubuntu%2Fazuredeploy.json)

# Monero Full Node on Ubuntu

The simplest way to get up-and-running with Monero on Azure!

Once deployed the script will start the Monero full node daemon, and it will begin syncing up to the network. This typically takes anything from an hour to several hours, depending on your Azure instance's connectivity, performance, and bandwidth.

## Monitoring and Interacting with the Node

For ease-of-access the Monero node runs in a screen session. This allows you to quickly bring the screen to the foreground and see the most recent log entries. You can do this by running ```screen -x```, or if you have other screen sessions then ```screen -x bm```.

By default the Monero node's JSON RPC API is served, to localhost only, on port 18081. Should you wish to access the JSON RPC API externally (not totally recommended, but there are specific use-cases for it) please note that you will have to open the port through UFW, and you will need to modify the ```~/bm_watchdog.sh``` file to include a ```--rpc-bind-ip 0.0.0.0``` flag.

After doing this you can exit the daemon either by running ```~/bitmonerod exit```, or by running the ```exit``` command from within the screen session.

## System Configuration

For security purposes the configuration script enables two things:

1. The Ubuntu UFW (Uncomplicated Firewall). It leaves the Monero daemon port (18080) and the standard SSH port (22) open.
2. Ubuntu's automatic security updates are enabled. This ensures that critical libraries are not left outdated.

## Assistance and Troubleshooting

If you run into issues please reach out to the Monero community for assistance using any of the following:

- IRC: [#monero-dev](irc://chat.freenode.net/#monero-dev) or [#monero](irc://chat.freenode.net/#monero) on Freenode
- [The Monero Forum](https://forum.getmonero.org)
- [The Monero Sub-Reddit](https://reddit.com/r/Monero/)