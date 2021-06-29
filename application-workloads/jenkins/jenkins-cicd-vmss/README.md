# Immutable Infrastructure CI/CD using Jenkins and Terraform on Azure Virtual Machine Scale Sets

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-vmss/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-vmss/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-vmss/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-vmss/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-vmss/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cicd-vmss/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cicd-vmss%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cicd-vmss%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cicd-vmss%2Fazuredeploy.json)



Azure is a world-class cloud for hosting virtual machines running Windows or Linux. Whether you use Java, Node, Go or PHP to develop your applications, you will need a continuous integration and continuous deployment (CI/CD) pipeline to push your changes to these virtual machines automatically.

## Deployment steps

1. Create service principal with the `Contributor` role with [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest) if you don't have one in your subscription.
   ```shell
   az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
   ```

2. Your appId, password, sp_name, and tenant are returned. Make a note of the **appId** and **password**.

3. Click the **Deploy to Azure** button at the beginning of this document, and fill in the settings.
   - **Jenkins VM Admin Username** - Provide the user name for the Jenkins Virtual Machine.
   - **Jenkins VM Admin Password** - Provide the password for the Jenkins Virtual Machine, it must meet the complexity requirements, e.g. `30Jan2@18`
   - **Jenkins Dns Prefix** - Provide the unique DNS name for the Public IP used to access the Jenkins Virtual Machine.
   - **Jenkins Release Type** - Provide the Jenkins release type.
   - **Repository Url** - Provide the GitHub repository URL for the source code.
   - **Client Id** - Provide the client id for Azure service principal, use **appId** noted above.
   - **Client Secret** - Provide the client secret for Azure service principal, use **password** noted above.
   - **VM Dns Prefix** - Provide the unique DNS prefix name for the VMSS VMs and Jumpbox VM.
   - **VM Admin Username** - Provide the username for the VMSS VMs.
   - **VM Admin Password** - Provide the password for the VMSS VMs, it must meet the complexity requirements, e.g. `30Jan2@18`
   - **OMS Workspace Name** - Provide the OMS workspace name.
   - **_artifacts Location** - Leave it with the default value.
   - **_artifacts Location Sas Token** - Leave it with the default value.

## Usage

### Check Jenkins Build Job Status

1. Find out the Jenkins URL in either **Outputs** section of the ARM template deployment blade, or in the `JenkinsPublicIP` component in the new resource group.

   ![](images/arm-output.png)
   ![](images/jenkins-publicip.png)

2. Open Jenkins URL in browser.

3. The `BuildVM` job will run automatically once the deployment complete, a running build instance will present in the **Build Executor Status** section at the bottom of the left side bar, or alternatively a completed build instance present in **Last Success** or **Last Failure** column if the build complete.

   ![](images/jenkins-anonymous.png)

3. Click the build number (e.g. `#1`).

4. Click the **Console Output** in the left sidebar.

   ![](images/jenkins-build-overview.png)

5. The build console output will be shown and keep refreshed until the build completes.
   ![](images/jenkins-build-output.png)

### Manage Jenkins

If you want to manage Jenkins, e.g. trigger a build manually, just follow the steps below.

1. Click the **log in** button on the top right of the Jenkins page.

   The Jenkins console is inaccessible through unsecured HTTP so instructions are provided on the page to access the Jenkins console securely from your computer using an SSH tunnel.

   ![](images/jenkins-login.png)

2. Set up the tunnel using the `ssh` command on the page from the command line, replacing `username` with the name of the virtual machine admin user chosen earlier.

   ```shell
   ssh -L 127.0.0.1:8080:localhost:8080 username@msvmsstest004.eastus.cloudapp.azure.com
   ```

   Or use [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/) for Windows client alternatively.

   ```shell
   putty -ssh -L 127.0.0.1:8080:localhost:8080 username@msvmsstest004.eastus.cloudapp.azure.com
   ```

3. Get the initial password by running the following command in the command line while connected through SSH to the Jenkins VM.

   ```shell
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

4. Navigate to http://localhost:8080/ on your local machine.

5. Sign in with the user name `admin` and the initial password above.
   
   ![](images/jenkins-login-ssh.png)

6. Proceed management operations as need.

### Manage VMSS

The VMSS components are created in a separate resource group whose name is postfixed with `-VMSS`, you could access and manage them via the Azure portal.

> **Note:** Any custom changes in the VMSS components would get lost when there's new commits in the repository specified by the ARM template parameter **Repository Url**, as that would trigger Jenkins job to re-create the image and all VMSS components.

![](images/vmss-resources.png)

### Connect to HelloWorld Java Web App

1. The website URL of the Java web app could be found in the output of the Jenkins build (see this [section](#check-jenkins-build-job-status)), or in the `vmss-public-ip` component in the separate resource group for VMSS components.

   ![](images/vmss-publicip.png)

2. Navigate to the HelloWorld web app.

   ![](images/vmss-webapp.png)


