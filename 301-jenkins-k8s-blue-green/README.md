# Jenkins Blue-Green Deployment on Kubernetes

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FArieShout%2Fazure-quickstart-templates%2Fblue-green%2F301-jenkins-k8s-blue-green%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FArieShout%2Fazure-quickstart-templates%2Fblue-green%2F301-jenkins-k8s-blue-green%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy and configure a DevOps pipeline from public Tomcat Docker images to 
an Azure Container Service with Kubernetes orchestrator. It deploys an instance of Jenkins on a Linux
Ubuntu 16.04 LTS VM and a Kubernetes based ACS cluster that the pipeline will deploy to. It is an example
to demonstrate how we can use Jenkins pipeline to do blue-green deployment on ACS Kubernetes.

The Jenkins instance will be configured with the following items:

* An Azure Service Principal credential which can be used to manage the Azure resources
* An SSH credential with username and private key, which can be used to authenticate with the Kubernetes
   master host.
* A basic pipeline that demonstrates the steps to do blue-green deployment on Kubernetes:
   1. Prepare two similar environments, blue and green.
      
      ***Note***: in real world projects, this is likely to be done outside of the continous integration
      pipeline. We included this in the pipeline to make the quickstart configurations easier to manage.
   2. Deploy new applications to one of the environment, say, "Green".
   3. Verify that the Green environment is working as expected through the test endpoint.
   4. Update the application public endpoint to route the traffic to "Green" environment.
   5. Verify that the public endpoint is working properly with the "Green" environment serving as backend.

## How To Try It Out

### Prerequisites

* An Azure subscription.
* An Azure Service Principal to manage the related Azure resources.
* An SSH key pair that will be used to login remotely to the Jenkins master VM and the ACS master node.

### Steps

1. Click the **Deploy to Azure** button from above, this will leads you to the ARM provision page.
1. Fill in the parameters, agree to the terms & conditions and click **Purchase**. It takes about 20 minutes
   for the provision process to complete
1. Check in the resource group, find the latest deployment with the name `Microsoft.Template`, the following
   details will be displayed in the `Outputs` section:
   * `ADMINUSERNAME`: The Admin username for the Jenkins master VM and the ACS master VM, which is the one
      you filled in the provision page
   * `DEVOPSVMFQDN`: The host name of the Jenkins master VM
   * `JENKINSURL`: The Jenkins URL
   * `SSH`: The SSH command to create a tunnel through which you can login and manage the Jenkins instance
      securely
   * `KUBERNETESMASTERFQDN`: The host name of the ACS Kubernetes master node
   * `KUBERNETESMASTERSSH`: The SSH command to login to the ACS Kubernetes master node
1. Run the command listed in the `SSH` box. Check the Jenkins admin password by running the following command
   in the SSH session:

   ```sh
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

1. Visit `http://localhost:8080`, login with the admin password
1. Follow the instructions to setup the Jenkins instance
1. You should be able to see the job `ACS Kubernetes Blue-green Deployment`
1. Start the build. The build process may take several minutes for the first time, as the backend Kubernetes
   needs to provision the Azure load balancer for the test and public endpoints for the services.
1. Run the build more times, it will cycle between BLUE and GREEN deployment.