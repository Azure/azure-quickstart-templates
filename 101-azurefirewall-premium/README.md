# Create Azure Firewall with IP Groups

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurefirewall-premium/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-premium%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurefirewall-premium%2Fazuredeploy.json)

This template deploys an Azure Firewall Premium which includes IDPS, TLS Inspection and Web Category filtering.

## Certificate Generation
For TLS inspection, one needs to provide a valid CA certificate to be used for signing dynamically for new certificates. This sample template includes a script to generate the necessary certificates.

```
# Generate the certificates
cd scripts
./cert.sh

# Expected output
# ================
# Successfully generated root and intermediate CA certificates
#    - rootCA.crt/rootCA.key - Root CA public certificate and private key
#    - interCA.crt/interCA.key - Intermediate CA public certificate and private key
#    - interCA.pfx.base64 - Base64 encoded intermediate CA pkcs12 package to be consumed by caPfxEncodedInBase64 template parameter
#    - rootCA.crt.base64 - Base64 encoded root PEM certificate to be consumed by the  rootPemEncodedInBase64 template parameter
# ================
```

Following the script, plug in the following files into the template
- **rootCA.crt.base64** - `rootPemEncodedInBase64` template parameter
- **interCA.pfx.base64** - `caPfxEncodedInBase64` template parameter