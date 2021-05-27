# [<img style="width:100%;" src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/dist/images/banner.png">](https://trailbot.io)

# Secure Ubuntu by Trailbot

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/trailbot/stampery-trailbot-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/trailbot/stampery-trailbot-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/trailbot/stampery-trailbot-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/trailbot/stampery-trailbot-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/trailbot/stampery-trailbot-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/trailbot/stampery-trailbot-ubuntu/CredScanResult.svg)

This Ubuntu VM comes with a special demon called __Trailbot Watcher__ that monitors system files and logs, triggers __Smart Policies__ upon modification and generates a __blockchain-anchored__, __immutable audit trail__ of everything happening to them.

[Smart Policies](https://github.com/trailbot/client/wiki/Smart-Policies) are simple scripts that get called every time a tracked file changes. They trigger actions such as emailing someone, rolling files back or even shutting the system down. There are [plenty of them ready to use](https://github.com/trailbot/client/wiki/Smart-Policies#ready-to-use-policies), and you can even [create your own](https://github.com/trailbot/client/wiki/Smart-Policies).

You can manage your Smart Policies and audit trails by using the [Trailbot Client] desktop app.

All the files and logs watched in this VM will have the [Stamper Smart Policy](https://github.com/trailbot/stamper-policy) configured by default, so every time such files are modified, their hashes will be embedded in both the Ethereum and Bitcoin blockchains by using the [Stampery API](https://stampery.com/tech).

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftrailbot%2Fstampery-trailbot-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftrailbot%2Fstampery-trailbot-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftrailbot%2Fstampery-trailbot-ubuntu%2Fazuredeploy.json)



`Tags: Blockchain, Ubuntu, Security, Integrity, Bitcoin, Ethereum, Stampery`

## Getting Started Tutorial

* Download and install [Trailbot Client](https://github.com/trailbot/client) in your computer.
* Run Trailbot Client, generate and export a _client public key_.
* Click the `Deploy to Azure` icon above
* Complete the template parameters including the client public key, choose your resource group, accept the terms and click Create
* Wait about 15 minutes for the VM to spin up and install the software
* Then you will receive the _watcher public key_ in your email (check SPAM folder, just in case)
* Import the _watcher public key_ into the Trailbot Client and you are ready to play.

## Usage

You can find detailed usage instructions in the [Getting Started guide](https://github.com/trailbot/client/blob/master/GETTING-STARTED.md#usage).

[<img style="width:100%;" src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/images/footer.png">](https://stampery.com)


