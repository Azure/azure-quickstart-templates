# Pivotal Apigee Azure Quickstart

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpivotalcloudfoundry-apigee%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpivotalcloudfoundry-apigee%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

#### IMPORTANT: Before you deploy the template make sure you have accepted Pivotal End User License Agreement:

Elastic Runtime 1.7.15:
https://network.pivotal.io/products/elastic-runtime/releases/2134/eula

MySQL for PCF 1.7.8:
https://network.pivotal.io/products/p-mysql/releases/1770/eula

RabbitMQ for PCF 1.6.0:
https://network.pivotal.io/products/pivotal-rabbitmq-service/releases/1799/eula

Redis for PCF 1.5.15:
https://network.pivotal.io/products/p-redis/releases/1876/eula

Spring Cloud Services for PCF 1.0.9:
https://network.pivotal.io/products/p-spring-cloud-services/releases/1735/eula

## Solution Template Summary
The Solution stack deploys Pivotal Cloud Foundry, Concourse CI, Apigee Edge Gateway, Apigee Service Broker and Azure Meta Service Broker
![Solution Summary](https://github.com/sysgain/azurequickstarts/blob/vcherukuri-patch-1/PivtoalCloudFoundry-Concourse-Apigee-AzureMetaService/pivotal-P2P/Images/Solution%20Summary.png?raw=true)

Apigee and Pivotal partnered to provide comprehensive API management capabilities that expedite the scalable delivery of apps on the powerful Pivotal Cloud Foundry platform. Apigee Edge is available for rapid deployment as a partner service in the Pivotal Network. Developers use Apigee Edge as a Pivotal Cloud Foundry partner service. 
Pivotal Cloud Foundry’s service broker API is used to create the Apigee service broker, which enables the provisioning and configuration of Edge instances bound to client apps. When Edge is configured, the route service intelligently routes API traffic to and from Edge, thereby leveraging Apigee's broad range of features related to traffic management, mediation, policy enforcement, and analytics. Developers in a customers's ecosystem consume and test their APIs using Apigee's developer portal.

The Apigee service broker supports Apigee Edge, including Trial, SMB, Startup, and Enterprise.

![Pivotal Cloud Foundry Integration with Apigee Edge Gateway](https://github.com/sysgain/azurequickstarts/blob/vcherukuri-patch-1/PivtoalCloudFoundry-Concourse-Apigee-AzureMetaService/pivotal-P2P/Images/Solution%20Integration.png?raw=true)



## Product Architecture
![Product Architecture](https://raw.githubusercontent.com/sysgain/pivotal/master/pivotal-P2P-Architecture.jpg)

## Solution contains the following

The diagram above provides the overall deployment architecture for this solution template.
As a part of deployment, the template launches the following:

Pivotal Cloud Foundry

Concourse Continuous Integration

Apigee Edge Gateway

Azure Meta Service Broker

### Pivotal Cloud Foundry

Pivotal cloud foundry offer developers a production-ready application container runtime and fully automated service deployments. Meanwhile, operations teams can sleep easier with the visibility and control made possible by platform-enforced policies and automated lifecycle management.

Cloud Foundry supports the full lifecycle, from initial development, through all testing stages, to deployment. It is therefore well-suited to the continuous delivery strategy. Users have access to one or more spaces, which typically correspond to a lifecycle stage. For example, an application ready for QA testing might be pushed (deployed) to its project's QA space. Different users can be restricted to different spaces with different access permissions in each.
### Concourse Continuous Integration

Concourse is a simple and scalable way to declare your continuous integration as code.
Concourse limits itself to three core concepts: tasks, resources, and the jobs that compose them. 

-A task is the execution of a script in an isolated environment with dependent resources available to it. A task can either be executed by a Job or executed manually with the Fly CLI.

-A resource is any entity that can be checked for new versions, pulled down at a specific version, and/or pushed up to idempotently create new versions.

-Jobs can be thought of as functions with inputs and outputs, that automatically run when new inputs are available. A job can depend on the outputs of upstream jobs, which is the root of pipeline functionality.

-Concourse “pipelines” are YAML files that declare resources to use, e.g. Git repos or Docker images, and contain a set of jobs to execute. In turn, jobs are sub-divided into tasks and each task runs in a container. 

-An instance of execution of a job's plan is called a build. Builds in Concourse are reproducible since their tasks run afresh in new containers. 

### Apigee Edge Gateway

Apigee Edge is a platform for developing and managing API proxies. The primary consumers of Edge API proxies are app developers who want to use your backend services. The API proxy isolates the app developer from your backend service. 
Rather than having app developers consume your services directly, they access an API proxy created on Edge. The API proxy functions as a mapping of a publicly available HTTP endpoint to your backend service.  By creating an API proxy you let Edge handle the security and authorization tasks required to protect your services, as well as to analyze, monitor, and monetize those services.

#### Components of Apigee Edge

-Edge API Services - Apigee Edge API Services are all about creating and consuming APIs, whether you're building API proxies as a service provider or using APIs, SDKs, and other convenience services as an app developer.

-Edge Analytics Services - Apigee Edge Analytics Services provides powerful tools to see short- and long-term usage trends of your APIs.

-Edge Developer Services - Apigee Edge Developer Services provide the tools to manage the community of app developers using your services.

### Azure Meta Service Broker

A service broker to manage multiple Azure services in Cloud Foundry.
Azure Meta Service Brokers are available for the following services:

Azure Storage Blob Service - Azure Storage Service offers reliable, economical cloud storage for data big and small. This broker currently publishes a single service and plan for provisioning Azure Storage Blob Service.

Azure Redis Cache Service - Azure Redis Cache is based on the popular open-source Redis cache. It gives you access to a secure, dedicated Redis cache, managed by Microsoft and accessible from any application within Azure. This broker currently publishes a single service and plan for provisioning Azure Redis Cache.

Azure DocumentDB Service - Azure DocumentDB is a NoSQL document database service designed from the ground up to natively support JSON and JavaScript directly inside the database engine.

Azure Service Bus Service - Azure Service Bus keep apps and devices connected across private and public clouds. This broker currently publishes a single service and plan for provisioning Azure Service Bus Service.

Azure SQL Database Service - Azure SQL Database is a relational database service in the cloud based on the market-leading Microsoft SQL Server engine, with mission-critical capabilities.

### RESOURCES

56 Virtual Machines
Document DB
SQL Server
3 Public IP Addresses


## Deployment Steps

You can click the “Deploy to Azure” button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.
Please refer to parameter descriptions if you need more information on what needs to be provided as an input.

The deployment takes about 5 Hours. 

To work with Pivotal Cloud Foundry Hands on Lab click [here](http://pcf-ignite.pcfazure.com/Labs/)


