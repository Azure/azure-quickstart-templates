# Deploy a Linux HDInsight cluster with new Data Lake Store and Storage accounts.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-datalake-store-azure-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-datalake-store-azure-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-datalake-store-azure-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-datalake-store-azure-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-datalake-store-azure-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-datalake-store-azure-storage/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-datalake-store-azure-storage%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-datalake-store-azure-storage%2Fazuredeploy.json)

This template allows you to deploy a new Linux HDInsight cluster with new Data Lake Store and Storage accounts.

### Prerequisites ###

**PFX Certificate and Service Principal**

In order to properly deploy this ARM template, you need to first create a service principal in your Azure Active directory.

This service principal needs to be configured to use a password-protected PFX certificate for authentication.
 
Below are instructions for creating the certificate and service principal.

1. Create a password-protected PFX certificate.
   
    In Windows, you can do this using Azure PowerShell.
    
        $certFolder = "C:\certificates"
        $certFilePath = "$certFolder\certFile.pfx"
        $certStartDate = (Get-Date).Date
        $certStartDateStr = $certStartDate.ToString("MM/dd/yyyy")
        $certEndDate = $certStartDate.AddYears(1)
        $certEndDateStr = $certEndDate.ToString("MM/dd/yyyy")
        $certName = "HDI-ADLS-SPI"
        $certPassword = "new_password_here"
        $certPasswordSecureString = ConvertTo-SecureString $certPassword -AsPlainText -Force
        
        mkdir $certFolder
        
        $cert = New-SelfSignedCertificate -DnsName $certName -CertStoreLocation cert:\CurrentUser\My -KeySpec KeyExchange -NotAfter $certEndDate -NotBefore $certStartDate
        $certThumbprint = $cert.Thumbprint
        $cert = (Get-ChildItem -Path cert:\CurrentUser\My\$certThumbprint)
        
        Export-PfxCertificate -Cert $cert -FilePath $certFilePath -Password $certPasswordSecureString

2. Create a service principal using the certificate.

    In Windows, you can do this using Azure PowerShell.

        $clusterName = "new-cluster-name-here"
        $certificatePFX = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certFilePath, $certPasswordSecureString)
        $credential = [System.Convert]::ToBase64String($certificatePFX.GetRawCertData())
        
        $application = New-AzureRmADApplication -DisplayName $certName `
                                -HomePage "https://$clusterName.azurehdinsight.net" -IdentifierUris "https://$clusterName.azurehdinsight.net"  `
                                -KeyValue $credential -KeyType "AsymmetricX509Cert" -KeyUsage "Verify"  `
                                -StartDate $certStartDate -EndDate $certEndDate
                                
        $servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId

3. Obtain the service principal information needed for the ARM template deployment.

    In Windows, you can do this using Azure PowerShell.

    * Application ID: ``$servicePrincipal.ApplicationId``
    * Object ID: ``$servicePrincipal.Id``
    * AAD Tenant ID: ``(Get-AzureRmContext).Tenant.TenantId``
    * Base-64 PFX file contents: ``[System.Convert]::ToBase64String((Get-Content $certFilePath -Encoding Byte))``
    * PFX password: ``$certPassword``


