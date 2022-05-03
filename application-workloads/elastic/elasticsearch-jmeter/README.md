# Deploy a JMeter test environment for Elasticsearch

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-jmeter/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-jmeter/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-jmeter/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-jmeter/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-jmeter/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-jmeter/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch-jmeter%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch-jmeter%2Fazuredeploy.json)

This template will deploy a JMeter environment into an existing virtual network. One master node and multiple subordinate nodes are deployed into a new subnet called jmeter, with the address prefix 10.0.4.0/24. This template works in conjunction with the Elasticsearch template at https://github.com/Azure/azure-quickstart-templates/tree/master/elasticsearch, and it is recommended you deploy that template first, followed by this one. 

The topology of the test environment is described further at https://github.com/Azure/azure-content/blob/master/articles/guidance/guidance-elasticsearch-creating-performance-testing-environment.md.

If you are deploying this template into an existing virtual network which was not created with the above template, please update the JMeter parameters in /opt/jmeter/run.properties on the master node.

The jarball should contain any JUnit tests and dependent jars which are needed by the JMX test plan in the test pack. By default the test plan and parameters are provided from the load test described at https://github.com/Azure/azure-content/blob/master/articles/guidance/guidance-elasticsearch-deploying-jmeter-junit-sampler.md. 

##Notes

Start the test run using /opt/jmeter/run.sh on the master node, and view the results in Marvel as well as in the resulting CSV logs. For more details on this test plan please see https://github.com/Azure/azure-content/blob/master/articles/guidance/guidance-elasticsearch-implementing-jmeter-test-plan.md. 


