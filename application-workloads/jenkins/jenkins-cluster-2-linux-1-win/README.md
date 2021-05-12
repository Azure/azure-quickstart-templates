# ARM Template for Deploying Jenkins Master/Slave Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cluster-2-linux-1-win/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cluster-2-linux-1-win/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cluster-2-linux-1-win/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cluster-2-linux-1-win/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cluster-2-linux-1-win/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/jenkins-cluster-2-linux-1-win/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cluster-2-linux-1-win%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cluster-2-linux-1-win%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fjenkins-cluster-2-linux-1-win%2Fazuredeploy.json)   

1.  Start the Jenkins Master VM and access the the URL 

    http://jenkins-cluster-mx.southeastasia.azure.com:8080/

2.  Create a remote ssh session (Use PuTTY or Ubuntu Bash or Git Bash)
    And enter following command to get the initial password.

    ```bash
    $ sudo cat /var/lib/jenkins/secret/initialAdminPassword
    ```

3.  Copy the content of file displayed by `cat` command.
    And paste this password in jenkins web-page. Click continue button and then use `Install Suggested Plugins`

4.  After Plugin Installation, it should then ask for New User creation. Create a new user (Admin) for regular login into jenkins dashboard. 

5.  After User creation, continue to dashboard.

6.  Now, SSH into Master node to generate new SSH-Key Pair and copy it to node-1

    ```
    # Become ROOT user
    $ sudo -i
    # Become jenkins user
    $ su - jenkins
    ## No password prompt
    # Generate SSH Key Pair
    $ ssh-keygen 
    # PRESS ENTER at ALL PROMPTS
    # Now, Copy SSH key
    $ ssh-copy-id jenkins@10.0.1.11
    Enter Password: pass@12345
    Add to Known Server: Yes
    ## Now, test it..
    $ ssh -i .ssh/id_rsa jenkins@10.0.1.11
    ## check if allowed to access node-1
    ## Exit from node-1
    $ exit
    # Print Private key on screen
    $ cat .ssh/id_rsa.pub
    # Copy the content of
    ## exit SSH Connection
    $ exit
    ```

7.  Now, You need to register 'node-1' with private-ip `10.0.1.11` as jenkins slave instance.

    Manage Jenkins > Manage Nodes & Cloud > New Node

    ```yaml
    Name: Node-1
    Usage: Use this node as much as possible
    # Of executors: 2
    Remote Root directory: /home/jenkins
    Launch Method: Launch slave agent via SSH
    Host: 10.0.1.11
    Credentials: <CHOOSE SSH KeyPair Credentials>
    ```

