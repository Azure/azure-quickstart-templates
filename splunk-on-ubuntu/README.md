# Install Splunk Enterprise on Ubuntu VM using custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsplunk-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys Splunk Enterprise on Ubuntu VM with 2 data drives in RAID0 configuration. The template also provisions a storage account, a virtual network with subnets, public IP address, and network interfaces required.

The instance has SSH port 22 open as well as port 8000 for HTTP, 9997 for TCP receiver traffic, and 8089 for Management.

Once the deployment is complete, Splunk Enterprise instance can be accessed using the configured DNS address. The DNS address will include the `dnsDomain` and `location` entered as parameters in the format `{dnsDomain}.{location}.cloudapp.azure.com`. If you created a deployment with the dnsName parameter set to splunk in the West US region you could access Splunk Enterprise VM at `http://splunk.westus.cloudapp.azure.com:8000`.

##Known Issues and Limitations

- The template sets up SSH access via admin username/password, and would ideally use an SSH key
- The template currently does not set up HTTPS access yet. For now, please follow instructions in Splunk Docs to easily turn on encryption [with default certificates](http://docs.splunk.com/Documentation/Splunk/latest/Security/TurnonbasicencryptionwithSplunkWeb) or [with your own certificates](http://docs.splunk.com/Documentation/Splunk/latest/Security/SecureSplunkWebusingasignedcertificate)

