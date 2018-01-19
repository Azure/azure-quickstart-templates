
# Microsoft

# OSS Quickstart (Phase-1)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdevopstools-jenkins-chefhabitat-terraform%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdevopstools-jenkins-chefhabitat-terraform%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

**Table of Contents**  

- [Solution Architecture:](#solution-architecture)
- [Terraform:](#terraform)
- [Packer:](#packer)
	- [Why Packer?](#why-packer)
- [ELK Stack:](#elk-stack)
	- [Elasticsearch](#elasticsearch)
	- [Logstash—Routing Your Log Data](#logstashrouting-your-log-data)
	- [Kibana—Visualizing Your Log Data](#kibanavisualizing-your-log-data)
	- [Beats—Lightweight Data Shippers](#beatslightweight-data-shippers)
	- [The following logs are visualized in Kibana:](#the-following-logs-are-visualized-in-kibana)
- [Jenkins:](#jenkins)
	- [Plugins:](#plugins)
	- [Terraform plugin](#terraform-plugin)
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
	- [MongoDBPackerJob](#mongodbpackerjob)
	- [MongoDBTerraformJob](#mongodbterraformjob)
	- [AppPackerJob:](#apppackerjob)
	- [VMSSjob](#vmssjob)
- [Verifying Mongodb:](#verifying-mongodb)
- [Chef Habitat:](#chef-habitat)
	- [Configuring Habitat:](#configuring-habitat)
	- [Creating Hart File:](#creating-hart-file)
	- [Uploading HART file to the Storage account](#uploading-hart-file-to-the-storage-account)

## Solution Architecture:

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/1.png)

This solution will deploy the following architecture:

1. Virtual Network with four subnets:

- Subnet1 – Jenkins server, Build instance with Chef Habitat
- Subnet2 – VM scale set
- Subnet3 – Elastic Stack
- Subnet4 – MongoDB

1. Azure Load Balancer
2. Azure Storage Account
3. GitHub- The Terraform code is taken from GitHub and has been configured as a job in Jenkins.

## Terraform:

**Terraform** is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing popular service providers as well as custom in-house solutions.

Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure.

Terraform&#39;s manageable infrastructure includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

## Packer:

**Packer** is an open source tool for creating identical machine images for multiple platforms from a single source configuration. It is easy to use and automates the process of creating server images. It supports multiple provisioners, all built into Packer.

### Why Packer?

- Supports multiple platforms such as Azure, VMware, VirtualBox, and other cloud vendors.
- Easy to use and mostly automated.
- Supports Ansible as a provisioner.

## ELK Stack:

**Elastic** is the company behind Elastic stack, which is a suite of products including **E** lasticsearch, **L** ogstash and **K** ibana.  The ELK stack makes it easier and faster to search and analyze large data sets. Logstash is used to normalize the data, Elasticsearch processes, and then Kibana visualizes it.

### Elasticsearch

Elasticsearch is an open-source, broadly-distributable, readily-scalable, enterprise-grade search engine. Elasticsearch can power extremely fast searches that support your data discovery applications **.** Consider these benefits:

- **Real-time data and real-time analytics:** The ELK stack gives you the power of real-time data insights, with the ability to perform super-fast data extractions from virtually all structured or unstructured data sources. With real-time extraction and real-time analytics, Elasticsearch is the engine that gives you both power and speed.
- **Scalable, high-availability, multi-tenant:**   It is built to scale horizontally out of the box. As you need more capacity, simply add another node and let the cluster reorganize itself to accommodate and exploit the extra hardware. Elasticsearch clusters are resilient since they automatically detect and remove node failures. You can set up multiple indices and query each of them independently or in combination.
- **Full text search: ** Elasticsearch uses Lucene to provide the most powerful full-text search capabilities available in any open-source product. The search features come with multi-language support, an extensive query language, geolocation support, context-sensitive suggestions, and autocompletion.
- **Document orientation:**  You can store complex, real-world entities in Elasticsearch as structured JSON documents. All fields have a default index, and you can use all the indices in a single query to get precise results in the blink of an eye.

### Logstash—Routing Your Log Data

**Logstash** is a tool for log data intake, processing, and output. This includes virtually any type of log that you manage: system logs, webserver logs, error logs, and app logs.  You can save a lot of time by training Logstash to normalize the data, getting Elasticsearch to process the data, and then visualizing it with Kibana. With Logstash, it&#39;s easy to take all those logs and store them in a central location. The only prerequisite is a Java runtime, and it takes just two commands to get Logstash up and running. Logstash will serve as the workhorse for storage, querying, and analysis of your logs. Since it has an arsenal of ready-made inputs, filters, codecs, and outputs, you can grab hold of a very powerful feature-set with a very little effort on your part. Think of Logstash as a pipeline for event processing: it takes precious little time to choose the inputs, configure the filters, and extract the relevant, high-value data from your log.

### Kibana—Visualizing Your Log Data

**Kibana ** is your log-data dashboard. Get a better grip on your large data stores with point-and-click pie charts, bar graphs, trendlines, maps, and scatter plots. You can visualize trends and patterns for data that would otherwise be extremely tedious to read and interpret. Eventually, each business line can make practical use of your data collection as you help them customize their dashboards. Save it, share it, and link your data visualizations for quick and smart communication.

### Beats—Lightweight Data Shippers

**Beats** is the platform for single-purpose data shippers. They install as lightweight agents and send data from hundreds or thousands of machines to Logstash or Elasticsearch. ELK allows Filebeat, Packetbeat, Metricbeat and Winlogbeat to ship log data from client servers.

**Filebeat** : For Text log files.        
**Metricbeat** : For OS and application.
**Packetbeat** : For Network monitoring. 
**Winlogbeat** : For windows event logs.

**Flow Diagram:**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/2.png)

### The following logs are visualized in Kibana:

| S.NO | Nodes            | Logs Path|
| ---- |-------------     | -------- |
| 1    | Application Node | /hab/svc/national-parks/logs/, /hab/pkgs/core/tomcat8/8.5.9/20170514144202/tc/logs/, /root/sup-national-parks.log|
| 2    | mongoDB          | /hab/svc/mongodb/logs, /hab/svc/mongodb/var/mongod.log, /root/sup.mongodb.log|


## Jenkins:

**Jenkins**  is an open-source, continuous integration software tool written in the Java programming language for testing and reporting on isolated changes in a larger code base in real time. This software enables developers to find and solve defects in a code base rapidly and automate testing of their builds. There are also hundreds of **plugins**  available to enhance its power and usability.

### Plugins:

The concept of plugins makes Jenkins attractive, easy to learn, and easy to use. Jenkins has many plugins available for free. These plugins help to integrate with various software tools for better convenience.

In this solution, we are using the Packer and Terraform plugins.

### Terraform plugin

Terraform works as a &quot;build wrapper&quot; and can be invoked by selecting Terraform under the Build Environment section of your job configuration.

Here, we are using Terraform plugin to deploy and configure ELK, MongoDB, and App nodes which are configured as a job in Jenkins.

This plugin provides an auto-installer to install the Terraform binary from  [bintray.com](http://bintray.com/).

### Packer plugin:

This plugin allows for a job to publish an image generated from [Packer](http://packer.io/).

At this level, this plugin can either use a global system-wide template for the chosen installation or packer template as text for a file.  As they are available at the system level,  [variables](http://www.packer.io/docs/templates/user-variables.html) and temporary files can be configured and referenced in the template.

The plugin will automatically install the desired version of Packer on the node.

### Jenkins Pipeline

Jenkins Pipeline is a suite of plugins which supports implementing and integrating _continuous delivery pipelines_ into Jenkins.

A _continuous delivery pipeline_ is an automated expression of your process for getting software from version control through to users and customers. Every change to your software (committed in source control) goes through a complex process on its way to being released. This process involves building the software in a reliable and repeatable manner, as well as the progression of the built software (called a &quot;build&quot;) through multiple stages of testing and deployment. The Jenkins Pipeline automates large chunks of this process, making it easier to get vital changes to your users in a timely manner.

## Azure Storage Account:

**Microsoft Azure Storage** is a Microsoft-managed cloud service that provides storage that is highly available, secure, durable, scalable, and redundant. Microsoft takes care of maintenance and handles critical problems for you.

Azure Storage consists of three data services: Blob storage, File storage, and Queue storage. Blob storage supports both standard and premium storage, with premium storage using only SSDs for the fastest performance possible.

Another feature is cool storage, allowing you to store large amounts of rarely accessed data for a lower cost. Azure Queue storage is a service for storing large numbers of messages that can be accessed from anywhere in the world via authenticated calls using HTTP or HTTPS.

To use any of the services provided by Azure Storage -- Blob storage, File storage, and Queue storage -- you must first create a storage account, then you transfer data to/from a specific service in that storage account.

Here we are using an Azure Storage Account to store Packer image.

## Chef Habitat:

**Chef Habitat** is a new open source project that allows developers to package their applications and run them on a wide variety of infrastructures.

Habitat essentially wraps applications into their own lightweight runtime environments and then allows you to run them in any environment, including bare metal servers, virtual machines, Docker containers (and their respective container management services), and PaaS systems like Cloud Foundry.

### Why Habitat?

Habitat is a modern technology to build, deploy, and manage applications in any environment from traditional datacenters to containerized microservices.

This is because in Habitat, the application is the unit of automation.  This means the application package contains everything needed to deploy, run, and maintain the application.

### Packaging an Application with Habitat:

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/3.png)

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

PuTTYgen is a key generator tool for creating SSH keys for PuTTY

1. PuTTYgen is normally installed as part of the normal PuTTY .msi package installation. There is no need for a separate PuTTYgen download. Download PuTTY from the  [**PuTTY download page**](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)

2. Go to Windows  **Start menu**  →  **All Programs**  →  **PuTTY** →  **PuTTYgen** to generate an SSH key.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/4.png)

3. Click  **Generate** , and start moving the mouse within the window. Putty uses mouse movements to collect randomness. You may need to move the mouse for some time, depending on the size of your key. As you move it, the green progress bar should advance.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/5.png)

4. Once the progress bar becomes full, the actual key generation computation takes place. When complete, the public key should appear in the Window.

5. Copy the Public Key in a notepad. This will be used while deploying the ARM Template.

6. You should save at the private key by clicking  **Save private key** , this private key will be used to log in to the Jenkins server.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/6.png)

### Create Service principal

To deploy the ARM template, you need to create a service principal to deploy the Terraform code which is configured as an ELK job in Jenkins.

You can create a service principal within the Azure Portal via Azure Cloud Shell. The AD identity running this installation should have the  **Owner**  role on the required Subscription.

1. We need to create a Service Principal to pass in to the template properties. If you do not have an existing Service Principal, you can create one using the  **following**  command:

    **az ad sp create-for-rbac**

You will receive the following output:

        Retrying role assignment creation: 1/36_

            {

              appId:ABCDEFGH-YOUR-GUID-HERE-IJKLMNOP

              displayName: azure-cli-2017-05-23-15-28-34

              name: http://azure-cli-2017-05-23-15-28-34

              password:an autogenerated password will appear here

              tenant:ABCDEFGH-YOUR-GUID-HERE-IJKLMNOP

            }

2. Note the values for  **appId** , **password(ClientSecret)** for the parameters section.


## Deploy the ARM Template:

1. Take the main-template from the provided GitHub URL.

2. Log in to your Azure portal using your credentials

3. Click on **New (+)** and search for **Template deployment** , then click on it.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/7.png)

4. Click on **Create.**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/8.png)

5. Click on **Build your own template in the editor**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/9.png)

6. Clear the default template section, paste the template from the GitHub and click on **Save**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/10.png)

7. Enter the detailsfor **Admin username, SSH Public key (Generated in prerequisites section),adminPassword (for ELK,VMSS and MongoDBTerrafrom VM's), KibanaUsername, KibanaPassword ( the password should have alphanumeric values only)then provide Application Id, Client Secret (Password) which are generated in prerequisites section and _artifactsLocation , leave _artifactsLocationSasToken parameter as an empty** in Custom Deployment and click on **Purchase**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/11.png)

8. The below screen shot shows that the template has been successfully deployed.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/12.png)

9. We can view the output section as shown below.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/13.png)

## Environment Details:

The ARM template will deploy the following resources on Azure:

| S.NO | Nodes                | Installed application            | No of nodes          |Node Purpose                                                                                                       | Ports
| ---- |-------------         | --------------------             | ------------         |-------------                                                                                                      | -----
| 1    |Jenkins server        | jenkins                           | 1                    |Install and configure plugins and jobs                                                                             | 8080   
| 2    |Build Instance        | Chef Habitat                     | 1                    |Creating habitat packages                                                                                          | 9631,9638
| 3    |Application Node      |  Mongo DB   | 1                    |To run National Park application                                                                                   | 8080,9631,9638,27017
| 4    |VM ScaleSets          | Web Application (National Parks)               | 3                    |To run mongo DB                                                                                                    | 9631,9638,27017
| 5    |ELK Stack             | Elasticsearch, Kibana, Filebeat  | 1                    |Elasticsearch:Contains Index data, Kibana:Segregate logs to visualize as graphs, Filebeat:Forwarding logs to Kibana| 80
| 6    |Load Balancer         | -                                | 1                    |Directs traffic to Application Nodes                                                                                  |
| 7    |Azure Storage Account | packer,jenkins,ELK               | 3                    |Packer:To store the Packer VHD’s |


## Solution Workflow:

After the template has been successfully deployed, log in to the Jenkins server with its Fully Qualified Domain Name (FQDN) provided in the output section, along with the private SSH key and username.

1. Open PuTTY and enter the Jenkins FQDN under **Session**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/14.png)

2. Navigate to **Connection &gt; SSH &gt; Auth**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/15.png)

3. Click on the **Browse** section, select SSH private key file which was generated earlier as part of the prerequisites section.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/16.png)

4. Enter the same username, which was provided while deploying the ARM template.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/17.png)

5. Change to the root user by using the below command:

    **sudo -i**

6. Change the directory to **cd /var/lib/jenkins/secrets** and run the below command to get the initial admin password.

    **cat initialAdminPassword**

7. Make a note of this value (Password), this credential will be used to login into the Jenkins WEBUI. (as part of step 9)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/18.png)

8. Open a new browser and enter the Jenkins FQDN with extension 8080, as shown below:

    **Eg : jenkinsFQDN:8080**

9. To unlock the Jenkins server, provide the Initialadminpassword which was retrieved as part of step 7.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/19.png)

10. Click on **Install suggested plugins**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/20.png)

11. Click on **Continue as admin**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/21.png)

12. Click on **Start using Jenkins**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/22.png)

13. We can see the jobs which are created in Jenkins server.

### Jobs

1. The following are the jobs that are created in Jenkins.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/23.png)

2. For the above jobs, we have installed the Terraform and Packer plugins.

### Executing the Jobs
### ELKJob

In ELKJob, we have configured terraform to deploy ELK stack on Azure. This will bring up one node, configured with Elasticsearch, Logstash and Kibana.

### MongoDBPackerJob

This job will create the images of MongoDB and application services. The MongoDBPackerjob will be triggered when the upstream job (ELKJob) is successfully executed.

### MongoDBTerraformJob

This job will deploy the MongoDB instance on Azure environment using Terraform plugin.

To accomplish this, image URL:  is to be updated as a mandate, which will be available from the previous job.

### AppPackerJob:

This job will create the image for VM ScaleSet, which contains Chef Habitat application.

### VMSSjob

This job will launch a Virtual machine Scale set with three application nodes.

1. Move to the Jenkins Dashboard and click on **ELKJob**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/24.png)

2.  Click on **Build Now**. Then, to view the Console output, click on **Build number** (Eg: **#1** ) as shown below.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/25.png)

3.  Click on **Console Output.**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/26.png)

4.  The console output log will be shown as below. If the build is successful, the output will reflect as **Success**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/27.png)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/28.png)

5.  Once the ELKJob is successfully executed, then the MongoDBPackerJob will automatically start.

6.  Click **MongoDBPackerJob** to view the job execution.


7.  Click on **Build number** (Eg: **#1** ) as shown below.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/29.png)

8.  Click **Console Output** to see the job status.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/30.png)

9.  If output section of this log reflects as **&quot;Success&quot;** , then the Packer VHD is created successfully and stored in the packer storage account.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/31.png)

