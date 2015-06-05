# Deploy a Virtual Machine with SSH Keys

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Linux Virtual Machine with SSH Keys. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Step-1: Generate a OpenSSH Key Pair. You will get a public and private key. The private key will be of the format : -----BEGIN RSA PRIVATE KEY-----base64encodedprivatekey-----END RSA PRIVATE KEY-----

Step-2: Now use openssl to get a public certificate for the generated private key. The following sample command should help you do that: openssl.exe req -x509 -days 365 -new -key "<Path>\privatekeyopenssh.pem" -out "publickeycert.cer" -config openssl.cnf. The certificate generated should be this format - -----BEGIN CERTIFICATE-----base64encodedpublickey-----END CERTIFICATE-----

Step-3: In the template file, you need to pass the base64encodedpublickey (after stripping off Begin and End Certificate header) as the sshKeyData value.

Note: In the next few weeks, we will make a breaking API change to update the APIs to accept the sshKeyData in the following format - ssh-rsa <publickey> keyComment.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| sshKey  | Explained in Detail above |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| subscriptionId  | Subscription ID where the template will be deployed |
| vmSourceImageName  | Source Image Name for the VM. Example: b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_5-LTS-amd64-server-20140927-en-us-30GB |
| location | location where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |
| publicIPAddressName | Name of Public IP Address Name |
| nicName | Name of Network Interface |
