# VM-Redhat - Team Services Build Agent and Cross-Platform SDKs installation

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-fullbuild-redhat-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-fullbuild-redhat-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-fullbuild-redhat-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-fullbuild-redhat-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-fullbuild-redhat-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-fullbuild-redhat-vm/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvsts-fullbuild-redhat-vm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvsts-fullbuild-redhat-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvsts-fullbuild-redhat-vm%2Fazuredeploy.json)

This template allows you to create multiple (1 or more) Red Hat VMs with a full cross-platform development environment to support:
* OpenJDK 6, 7 and 8; 
* Ant, Maven and Gradle;
* npm and nodeJS;
* groovy and gulp;
* Gnu C and C++ along with make;
* Perl, Python, Ruby and Ruby on Rails;
* .NET Core;
* go;
* Docker Engine and Docker Compose; and
* the VSTS CoreCLR Linux Build Agent. 
(Build Agent available here: https://github.com/Microsoft/vsts-agent).

To learn more about Visual Studio Team Services (VSTS) and Team Foundation Server (TFS) support for Java, check out:
http://java.visualstudio.com/

## Before you Deploy to Azure

To create the VM, you will need to:

1. Know the Team Services URL (e.g. https://myaccount.visualstudio.com)

2. Create or obtain a Personal Access Token (PAT) from Team Services which has *"Build (read and execute)"* and *"Agent Pools (read, manage)"* privileges/capabilities
(see https://www.visualstudio.com/en-us/docs/setup-admin/team-services/use-personal-access-tokens-to-authenticate).

3. Create or obtain a build agent pool in Team Services (or use "Default")
(see https://www.visualstudio.com/en-us/docs/release/getting-started/configure-agents)

4. Decide on a name for your build agent (i.e. the name for your agent within the above pool).

## Verifying the Agent
Once the VM is successfully provisioned, Team Services build agent installation and initialization can be verified by accessing the the *Agent pools* tab under the Control panel for the Team Services account
(e.g. https://myaccount.visualstudio.com/_admin/_AgentPool).  You should be able to click on the build agent pool (from #3 above)
and see your agent listed by the name (used in #4 above).  If all is well, the colored bar to the left of the pool name should be green.
If the colored bar is red, or if the agent name does not appear in the specified pool, see below for debugging hints.

## Debugging Agent Failures
For general information on administering build agents, visit https://www.visualstudio.com/en-us/docs/build/admin/.

If the Azure portal under *Virtual machines* shows that your VM is *Running* (in the Status column) but either the build agent name does not 
show up under the build Agent Pool in Team Services OR the agent name does show up but has a red colored bar to the left of the name,
then you can SSH into the VM and check the installation log.  To do this:
* SSH into the VM using the name (or IP number) of the VM, and account name and the password you specified when setting up the VM.
(You can SSH from the command line of another computer or use a free tool such as MobaXterm).
* Once logged onto the VM, in the top directory of the account should be a file called *"vsts.install.log.txt"*.  Use the 
*cat* command to display its contents (i.e. **cat vsts.install.log.txt**).  Look for any errors in this file to indicate what failed 
in starting up the VSTS build agent.  The most common mistake is not having the correct permissions for the PAT (see #2 above for more guidance).
* If the agent started successfully and is running but an expected tool or software is not working from a build task (e.g. a build task can't find
maven or java or ...), then you can check the file *"install.progress.txt"* in the top level directory to see if one of the packages
may have failed to install or had errors (**cat install.progress.txt**).


