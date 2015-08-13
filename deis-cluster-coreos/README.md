# Deploy a Deis cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdeis-cluster-coreos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Deis cluster. The cluster is made up by three nodes, which are joined behind a load balancer with a public IP.


##Deploy the cluster

1. Generate an OpenSSH key pair:

		ssh-keygen -t rsa -b 4096 -c "[your_email@domain.com]"

2. Generate a certificate using the private key above:

		openssl req -x509 -days 365 -new -key [your private key file] -out [cert file to be generated]

3. Go to https://discovery.etcd.io/new to generate a new cluster token.

4. Modify **cloud-config.yaml** to replace the existing **discovery** token with the new token.

5. Modify **azuredeploy-parameters.json**: Open the certificate you created in step 2. Copy all text between  *----BEGIN CERTIFICATE-----* and *-----END CERTIFICATE-----* into the **sshKeyData** parameter (you'll need to remove all newline characters).

6. Modify other parameters such as **newStorageAccountName** and **publicDomainName** to values of your choice. 

7. Provision the resource group:

	You can use the PowerShell script:

		.\deploy-deis.ps1 -ResourceGroupName [resource group name] -ResourceGroupLocation "West US" -TemplateFile .\azuredeploy.json -ParametersFile .\azuredeploy-parameters.json -CloudInitFile .\cloud-config.yaml

	Or use the Shell script:

		./deploy-deis.sh -n "[resource group name]" -l "West US" -f ./azuredeploy.json -e ./azuredeploy-parameters.json -c ./cloud-config.yaml


>**Note:** If you chose to use the "Deploy to Azure" button experience, you'll need to manually encode **cloud-config.yaml** as a Base64 string and enter the encoded string to the **customData** parameter. Although the template can be updated to use the built-in base64() founction, I found the triple-encoding is rather troublesome especially for readability and maintenance.
		
##Install the client
You need **deisctl** to control your Deis cluster. *deisctl* is automatically installed in all the cluster nodes. However, it's a good practice to use *deisctl* on a separate administrative machine. Because all nodes are configured with only private IP addresses, you'll need to use SSH tunneling through the load balancer, which has a public IP, to the node machines. The following are the steps of setting up *deisctl* on a separate machine.

1. Install *deisctl*

		mkdir deis
		cd deis
		curl -sSL http://deis.io/deisctl/install.sh | sh -s 1.6.1
		sudo ln -fs $PWD/deisctl /usr/local/bin/deisctl

2. Add private key to ssh agent

		eval `ssh-agent -s`
		ssh-add [path to the private key file, see step 1 in the previous section]

3. Configure *deisctl*

		export DEISCTL_TUNNEL=[public ip of the load balancer]:2223

	>Note: the template defines inbound NAT rules that map 2223 to instance 1, 2224 to instance 2, and 2225 to instance 3. This provides redundancy for using the deisctl tool. Becuase of the limitation of NAT rule syntax, this implementation is constrianed to 3 nodes. If you want to have more nodes, you'll need to modify the NAT rules to define a new rule for each of the new nodes. This should be fixed, however I don't know what the best way is yet. A possible fix is to define two VM types. The first VM type will be defined with NAT rules to support the deisctl tool, while the second VM type will act as regular nodes.

##Install and start platform
Now you can use **deisctl** to install and start the platform

		deisctl config platform set domain=[some domain]
		deisctl config platform set sshPrivateKey=[path to the private key file]
		deisctl install platform
		deisctl start platform

> **Note:** starting the platform takes a while (>10 minutes). Especially, starting the builder service can take a long time. And sometimes it takes a few tries to succeed. If you found the operation seems to hang after a few minutes. You can use *ctrl+c* to break execution of the command and retry. Or, you can use the commands in the debugging tips section to find out the root causes of the problems.

> **Note:** as we don't have a custom DNS in the template, you should use a domain for which you can define a wildcard A record that points to the load balancer IP. For instance, if your domain is *yourdomain.com*, you should have a A record ***.yourdomain.com** pointing to the load balancer public IP.

##Deploy and scale a Hello World application
The following steps show how to deploy a "Hello World" Go application to the cluster. The steps are based on: http://docs.deis.io/en/latest/using_deis/using-dockerfiles/#using-dockerfiles.

1. Install **deis**

		mkdir deis
		cd deis
		curl -sSL http://deis.io/deis-cli/install.sh | sh
		ln -fs $PWD/deis /usr/local/bin/deis

2. Create a new SSH key

		cd ~/.ssh
		ssh-keygen (press [Enter]s to use default file names and empty passcode)

3. Add id_rsa.pub to GitHub (using Settings->SSH Keys section on your GitHub account).

	> **Note**: for step 2 and 3, you can also reuse your existing key.
	
4. Register a new user

		deis register http://deis.[your domain]

5. Add the SSH key:

		deis keys:add [path to your id_rsa.pub file in step 3]

6. Create an application:

		git clone https://github.com/deis/helloworld.git
		cd helloworld
		deis create
		git push deis master

7. Verify if the application is running:
	
		curl -S http://[your application name].[your domain]

	You should see:

		Welcome to Deis!
		See the documentation at http://docs.deis.io/ for more information.

	> Note: You can use *deis apps:list* to find out your application name.

8. Scale the application to 3 instances:

		deis scale cmd=3


##Other parameters

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| adminUsername | Name of the admin user | 
| customData | Explained above |
| newStorageAccountName | new storage account for the VMs OS disk |
| numberOfNodes | Number of member nodes. Currently only 3-node clusters are supported |
| publicDomainName | public domain name to be assoicated with the load balancer IP |
| sshKeyData | Explained above |
| vmSize | Instance size for the VMs |

##Deis debugging tips

1. First, verify if the VM machines have been provisioned correctly. When you ssh into the machines, you should see the Deis logo as ASCII art. If you don't see it, something has gone wrong with the cloud-init process. Probably you have an invalid cloud-init file.

2. As you ssh into the machine, verify if Docker daemon is running by running some Docker command such as *docker ps*.

3. Use *deisctl list* to list all services. Check if all services are running. If you found a service is in faulted state, you can try to use the following commands to find out why the service is failing:
	- List service journal

			deisctl journal [service]  #example: deisctl journal builder

	- Restart a service

			deisctl restart [service] #example: deisctl restart controller
	
	>Note: For more information, see http://docs.deis.io/en/latest/troubleshooting_deis/
