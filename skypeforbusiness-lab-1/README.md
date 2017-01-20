# Azure SfB lab
Azure template for a Skype for Business

# Create a Skype for Business 2015 Standard Edition Lab

This template will deploy a complete Skype for Business 2015 setup in a minimum of 2hr35min, a kind of onpremises deployment lab, mainly for training and test purpose. 
For this first release, it includes 3 VM's 1 AD Domain Controler , 1 SfB Front End server and 1 Windows 10 client which include Skype client. Edge Server, Reverse Proxy and ADFS will be added shortly in order to setup external connectivity as well as hybrid labs with Office365 CloudPBX.

Before starting the deployment there is some steps to follow:

1. Create an azure storage account with a fileshare named "skype" where Skype for Business software (content of the ISO) will be accessible.
2. Create a correct folder structure where to put SfB software see below
3. Download Skype for Business 2015 eval software and put the content of the ISO in "\skype\SfBserver2015\"
4. Download Skype Basic or Skype 2016 eval, rename it to "setup.exe" and put it in "\skype\SfB2016\"
5. Download Silverlight_x64.exe and put it in "\skype" folder
6. Download 3 mandatory Windows Server 2012 updtates (KB2919355, KB2919442, KB2982006) and put them into "\Skype" folder
7. Then Click the button below to deploy
8. You will have to fill some parameters like your storage account name and the sastoken as well as some other mandatory parameters like the dns prefix of your lab. Please remember to use only numbers plus lower case letters for your resource group name because it is concatenated to create a storage account name which support only lower case. Use Western Europe instead of Uk south it doesn't support yet the types of VM's used.


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fibenbouzid%2FAzure_sfb2015_lab%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fibenbouzid%2FAzure_sfb2015_lab%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

You can either deploy through the azure deploy button (which take less time) or via the azuredeploy.ps1 powershell script which requires to previously setup your machine with the right Azure modules.

# Folder structure
The folder structure inside your storage account should look like this

<a >
<img src="https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master/images/FolderStructure.jpg"/>
</a>

Here is SfBServer2015 and SfB2016 folders components
<a >
<img src="https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master/images/SfBServer2015.jpg"/>
<img src="https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master/images/SfB2016.jpg"/>
</a>

# Software

You can download Skype for business eval version here :
https://www.microsoft.com/en-gb/evalcenter/evaluate-skype-for-business-server

And the Skype 2016 client Here
https://products.office.com/en-gb/skype-for-business/download-app?tab=tabs-3
