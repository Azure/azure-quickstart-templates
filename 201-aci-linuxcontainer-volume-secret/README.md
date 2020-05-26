# Azure Container Instances

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-linuxcontainer-volume-secret/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-linuxcontainer-volume-secret/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-linuxcontainer-volume-secret/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-linuxcontainer-volume-secret/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-linuxcontainer-volume-secret/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-aci-linuxcontainer-volume-secret/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-aci-linuxcontainer-volume-secret%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-aci-linuxcontainer-volume-secret%2Fazuredeploy.json)

This template demonstrates a simple use case for secret volumes of [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/). When creating a container with the image containerinstance/helloworld:ssl, it sets up HTTP connections with the certificate and password passed in as secret volumes.

A PFX certificate is encoded in Base64 and mounted as a secret volume. Inside the container the certificate is accessible as a file with path /mnt/secrets/sslcertificateData. The password of the PFX certificate is also encoded in Base64, and mounted as a secret volume. Inside the container the certificate is accessible as a file with path /mnt/secrets/sslcertificatePwd.

The parameters sslcertificateData and sslcertificatePwd are only for demo purpose. Please create your own certificate when creating container groups. 