10.  Once the **MongoDBPackerJob** is successfully executed, copy the Packer VHD URL (as highlighted in the image below) from the console output and paste it in the **MongoDBTerraformJob** under the parameters section.
 Then execute the **MongoDBTerraformJob.**

 ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/32.png)

11. Go to **MongoDBTerraformJob** , click on the **Configure** tab.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/33.png)

12. Scroll down to the **Terraform** section and update **Resource variable** section as follow:
    Update the **imageURL** variable value with VHD URL, which is created from **MongoDBpackerJob** as shown below:

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/34.png)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/35.png)

13. Click on **Apply and Save**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/36.png)

14. Click on **Build Now** , then click on **Build number** **(#1).**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/37.png)

15. Click on **Console Output**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/38.png)

16. The console output log is shown as below. If the build is successful, the output will reflect as **&quot;Success&quot;**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/39.png)
       
## Verifying Mongodb:

1. Log in to the build instance and SSH the highlighted VM created from **MongoDBTerraformjob.** Login credentials can be found from theutput section of the previously shown **MongoDBTerraformjob**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/40.png)

2. Execute the below command to find the MongoDB path:

    **sudo -i**

    **find / -iname mongod**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/41.png)

3. Change the directory to MongoDB path and execute the command as shown below: (Please fill the Date &amp; Time as appropriate)

    **cd /hab/pkgs/root/mongodb/3.2.9/&lt;YYYYMMDDT&gt;**

    **./bin/mongo**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/42.png)

