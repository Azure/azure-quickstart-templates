# SAP NetWeaver 3-tier compatible template using a Marketplace image - MD

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-md/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-md/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-md/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-md/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-md/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-3-tier-marketplace-image-md/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-marketplace-image-md%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-marketplace-image-md%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-3-tier-marketplace-image-md%2Fazuredeploy.json)

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver, using the latest patched version of the selected operating system. This is a template for a 3-tier configuration. It deploys 1 (no HA) or 2 (HA) ASCS/SCS servers, 1 (no HA) or 2 (HA) database servers and serveral virtual machines that can host dialog instances. In case of a HA deployment, the ASCS/SCS and DB servers are placed in Availability Sets and a Standard Load Balancer is added to the ASCS/SCS and DB server to allow HA configurations in the operating system (e.g. Windows Failover Cluster).
This template uses Managed Disks.

## ASCS/SCS Internal Load Balancer ports

* Cluster Administration Endpoint Ports: HA ports enabled, all ports are loadbalanced
* ASCS Ports (instance number 00): HA ports enabled, all ports are loadbalanced
* SCS Ports (instance number 01):  HA ports enabled, all ports are loadbalanced
* ASCS ERS ports (instance number 02):  HA ports enabled, all ports are loadbalanced
* SCS ERS ports (instance number 03):  HA ports enabled, all ports are loadbalanced

Cluster Administration Load Balancer probe port: **63500**

ASCS Internal Load Balancer probe port: **62000**

SCS Internal Load Balancer probe port: **62001**

ABAP ERS Internal Load Balancer probe port: **62102**

JAVA ERS Internal Load Balancer probe port: **62103**

## DB Internal Load Balancer ports

* Cluster Administration Endpoint Ports: HA ports enabled, all ports are loadbalanced
* DB Internal Load Balancer ports: HA ports enabled, all ports are loadbalanced

Cluster Administration Load Balancer probe port: **63500**

HANA DB Internal Load Balancer probe port: **62504**

SQL DB Internal Load Balancer probe port: **62500**

|Size|DB Type|HA|Non-HA|
|--- |--- |--- |--- |
|Demo|HANA|2xStandard_E8s_v3 DB Server (7xP10) + 2xStandard_DS2_v3 ASCS/SCS (1xP10) + 2xStandard_DS2_v3 DI (1xP10)|1xStandard_E8s_v3 DB Server (7xP10) + 1xStandard_DS2_v3 ASCS/SCS (1xP10) + 1xStandard_DS2_v3 DI (1xP10)|
|Demo|SQL|2xStandard_E4_v3 DB Server (1xP10) + 2xStandard_DS2_v3 ASCS/SCS (1xP10) + 2xStandard_DS2_v3 DI (1xP10)|1xStandard_E4_v3 DB Server (1xP10) + 1xStandard_DS2_v3 ASCS/SCS (1xP10) + 1xStandard_DS2_v3 DI (1xP10)|
|Small < 30.000 SAPS|HANA|2xStandard_E32s_v3 DB Server (5xP20 1xP6) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E8_v3 DI (1xP10)|1xStandard_E32s_v3 DB Server (5xP20 1xP6) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E8_v3 DI (1xP10)|
|Small < 30.000 SAPS|SQL|2xStandard_E8_v3 DB Server (5xP20) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E8_v3 DI (1xP10)|1xStandard_E8_v3 DB Server (5xP20) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E8_v3 DI (1xP10)|
|Medium < 70.000 SAPS|HANA|2xStandard_E64s_v3 DB Server (1xP30 4xP20 1xP6) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E8_v3 DI (1xP10)|1xStandard_E64s_v3 DB Server (1xP30 4xP20 1xP6) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E8_v3 DI (1xP10)|
|Medium < 70.000 SAPS|SQL|2xStandard_E16_v3 DB Server (8xP20) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E8_v3 DI (1xP10)|1xStandard_E16_v3 DB Server (8xP20) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E8_v3 DI (1xP10)|
|Large < 180.000 SAPS|HANA|2xStandard_M64s DB Server (3xP30 6xP20 1xP6) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E16_v3 DI (1xP10)|1xStandard_M64s DB Server (3xP30 6xP20 1xP6) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E16_v3 DI (1xP10)|
|Large < 180.000 SAPS|SQL|2xStandard_E32_v3 DB Server (5xP30 1xP20) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E16_v3 DI (1xP10)|1xStandard_E32_v3 DB Server (5xP30 1xP20) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E16_v3 DI (1xP10)|
|X-Large < 250.000 SAPS|HANA|2xStandard_M128s DB Server (2xP40 4xP30 2xP20 1xP6) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E16_v3 DI (1xP10)|1xStandard_M128s DB Server (2xP40 4xP30 2xP20 1xP6) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E16_v3 DI (1xP10)|
|X-Large < 250.000 SAPS|SQL|2xStandard_E64_v3 DB Server (8xP30) + 2xStandard_E2_v3 ASCS/SCS (1xP10) + 2xStandard_E16_v3 DI (1xP10)|1xStandard_E64_v3 DB Server (8xP30) + 1xStandard_E2_v3 ASCS/SCS (1xP10) + 1xStandard_E16_v3 DI (1xP10)|
