# Microsoft

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/devopstools-jenkins-chefhabitat-kubernetes/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/devopstools-jenkins-chefhabitat-kubernetes/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/devopstools-jenkins-chefhabitat-kubernetes/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/devopstools-jenkins-chefhabitat-kubernetes/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/devopstools-jenkins-chefhabitat-kubernetes/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/devopstools-jenkins-chefhabitat-kubernetes/CredScanResult.svg)

# OSS Quickstart (Phase-2)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdevopstools-jenkins-chefhabitat-kubernetes%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdevopstools-jenkins-chefhabitat-kubernetes%2Fazuredeploy.json)



**Table of Contents**  

- [Solution Architecture:](#solution-architecture)
- [Terraform:](#terraform)
- [Kubernetes:](#Kubernetes)
	- [Why Kubernetes?:](#WhyKubernetes?)
- [ELK Stack:](#elk-stack)
	- [Elasticsearch:](#elasticsearch)
	- [Logstash—Routing Your Log Data:](#logstashrouting-your-log-data)
	- [Kibana—Visualizing Your Log Data:](#kibanavisualizing-your-log-data)
	- [Beats—Lightweight Data Shippers:](#beatslightweight-data-shippers)
	- [The following logs are visualized in Kibana:](#the-following-logs-are-visualized-in-kibana)
- [Jenkins:](#jenkins)
	- [Plugins:](#plugins)
	- [Kubernetes Continuous Deploy plugin](#kubernetes-continuous-deploy-plugin)
	- [Packer plugin:](#packer-plugin)
	- [Jenkins Pipeline](#jenkins-pipeline)
- [Azure Storage Account:](#azure-storage-account)
- [Chef Habitat:](#chef-habitat)
	- [Why Habitat?](#why-habitat)
	- [Packaging an Application with Habitat:](#packaging-an-application-with-habitat)
	- [Habitat Components:](#habitat-components)
	- [Habitat Packaging Format:](#habitat-packaging-format)
	- [Habitat Highlights:](#habitat-highlights)
- [Prerequisites:](#prerequisites)
	- [Generate your SSH key:](#generate-your-ssh-key)
	- [Create Service principal](#create-service-principal)
- [Deploy the ARM Template:](#deploy-the-arm-template)
- [Environment Details:](#environment-details)
- [Solution Workflow:](#solution-workflow)
- [Jobs](#jobs)
- [Executing the Jobs](#executing-the-jobs)
	- [ELKJob](#elkjob)
	- [KubernetesClusterjob](#kubernetesclusterjob)
	- [VMSSjob](#vmssjob)
- [Chef Habitat:](#chef-habitat)
 	- [Configuring Habitat:](#configuring-habitat)
	- [Creating Hart File:](#creating-hart-file)
   	- [Get Azure Container Registry Password from Azure portal:](#get-azure-container-registry-password-from-azure-portal)
  	- [Uploading MongoDB HART file to Azure Container Registry:](#uploading-mongodb-hart-file-to-azure-container-registry)
  	- [Uploading National parks HART File to the Azure Container Registry:](#uploading-national-parks-hart-file-to-the-azure-container-registry)
  	- [Verify Docker Images in Azure Container Registry](#verify-docker-images-in-azure-container-registry)
- [Run VMSS Job](#run-vmss-job)
- [Verify Kubernetes Pods and Services](#verify-kubernetes-pods-and-services)
- [Access National Park Applications](#access-national-park-applications)
- [Verifying Application Logs](#verifying-application-logs)

## Solution Architecture:

This Solution will be helpfull to deploy an application using the integration of Jenkins, Chef Habitat and Kubernetes.

This solution will deploy the following architecture:

### Virtual Network with four subnets:

- Subnet1 – Jenkins server, Build instance with Chef Habitat
- Subnet2 – Kubernetes
- Subnet3 – Elastic Stack

1. Azure Load Balancer
2. Azure Storage Account
3. GitHub- The Terraform code is taken from GitHub and has been configured as a job in Jenkins.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/1.png)

## Terraform:

**Terraform** is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing popular service providers as well as custom in-house solutions.

Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure.

Terraform&#39;s manageable infrastructure includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

## Kubernetes:

**Kubernetes** is an orchestrator tool provides a platform for automatic deployment, scaling and operations of applications. It is a system for managing containerized applications across a cluster of nodes and Kubernetes uses etcd to store configuration data that can be used by each of the nodes in the cluster.

  ### Why Kubernetes?

- Developing and updating the software at scale.
- Better management through modularity.
- Kubernetes is the largest and fastest growing open source software solution focused on distributing system patterns.

## ELK Stack:

**Elastic** is the company behind Elastic stack, which is a suite of products including **E** lasticsearch, **L** ogstash and **K** ibana.  The ELK stack makes it easier and faster to search and analyze large data sets. Logstash is used to normalize the data, Elasticsearch processes, and then Kibana visualizes it.

 ### Elasticsearch

Elasticsearch is an open-source, broadly-distributable, readily-scalable, enterprise-grade search engine. Elasticsearch can power extremely fast searches that support your data discovery applications **.** Consider these benefits:

- **Real-time data and real-time analytics:** The ELK stack gives you the power of real-time data insights, with the ability to perform super-fast data extractions from virtually all structured or unstructured data sources. With real-time extraction and real-time analytics, Elasticsearch is the engine that gives you both power and speed.
- **Scalable, high-availability, multi-tenant:**   It is built to scale horizontally out of the box. As you need more capacity, simply add another node and let the cluster reorganize itself to accommodate and exploit the extra hardware. Elasticsearch clusters are resilient since they automatically detect and remove node failures. You can set up multiple indices and query each of them independently or in combination.
- **Full text search:** Elasticsearch uses Lucene to provide the most powerful full-text search capabilities available in any open-source product. The search features come with multi-language support, an extensive query language, geolocation support, context-sensitive suggestions, and autocompletion.
- **Document orientation:**  You can store complex, real-world entities in Elasticsearch as structured JSON documents. All fields have a default index, and you can use all the indices in a single query to get precise results in the blink of an eye.

 ### Logstash — Routing Your Log Data

**Logstash** is a tool for log data intake, processing, and output. This includes virtually any type of log that you manage: system logs, webserver logs, error logs, and app logs.  You can save a lot of time by training Logstash to normalize the data, getting Elasticsearch to process the data, and then visualizing it with Kibana. With Logstash, it&#39;s easy to take all those logs and store them in a central location. The only prerequisite is a Java runtime, and it takes just two commands to get Logstash up and running. Logstash will serve as the workhorse for storage, querying, and analysis of your logs. Since it has an arsenal of ready-made inputs, filters, codecs, and outputs, you can grab hold of a very powerful feature-set with a very little effort on your part. Think of Logstash as a pipeline for event processing: it takes precious little time to choose the inputs, configure the filters, and extract the relevant, high-value data from your log.

  ### Kibana — Visualizing Your Log Data

**Kibana** is your log-data dashboard. Get a better grip on your large data stores with point-and-click pie charts, bar graphs, trendlines, maps, and scatter plots. You can visualize trends and patterns for data that would otherwise be extremely tedious to read and interpret. Eventually, each business line can make practical use of your data collection as you help them customize their dashboards. Save it, share it, and link your data visualizations for quick and smart communication.

  ### Beats —  Lightweight Data Shippers

**Beats** is the platform for single-purpose data shippers. They install as lightweight agents and send data from hundreds or thousands of machines to Logstash or Elasticsearch. ELK allows Filebeat, Packetbeat, Metricbeat and Winlogbeat to ship log data from client servers.

**Filebeat** : For Text log files.                   **Metricbeat** : For OS and application.

**Packetbeat** : For Network monitoring.     **Winlogbeat** : For windows event logs.

**Flow Diagram:**
![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/2.png)

  ### The following logs are visualized in Kibana:
| S.NO | Nodes            | Logs Path|
| ---- |-------------     | -------- |
| 1    | Application Node | /hab/svc/national-parks/logs/, /hab/pkgs/core/tomcat8/8.5.9/20170514144202/tc/logs/, /root/sup-national-parks.log|
| 2    | mongoDB          | /hab/svc/mongodb/logs, /hab/svc/mongodb/var/mongod.log, /root/sup.mongodb.log|

## Jenkins:

**Jenkins**  is an open-source, continuous integration software tool written in the Java programming language for testing and reporting on isolated changes in a larger code base in real time. This software enables developers to find and solve defects in a code base rapidly and automate testing of their builds. There are also hundreds of **plugins**  available to enhance its power and usability.

  ### Plugins:

The concept of plugins makes Jenkins attractive, easy to learn, and easy to use. Jenkins has many plugins available for free. These plugins help to integrate with various software tools for better convenience.

In this solution, we are using the Kubernetes Continuous Deploy plugins.

**Kubernetes Continuous Deploy plugin:**

This plugin allows for a Jenkins plugin to deploy resource configurations to a Kubernetes cluster.
It supports three options as:

- It helps to Fill the contents in kubeconfig file directly
- It provides to Fetch cluster details through SSH connection to the mater node
- To get the kubeconfig file from the workspace path.

  ### Jenkins Pipeline

Jenkins Pipeline is a suite of plugins which supports implementing and integrating _continuous delivery pipelines_ into Jenkins.

A _continuous delivery pipeline_ is an automated expression of your process for getting software from version control through to users and customers. Every change to your software (committed in source control) goes through a complex process on its way to being released. This process involves building the software in a reliable and repeatable manner, as well as the progression of the built software (called a &quot;build&quot;) through multiple stages of testing and deployment. The Jenkins Pipeline automates large chunks of this process, making it easier to get vital changes to your users in a timely manner.

## Azure Storage Account:

**Microsoft Azure Storage** is a Microsoft-managed cloud service that provides storage that is highly available, secure, durable, scalable, and redundant. Microsoft takes care of maintenance and handles critical problems for you.

Azure Storage consists of three data services: Blob storage, File storage, and Queue storage. Blob storage supports both standard and premium storage, with premium storage using only SSDs for the fastest performance possible. Another feature is cool storage, allowing you to store large amounts of rarely accessed data for a lower cost. Azure Queue storage is a service for storing large numbers of messages that can be accessed from anywhere in the world via authenticated calls using HTTP or HTTPS.

To use any of the services provided by Azure Storage -- Blob storage, File storage, and Queue storage -- you must first create a storage account, then you transfer data to/from a specific service in that storage account.

## Chef Habitat:

**Chef Habitat** is a new open source project that allows developers to package their applications and run them on a wide variety of infrastructures.

Habitat essentially wraps applications into their own lightweight runtime environments and then allows you to run them in any environment, including bare metal servers, virtual machines, Docker containers (and their respective container management services), and PaaS systems like Cloud Foundry.

  ### Why Habitat?

Habitat is a modern technology to build, deploy, and manage applications in any environment from traditional datacenters to containerized microservices.

This is because in Habitat, the application is the unit of automation.  This means the application package contains everything needed to deploy, run, and maintain the application.

  ### Packaging an Application with Habitat:

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/3.png)  

  ### Habitat Components:

**Habitat Supervisor:**

Habitat Supervisor is what runs the application artifact. The Supervisor is what allows you to run the artifact natively on hardware, in a virtual machine, or in a container (in the case of a container, you can also run it through a container orchestration service like Kubernetes, Mesosphere, or Docker Swarm).

**Service Group:**

A service group is a logical grouping of services with the same package and topology type connected in a ring. They are created to share configuration and file updates among the services within those groups and can be segmented based on workflow or deployment needs (QA, Production, and so on).

  ### Habitat Packaging Format:

Habitat packages are in a format called the HART format, which stands for Habitat Artifact.

These HART packages contain the compiled application itself – if, for example, you had a Java application you were automating, you would have the compiled Java application within this package. Along with the application, these packages also include everything needed to deploy and run the application, all in one place.

  ### Habitat Highlights:

Habitat is a first of its kind open source project that offers an entirely new approach to application management. Habitat makes the application and its automation the unit of deployment. When applications are wrapped in a lightweight &quot;habitat,&quot; the runtime environment, whether it is a container, bare metal, or PaaS, is no longer the focus and does not constrain the application. Features of Habitat include:

- Support for the Modern Applications
- Run Any Application, Anywhere
- Easily Port Legacy Applications
- Improve the Container Experience
- Integrate into Chef&#39;s DevOps Workflow

## Prerequisites:

1. Generate your SSH key
2. Create service principal

  ### Generate your SSH key:

Follow the below link to generate SSH public and private keys.

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#create-an-ssh-key-pair

 ### Create Service principal

To deploy the ARM template, you need to create a service principal to deploy the Terraform code which is configured as an ELK job in Jenkins.

You can create a service principal within the Azure Portal via  [Azure Cloud Shell](https://azure.microsoft.com/en-us/features/cloud-shell/). The AD identity running this installation should have the  **Owner**  role on the required Subscription.

1. Follow the below link to create Service principal. (Create a service principal with a password)

https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest#create-a-service-principal-for-your-application 

2. Note the values for  **appId** and **password(ClientSecret)** for the parameters section.

## Deploy the ARM Template:

1. Click on **Deploy to azure** button at the top of the documentation.

2. Enter the details for **Admin username,Azure Username, Azure Password,Admin password(for ELK and VMSS VM's) SSH Public key (Generated in prerequisites section),Kibana Username, kibana password then provide Application Id, Client Secret (Password) which is Created in prerequisites section, Kubernetes cluster name, Agent count, master count, leave atifactsLocationSasToken as an empty** in Custom Deployment and click on **Purchase**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/11.png)

3. The below screen shot shows that the template has been successfully deployed.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/12.png)

4. We can view the output section as shown below.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/13.png)

## Environment Details:

The ARM template will deploy the following resources on Azure:

| S.NO | Nodes                | Installed application            | No of nodes          |Node Purpose                                                                                                       | Ports
| ---- |-------------         | --------------------             | ------------         |-------------                                                                                                      | -----
| 1    |Jenkins server        | Jekins                           | 1                    |Install and configure plugins and jobs                                                                             | 8080   
| 2    |Build Instance        | Chef Habitat                     | 1                    |Creating habitat packages  
| 3    |ELK Stack             | Elasticsearch, Kibana, Filebeat  | 1                    |Elasticsearch:Contains Index data, Kibana:Segregate logs to visualize as graphs, Filebeat:Forwarding logs to Kibana| 80
| 4    |Load Balancer         | -                                | 1                    |Directs traffic to Application Nodes                                                                                  |
| 5    |Azure Storage Account | packer,jenkins,ELK               | 3                    |Packer:To store the Packer VHD’s |
| 6    |Kubernetes | -             | 1 master, 3 agents                    |To Deploy applications in pods |
| 7    |Azure Container Registry | -             | 1                  |To store Docker images |

## Solution Workflow:

After the template has been successfully deployed, login in to the Jenkins server with its Fully Qualified Domain Name (FQDN).

1. Open PuTTY and enter the Jenkins FQDN under **Session**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/14.png)

2. Navigate to **Connection &gt; SSH &gt; Auth**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/15.png)

3. Click on the **Browse** section, select SSH private key file which was generated earlier as part of the prerequisites section.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/16.png)

4. Enter the same username, which was provided while deploying the ARM template.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/17.png)

5. Change to the root user by using the below command:

	``sudo -i``

6. Change the directory to **cd /var/lib/jenkins/secrets** and run the below command to get the initial admin password.

	``cat initialAdminPassword``

7. Make a note of this value (Password), this credential will be used to login into the Jenkins WEBUI. (as part of step 9)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/18.png)

8. Open a new browser and enter the Jenkins FQDN with extension 8080, as shown below:

	`Eg:` &lt;`jenkinsFQDN`&gt;`:8080`

9. To unlock the Jenkins server, provide the Initialadminpassword which was retrieved as part of step 7.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/19.png)

10. Click on **Install suggested plugins**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/20.png)

11. Click on **Continue as admin**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/21.png)

12. Click on **Start using Jenkins**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/22.png)

13. We can see the jobs which are created in Jenkins server.

 ### Jobs

 1. The following are the jobs that are created in Jenkins.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/23.png)

 2. For the above jobs, we have installed the Kubernetes Continuous Deploy plugins.

  ### Executing the Jobs
**ELKJob**

In ELKJob, we have configured terraform to deploy ELK stack on Azure. This will bring up one node, configured with Elasticsearch, Logstash and Kibana.

       
**KubernetesClusterjob**

In Kubernetes Cluster job, it configures to deploy Kubernetes cluster on Azure, this will bring up one master and three nodes. This job also deploys Azure Container registry.

**VMSSjob**

This job will launch a Virtual Machine Scale set with three application nodes.

1. Move to the Jenkins Dashboard and click on **ELKJob**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/24.png)

2. Click on **Build Now**. Then, to view the Console output, click on **Build number** (Eg: **#1** ) as shown below.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/25.png)

3. Click on **Console Output.**

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/26.png)

4. The console output log will be shown as below. If the build is successful, the output will reflect as &quot;Success&quot;.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/27.png)

5. Once the ELKJob is successfully executed, move to the Jenkins Dashboard and click on **KuberentesClusterjob**.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/28.png)

6. Click on **Build Now**. Then, to view the Console output, click on **Build number** (Eg: **#1** ) as shown below.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/29.png)

7. Click on **Console Output.**

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/30.png)

8. The console output log will be shown as below. If the build is successful, the output will reflect as &quot;Success&quot;.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/31.png)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/32.png)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/33.png)

## Chef Habitat:

  ### Configuring Habitat:

To build the National Park application, begin by logging in to the Build Instance using Fully Qualified Domain Name (FQDN) from the output section of the ARM template. (As shown in the solution workflow step at page 22)

1. Switch to the root user using `sudo -i`
2. Chef Habitat can be configured using the below command.

	``hab setup``

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/34.png)

3. Enter &quot; **yes**&quot; for setting up the default origin
4. Enter origin name as &quot; **root&quot;**
5. Enter &quot; **yes**&quot; to generate the origin key
6. Enter &quot; **no**&quot; to setup the github access token
7. Enter &quot; **yes**&quot; to Enable analytics

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/35.png)

  ### Creating Hart File:

1. Clone the repository from URL **https://github.com/sysgain/MSOSS.git,** from the branch **habcode** using below commands.

	`git clone` [https://github.com/sysgain/MSOSS.git](https://github.com/sysgain/MSOSS.git)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/36.png)

2. Enter the below commands.

	`cd MSOSS`

	`git checkout habcode`

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/37.png)

3. Navigate to the location of the Directory where package plan.sh file is located.

	`cd national-parks-plan-kubernetes`

4. Enter `hab studio enter`

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/38.png)

5. Build the Application, using the `Build` Command.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/39.png)

6. Then exit the hab studio, by entering the `exit` command.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/40.png)

7. Once **build** is successful, a **HART** file will be generated in results Directory.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/41.png)

### Get Azure Container Registry Password from Azure portal

1. Login to Azure Portal   [https://portal.azure.com/](https://portal.azure.com/) .On the home page on left side menu click on more services and search for container registries

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/42.png)

2. Click on **Available azure container registries** **resource** and click on  **Access Keys**

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/43.png)

3. Be handy with username, password 1 and password 2 for further deployments

### Uploading MongoDB HART file to Azure Container Registry:

1. Change directory to /scripts by using below command

	`cd /scripts/`

2. Execute mongodb\_acrimage.sh command using below command

	`sh` `mongodb`\_`acrimage.sh` &lt;`username`&gt;&lt;`password1`&gt;

**NOTE:** password 1 value is copied from previous step. Password 1 value should be one of the password 1 and password 2 but not both.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/44.png)

  ### Uploading National parks HART File to the Azure Container Registry:

1. Change directory to /scripts by using below command.

	`cd /scripts`

2. Execute np\_acrimage.sh command using below command

	`sh` `np`\_`acrimage.sh` &lt;`username`&gt; &lt;`password1`&gt;

**NOTE:** password 1 value is copied from previous step. Password 1 value should be one of the password 1 and password 2 but not both.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/45.png)

##  Verify Docker Images in Azure Container Registry:

1. Login to Azure Portal   [https://portal.azure.com/](https://portal.azure.com/) .On the home page on left side menu click on more services and search for container registries

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/46.png)

2. Click on **Available azure container registries** **resource** and click on **Repositories**

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/47.png)

## Change the Azure container registry Username and Password

1. Move to the Jenkins Dashboard and Click on **Credentials** from left side menu.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/52.png)

2. Click on **ossAcr/******(acrReglogin)**

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/48.png)

3. Click on Update from left side menu

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/49.png)

4. Change the Username and Password which got from Azure Container Registry Services of Azure portal and save the changes.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/50.png)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/51.png)

  ## Run VMSS Job:

1. Move to the Jenkins Dashboard and click on VMSS Job.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/52.png)

2. Click on **Build Now**. Then, to view the Console output, click on **Build number** (Eg: **#1** ) as shown below.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/53.png)

3. Click on **Console Output.**

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/54.png)

4. The console output log will be shown as below. If the build is successful, the output will reflect as &quot;Success&quot;.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/55.png)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/56.png)

## Verify Kubernetes Pods and Services:

1. Get the DNS of Jenkins server and Kubernetes master Instances from Azure portal

2. Login to Jenkins using private key and execute below command to connect to Kubernetes master instance.

	`ssh -i /var/lib/jenkins/.ssh/id\_rsa` &lt;`username of kubernetes vm`&gt;`@`&lt;`Kubernetes master Instance dns name`&gt;

3. Change to the root user by using the below command:

	`sudo -i`

4.  Verify Kubernetes pods using below command

	`Kubectl get pods`

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/57.png)

5. Verify kubernetes service using below command

	`Kubectl get svc`

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/58.png)

## Access National Park Applications

1. Get the External IP of web service in the above picture and access national parks applications in browser as below

	`http://`&lt;`external-ip`&gt;`:8080/national-parks`

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/59.png)

## Verifying Application Logs:

1. Get pod details by running command below command

	`Kubectl get pods`

  ![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/60.png)

2. Get Logs of each pod by using below command. Replace podname with exact pod name one at a time.

	`Kubectl logs` &lt;`podname`&gt;

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/61.png)

## Visualizing logs in Kibana Dashboard

1. Use the **FQDN** of **ELKJob** output from the Jenkins to log into **Kibana DashBoard** and credentials from output section of ARM template from Azure portal.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/62.PNG)

2. After log into Kibana Dashboard, Click on **&quot;filebeat&quot;** from left side menu and Click on star icon.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/63.PNG)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/64.PNG)

3. Click on **&quot;Discover&quot;** from top menu to view the logs.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/65.png)

4. By default last 15 min logs will be displayed, you can change it as per log search and also you can set auto refresh time as shown below.

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/66.PNG)

![alt text](/devopstools-jenkins-chefhabitat-kubernetes/images/67.PNG)


