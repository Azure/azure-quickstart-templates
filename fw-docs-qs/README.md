# Azure Firewall with multiple public IP addresses Quickstart

    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/fw-docs-qs/PublicLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/fw-docs-qs/PublicDeployment.svg" />&nbsp;

    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/fw-docs-qs/FairfaxLastTestDate.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/fw-docs-qs/FairfaxDeployment.svg" />&nbsp;
    
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/fw-docs-qs/BestPracticeResult.svg" />&nbsp;
    <IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/fw-docs-qs/CredScanResult.svg" />&nbsp;
    
    
    <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ffw-docs-qs%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
    </a>
    <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ffw-docs-qs%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
    </a>

This template deploys an **Azure Firewall** with multiple public IP addresses. The firewall has NAT rules to allow RDP traffic to the two test virtual machines.

The backend virtual machines are *Standard_B2ms* virtual machines running Windows Server 2019.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

This template is used by the Azure Firewall documentation Quick Start article.

`Tags: Azure Firewall`
