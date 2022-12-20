# Deploying Openchain on Microsoft Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/blockchain/openchain-blockchain-coinprism/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/blockchain/openchain-blockchain-coinprism/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/blockchain/openchain-blockchain-coinprism/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/blockchain/openchain-blockchain-coinprism/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/blockchain/openchain-blockchain-coinprism/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/blockchain/openchain-blockchain-coinprism/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fblockchain%2Fopenchain-blockchain-coinprism%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fblockchain%2Fopenchain-blockchain-coinprism%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fblockchain%2Fopenchain-blockchain-coinprism%2Fazuredeploy.json)

Openchain is an open source distributed ledger technology. It is suited for organizations wishing to issue and manage digital assets in a robust, secure and scalable way.

Please follow these steps to deploy Openchain on Microsoft Azure.

## Generate an admin seed

The admin seed will be used to authenticate as an administrator on the Openchain instance. The administrator is a superuser and has the ability to perform several administrative operations.

To generate an admin seed, go to https://wallet.openchain.org. If this is the first time you access the wallet, you will be prompted for an endpoint URL, click the link to use the test instance.

You will then be directed to the "Sign in" page. Click on "Create a new wallet". A seed will be showed, write down this seed, and store it in a safe place. Press back, and type the seed in the "Passphrase" box.

After a few seconds, you will see the home screen. On the right, an address is displayed. It will look like ``XaykLnzmAPVMcGYQ51BvpJRJ9KQ34ssoPL``. Copy this address, it represents the admin public key.

## Start the deployment

In order to deploy Openchain, you will need the following pieces of information:

* ``storageAccountNamePrefix``: A unique name for the Storage Account where the Virtual Machine's disks will be placed.
* ``vmSize``: The size of the virtual machines used when provisioning the node.
* ``openchainVersion``: The Openchain version to deploy.
* ``openchainAdminKey``: The admin public key obtained in the previous section of this document.
* ``adminUsername``: The username used to log in onto the Virtual Machine.
* ``adminPassword``: The password used to log in onto the Virtual Machine.
* ``dnsLabelPrefix``: A unique name used for the public IP used to access the Openchain instance.
* ``openPermissions``: If True, anyone can join the ledger after generating a key pair. If False, users must be [granted permission](https://docs.openchain.org/en/latest/ledger-rules/closed-loop.html) to transact on the ledger (except for the admin).

Once the deployment has completed, you will receive the ``endpointURL`` that can be used to connect to the Openchain instance.

## Connect to the Openchain instance

Go to [http://nossl.wallet.openchain.org/](nossl.wallet.openchain.org). Enter the admin seed when prompted.

If you are connecting to this wallet endpoint for the first time, you will be prompted for the endpoint URL. Use the ``endpointURL`` obtained when the deployment completed. If you are not prompted, after authenticating with the admin seed, go to "Account" on the top right, and click "Add server...", then enter the endpoint URL obtained when the deployment completed.

## Configure the ledger information

Go to the Advanced tab and click Edit Ledger Info on the left. The screen will show you a form that will let you edit the ledger name and other fields stored in the [info record](https://docs.openchain.org/en/latest/ledger-rules/general.html#ledger-info-record).


