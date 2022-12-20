---
description: Containers make it very easy for you to continuously build and deploy your applications. By orchestrating deployment of those containers using Kubernetes in Azure Container Service, you can achieve replicable, manageable clusters of containers. By setting up a continuous build to produce your container images and orchestration, you can increase the speed and reliability of your deployment.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: jenkins-cicd-container
languages:
- json
---
# CI/CD using Jenkins on Azure Container Service (AKS)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-container/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-container/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-container/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-container/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-container/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-container/CredScanResult.svg)

## Architecture overview

Containers make it very easy for you to continuously build and deploy your applications. By orchestrating deployment of those containers using Kubernetes in Azure Container Service, you can achieve replicable, manageable clusters of containers.

By setting up a continuous build to produce your container images and orchestration, you can increase the speed and reliability of your deployment.

![](images/architecture.png)

1. Change application source code.
2. Commit code to GitHub.
3. Continuous Integration Trigger to Jenkins.
4. Jenkins triggers a build job using Azure Container Service (AKS) for a dynamic build agent.
5. Jenkins builds and pushes Docker container Azure Container Registry.
6. Jenkins deploys new containerized app to Kubernetes on Azure Container Service (AKS) backed by Azure Cosmos DB.
7. Grafana displays visualization of infrastructure and application metrics via Azure Monitor.
8. Monitor application and make improvements.

## Deploy to Azure

### Create an Azure service principal

1. Install [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest) if you have not.

   > Note: Alternatively, you can also use Azure Cloud Shell from the Azure Portal.

2. Open terminal, then execute:

   ```sh
   az login
   ```

   Follow the guide to sign in.

   > Note: If you use Azure Cloud Shell from the Azure Portal, you are automatically authenticated. Therefore there is no need to ``az login`` again.

3. Execute the command below to create service principal, with the role ``Contributor`` and under the current subscription by default.

   ```sh
   az ad sp create-for-rbac --name <AppName> --role Contributor
   ```

   > Note: please replate the \<AppName> placeholder.

4. You will get a response like below.

   ```json
   {
      "appId": "8e897eb4-069d-40c2-9563-000000003c14",
      "displayName": "<AppName>",
      "password": "xxxxxvJgeKZoRAfxxxx0SitnANH8Kxxxx",
      "tenant": "000088bf-0000-0000-0000-2d7cd0100000"
   }
   ```

   Copy the values **appId** and **password**, they will be used later.

   > Note: for more details about creating an Azure service principal, please refer to [Create an Azure service principal with Azure CLI 2.0](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)

### Create a SSH Key for Linux VMs

