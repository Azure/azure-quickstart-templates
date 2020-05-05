# Apprenda 6.0 Small Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/apprenda60-small/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/apprenda60-small/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/apprenda60-small/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/apprenda60-small/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/apprenda60-small/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/apprenda60-small/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapprenda60-small%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapprenda60-small%2Fazuredeploy.json)

## GETTING STARTED

### Notes and Prerequisites

- Apprenda Licensing for the Apprenda Azure Certified Image is free for the first month (trial period). After the first month the cost is $0.10/hour. This includes up to 16GB in memory for your virtual machines, so please allocate wisely.
- You are responsible for the cost of operating the Virtual Machine in Azure. Consult the Azure Pricing details for the Tier of your choice to get an estimate of the cost. We recommend using at least an A4 workload for the Apprenda virtual machine for optimal performance.

### Completing the Installation

1. Once you have connected to the platform node VM, launch a browser with the following URLs (links to both are created in the desktop)

- Operator Portal (https://apps.apprenda.<computername>/SOC)

  - Developer Portal (https://apps.apprenda.<computername>/Developer)

  - Your credentials are the plaftorm administrator email and password you provided during provisioning time.

1. Use the following link to TimeCard.zip to create your first application in the Apprenda Developer Portal: http://docs.apprenda.com/sites/default/files/TimeCard.zip

1. Don’t forget to configure or enable the following services and components

- Windows Updates
- Windows Firewall
- Windows SmartScreen

For a useful video of how this VHD is being utilized in Microsoft Azure Marketplace as an Azure Certified Image, follow this link: https://www.youtube.com/watch?v=rmnO5KhDYus

### START HERE. THEN TAKE APPRENDA HOME

With the Apprenda 6.0 Express Cluster, you can experience most of the functionality of the Apprenda Enterprise Private PaaS, before installing the platform within your enterprise IT environment or in Microsoft Azure. Everything you do with this image of Apprenda can be deployed on your own compute capacity in the private, public, or hosted cloud.

## ADDITIONAL RESOURCES

1. Sign up for the monthly free tutorial
2. Arrange a Proof-of-Concept (PoC) for your organization

## About Apprenda

Apprenda is the leading enterprise Platform as a Service (PaaS) powering the next generation of enterprise software development in public, private and hybrid clouds. As a foundational software layer and application run-time environment, Apprenda abstracts away the complexities of building and delivering modern software applications, enabling enterprises to turn ideas into innovations faster. With Apprenda, enterprises can securely deliver an entire ecosystem of data, services, applications and APIs to both internal and external customers across any infrastructure. From the world’s largest banks like JPMorgan Chase to healthcare organizations including McKesson and AmerisourceBergen, Apprenda’s clients are part of a new class of software-defined enterprises, disrupting industries and winning with software. For more information, visit Apprenda at www.apprenda.com.

