# Deploy a CoreOS cluster hosting Fleet 

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a CoreOS cluster with Fleet deployed and started on each cluster node. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface. 

You will need to provide a key pair for authentication to the nodes as well as a cloud-config.yaml file to configure Fleet.

Step-1: Generate a OpenSSH Key Pair. You will get a public and private key. The private key will be of the format : -----BEGIN RSA PRIVATE KEY-----base64encodedprivatekey-----END RSA PRIVATE KEY-----

Step-2: Now use openssl to get a public certificate for the generated private key. The following sample command should help you do that: openssl.exe req -x509 -days 365 -new -key "<Path>\privatekeyopenssh.pem" -out "publickeycert.cer" -config openssl.cnf. The certificate generated should be this format - -----BEGIN CERTIFICATE-----base64encodedpublickey-----END CERTIFICATE-----

Step-3: In the template file, you need to pass the base64encodedpublickey (after stripping off Begin and End Certificate header) as the sshKeyData value.

Note: In the next few weeks, we will make a breaking API change to update the APIs to accept the sshKeyData in the following format - ssh-rsa <publickey> keyComment.


The cloud-config.yaml file requires a distinct discovery ID to identify the cluster. You can use the CoreOS discovery service to generate the discovery ID by running the following command:

curl https://discovery.etcd.io/new | grep ^http.* > etcdid

This will provide a token like the following that must be inserted in the cloud-config.yaml file:

https://discovery.etcd.io/dcf78d9803b417e1a3eeb15987bdf82f

The following is a sample cloud-config.yaml file:

#cloud-config

coreos:
  etcd:
    # generate a new token for each unique cluster from https://discovery.etcd.io/new
    discovery: https://discovery.etcd.io/dcf78d9803b417e1a3eeb15987bdf82f
    # deployments across multiple cloud services will need to use $public_ipv4
    addr: $private_ipv4:4001
    peer-addr: $private_ipv4:7001
  units:
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start

This file must be base64 encoded and set as the customData value in azuredeploy-parameters.json


Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | location where the resources will be deployed |
| newStorageAccountName | new storage account for the VMs OS disk |
| vmNamePrefix | prefix for the names of each VM |
| virtualNetworkName | name for the new VNET |
| imageSku | SKU for the CoreOS VM image |
| imageVersion | version for the CoreOS VM image |
| vmSize | Instance size for the VMs |
| numberOfNodes | Number of CoreOS compute nodes to deploy |
| adminUsername | Name of the admin user | 
| sshKeyData | Explained above |
| customData | Explained above |