4. Enter the below command to validate the success of MongoDB configuration. Below screenshot depicts the local database creation:

    **db.adminCommand( { listDatabases: 1 } )**

    ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/43.png)

5. Enter the &quot; **exit**&quot; command to log out of MongoDB.
6. Enter **exit** again.

## Chef Habitat:

### Configuring Habitat:

To build the National Park application, begin by logging in to the Build Instance using Fully Qualified Domain Name (FQDN) from the output section of the ARM template. (As shown in the solution workflow step at page 22)

1. Switch to the root user using **sudo -i**

2. Chef Habitat can be configured using the command **hab setup**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/44.png)

3. Enter &quot; **yes**&quot; for setting up the default origin

4. Enter origin name as &quot; **root&quot;**

5. Enter &quot; **yes**&quot; to generate the origin key

6. Enter &quot; **no**&quot; to setup the github access token

7. Enter &quot; **yes**&quot; to Enable analytics

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/45.png)

### Creating Hart File:

1. Clone the repository from URL **https://github.com/sysgain/MSOSS.git,** from the branch **habcode** using below commands.

    **git clone** [https://github.com/sysgain/MSOSS.git](https://github.com/sysgain/MSOSS.git)

    ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/46.png)

    **cd MSOSS**

    **git checkout habcode**

    ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/47.png)