1. Navigate to [Azure Portal](https://portal.azure.com/).

2. At the top of the page, type SSH to search. Under **Services**, select SSH keys.

3. On the **SSH Key** page, select **Create**.

   ![](images/portal-sshkey.png)

4. In **Resource group** select **Create new** to create a new resource group to store your keys. Type a name for your resource group and select **OK**.

5. In **Region** select a region to store your keys. You can use the keys in any region, this is just the region where they will be stored.

6. Type a name for your key in **Key pair name**.

7. In **SSH public key source**, select **Generate public key pair**.

8. When you are done, select **Review + create**.

9. After it passes validation, select Create.

10. You will then get a pop-up window to, select **Download private key and create resource**. This will download the SSH key as a .pem file.

      ![](images/download-key.png)

11. Once the .pem file is downloaded, you might want to move it somewhere on your computer where it is easy to point to from your SSH client.

### Deploy

1. Click **Deploy to Azure** to start the deployment.

   [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cicd-container%2Fazuredeploy.json)

   [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cicd-container%2Fazuredeploy.json)

   [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cicd-container%2Fazuredeploy.json)

2. Fill the form:

   * Choose a subscription.

   * Use a new resource group and choose a location.

   * Input the settings.

     > Note:
     >
     > * The names and DNS prefixes should be unique. To avoid naming conflicting, we strongly recommend you to add some suffix. For example, the Cosmos Db name could be **cosmos-180130-1512**.
     > * ACR (Azure Container Registry) names may contain alpha numeric characters only. A valid name is **acr1801301512**.
     > * Plesae select the **SSH Key** created in last step, rather than generate a new one.

   * Check **I agree to the terms and conditions stated above**.

3. Click **Purchase**.

   > Note: It will take about 13 minutes to finish the deployment.

### Deployment output

After the deployment finishes, you will get some important information from the outputs section.

![](images/azure-deployment-output.png)

>Note: the deployment window above could be re-open in the **Deployments** tab of the resource group.
>
>![](images/azure-resource-group-deployments.png)
>
>Click the first one **Microsoft.Template**.

## Access Deployed Resources

### Access Jenkins

This Jenkins instance does not support https, so logging in through a public IP address has been disabled (it would expose your password and other information to eavesdropping). To securely login, you need to connect to the Jenkins instance using SSH port forwarding.

#### Connect to the Jenkins instance using SSH port forwarding

1. Find out the SSH Key pem file path and replace the `<keyfile>` of below command.

2. Open terminal, then paste and execute it.

   ```Sh
   $ ssh -i <keyfile> -L 8080:localhost:8080 azureuser@jenkins-180131-1520.eastus.cloudapp.azure.com
   ECDSA key fingerprint is SHA256:ky3f+1oqa/nHzzLWZGf5TqiyZbJahoztoODcbobBGS8.
   Are you sure you want to continue connecting (yes/no/[fingerprint])?
   ```

3. Input **yes** and press **Enter** key to accept and add the ECDSA to the list of known hosts.

   ```sh
   Warning: Permanently added 'jenkins-180131-1520.eastus.cloudapp.azure.com,40.71.20.174' (ECDSA) to the list of known hosts.
   azureuser@jenkins-180131-1520.eastus.cloudapp.azure.com's password:
   ```

4. Input the **Linux Admin Password**

   If your pass work is correct, you will get the welcome message:

   ```Sh
   Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1067-azure x86_64)
   ...
   ```

   Keep the terminal open.

#### Get the Jenkins admin password

1. Execute the command in the terminal:

   ```Sh
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

2. You will get the Jenkins admin password which looks like below:

   ```Sh
   77a6d3183ad24f9ca7df6181c81400d0
   ```

3. Follow the Jenkins **Getting Started** wizard to finalise the setup. You just need to install default recommended plugins.

#### Log into Jenkins

1. Open http://localhost:8080 in a browser.

2. Click **log in** at the top-right.

3. Input the user and password:

   * User: admin
   * Password: *use the password you get in previous step*

   Click **log in**.

#### Check the sample pipeline job

After logged in, you will see the **Hello World Build & Deploy** pipline job. Please click to explore it.

![](images/jenkins-pipline-job.png)

### Access the hello world web app

#### Sign into Azure and get AKS credentials

1. Open terminal, execute:

   ```sh
   az login
   ```

   Follow the guide to sign in.

2. Execute the command below to get Kubenetes cluster credentials.

   ```sh
   aks get-credentials --resource-group <ResourceGroup> --name <KubenetesClusterName>
   ```

   > Note: please replace \<ResourceGroup> and \<KubenetesClusterName> before executing it.

   When done, you will get a prompt:

   ```Sh
   Merged "kube-180131-1520" as current context in /Users/<User>/.kube/config
   ```

#### Get Kubenetes service

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) if you have not. Or, you can install `kubectl` locally using the [az aks install-cli](https://docs.microsoft.com/cli/azure/aks#az-aks-install-cli) command:

   ```sh
   az aks install-cli
   ```

2. Execute the command below:

   ```Sh
   kubectl get service
   ```

3. You will get the response like below:

   ```Sh
   NAME                  TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)        AGE
   hello-world-service   LoadBalancer   10.0.98.99   52.168.126.156   80:32611/TCP   1h
   kubernetes            ClusterIP      10.0.0.1     <none>           443/TCP        1h
   ```

4. Copy the **external ip** of the **hello-world-service**.

#### Access the hello world web app

1. Open the **external ip** in a browser. You will see the response:

   ```html
   Hello World!
   There are 0 request records.
   ```

2. Refresh the page, the number of request records will increase.

### Access the Grafana instance

1. Copy the GRAFANAURL value from the Outputs section of the deployment.

2. Open it in a browser, then log in:

   * User: admin
   * Password: *use the Linux Admin Password*

3. Click **Home**.

   ![](images/grafana-01.png)

   Then click **Hello World Overview**:

   ![](images/grafana-02.png)

4. You will see the graphs:

   ![](images/grafana-03.png)

5. If you want to SSH to Grafana host machine, you can open terminal, then paste and execute a command like below.

   ```Sh
   ssh -i <private_ssh_key>  <username>@<GRAFANAURL>
   ```

`Tags: Microsoft.ContainerRegistry/registries, Microsoft.DocumentDb/databaseAccounts, Microsoft.Network/virtualNetworks, Microsoft.Resources/deployments, Microsoft.ContainerService/managedClusters, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, CustomScript`
