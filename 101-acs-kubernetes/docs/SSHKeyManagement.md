# SSH Key Management

## SSH Key Generation

When creating container services, you will need an SSH RSA key for access.  Use the following articles to create your SSH RSA Key:

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac

# Key Management and Agent Forwarding with Windows Pageant

Pageant enables agent forwarding.  This means that you can SSH from any of the master nodes directly to any of the agent nodes.  Here are the steps to enable this:
 1. Download and install [Putty Pageant](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).
 2. Double Click on pageant.exe to run, and you will notice it appears in your tray

  ![Image of Pageant in the tray](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-dcos/images/pageant-tray.png)

 3. Right click on Pageant in the tray and click "View Keys"
 4. Click "Add Key", and add your PPK generated in (#ssh-key-generation).

  ![Image of Pageant addkey](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-dcos/images/pageant-addkey.png)

 5. Now try out the configuration by opening up Putty.exe
 6. Type in "azureuser@FQDN" and port 2200 where FQDN is the management name returned after deploying a cluster and port:

  ![Image of Putty main](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-dcos/images/putty-address.png)

 7. Browse to Connection->SSH->Auth and click "Allow agent forwarding":

  ![Image of Putty SSH](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-dcos/images/putty-agentforwarding.png)

 8. Click "Open" to connect to the master.  Now ssh directly to an agent, and you will connect automatically.