2. Navigate to the location of the Directory where package plan.sh file is located.

    **cd national-parks-plan**

3. Enter **hab studio enter**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/48.png)

4. Build the Application, using the &quot; **Build**&quot; Command.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/49.png)

5. Then exit the hab studio, by entering the **exit** command.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/50.png)

6. Once **build** is successful, a **HART** file will be generated in results Directory.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/51.png)

### Uploading HART file to the Storage account

1. Create a directory in root using the below command.

    **cd /**

    **mkdir /nationalparks**

2. Copy the **HART file** and **public key** to the created folder.

    **cp /root/MSOSS/national-parks-plan/results/root-national-parks-&lt;VERSION-DATETIME&gt;-x86\_64-linux.hart /nationalparks/**

    **cp /hab/cache/keys/root-&lt;DATETIME&gt;.pub /nationalparks/**

    ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/52.png)

3. ** Zip** the folder using the below commands.

    **cd /**

    **tar cvzf nationalparks.tar.gz /nationalparks/**

    ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/53.png)

4. Run the **uploadhart.sh** file from the scripts folder, to upload **ZIP** file to the Azure Storage Account.

    **Note** : The user must input the HART file

    **sh /scripts/uploadhart.sh nationalparks.tar.gz**

    ![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/54.png)

5. Go to **AppPackerJob** , click on **Configure** and Update the highlighted file name (as shown in the above image) to the variable of **AppPackerjob** under the parameter section of Packer in Jenkins.

Click **Apply** and **Save.**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/55.png)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/56.png)

6. Click on **Build**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/57.png)

7. Once the jobs are built, click on Console Output.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/58.png)

8. The console output log is as follows. If the build is successful, the output will reflect as **&quot;Success&quot;**. Copy the highlighted VHD URL which will be used in **vmssjob** as part of the successive steps.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/59.png)

9. Go to **VMSSjob** , then click on **Configure.**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/60.png)

10. Scroll down to the **Terraform** section, update the **Resource variables** section with the VHD URL created from **AppPackerjob** under Console Output. Once done, click on **Apply** and **Save**

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/61.png)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/62.png)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/63.png)

11. Click on **Build**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/64.png)

12. Click on **build number (#1)** and click on **Console Output**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/65.png)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/66.png)

13. The console output log is as follows. If the build is successful, the output will reflect as **&quot;Success&quot;**. Copy the highlighted Application\_URL.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/67.png)

14. In a new browser tab, paste **&lt;Application\_URL &gt;:8080/national-parks**.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/68.png)

15. Use the **FQDN** of **ELKJob** output from the Jenkins to log into **Kibana DashBoard** and credentials from output section of ARM template from Azure portal.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/69.PNG)

16. After log into Kibana Dashboard, Click on **&quot;filebeat&quot;** from left side menu and Click on star icon.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/70.PNG)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/71.PNG)

17. Click on **&quot;Discover&quot;** from top menu to view the vmss and mongoDB logs.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/72.PNG)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/73.PNG)

18. By default last 15 min logs will be displayed, you can change it as per log search and also you can set auto refresh time as shown below.

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/74.PNG)

![alt text](https://github.com/sysgain/azure-quickstart-templates/raw/msoss-p1/devopstools-jenkins-chefhabitat-terraform/images/75.PNG)