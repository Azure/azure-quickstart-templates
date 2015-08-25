# Create a simple Windows Multi-VM Deployment from the Azure Marketplace

This example includes an Azure Resource Manager (ARM) Template that deploys two or more Windows Virtual Machines and all the required resources including the Storage Accounts, Virtual Networks, Public IP Address, etc. This example will enable you create a createUiDefinition file and map it to the ARM Template is the right manner. 

###Basics:
* The createUiDefinition provides a mechanism for the partner to define the create UI flow that is shown to the end users of their product on the Azure Portal.
* It is typescript free, enabling the partner to create & modify without writing a custom Portal Extension
* The createUiDefinition is a simple .json that defines the UI elements required and the mapping from the UI Elements to the ARM Template
* It needs to be submitted alongside the mainTemplate.json as part of the Solution Template publishing process

###Details:
* The first step is to think about the user experience you want to provide the customer when deploying your product. The portal currently supports a wizard style creation flow once the customer chooses an item in the Marketplace. This wizard style flow has the below characteristics:
1.	It has a set of numbered steps that lead a user through the creation process
2.	It starts with a basics section which represents the very general deployment wide set of information required to deploy a product on Azure
	-	Subscription
	-	Location
	-	Resource Group
	-	<Partner controlled basic Items> e.g. Cluster Names, Admin Username, Password\SSH,..
3.	The next set of steps are controlled by entirely by the partner. These could include one or more steps with the below:
	-	Storage Account
	-	Virtual Network
	-	IP\DNS
	-	Size\Price Tiers
	-	<Partner controlled detailed items> e.g. Master and Worker Tier configuration, web & data tier configuration, …
4.	It then provides a summary blade which allows the user to validate all the chosen settings before hitting Create. This provides a user the opportunity to go back and edit settings in case where was an error.
5.	The last blade is also auto-added. It provides a mechanism to showcase any Legal & pricing summary for the partner product and ensure the users accept the terms before purchase (hit Buy).

* The second step is start authoring the createUiDefinition file. The schema for the createUiDefinition elements can be found here: <https://github.com/azure/azure-portal-createuidefinition> 
1. Create the basic schema for the file
```
	{
	  "handler": "Microsoft.Compute.MultiVm",
	  "version": "0.0.1-preview",
	  "parameters": {
		"basics": [],
		"steps": [],
		"outputs": {}
	  }
	}
```	
2. Next add in the UI elements you want to show the end user in the 'basics' and one or more 'steps' blades.
	1. Basics
		In this sample I have added the Admin Username and Password for all nodes as part of the basics step. I selected the special controls for Compute credentials from the schema and used them as part of the createUiDefinition.
		* Microsoft.Compute.UserNameTextBox 
		* Microsoft.Compute.CredentialsCombo
	2. Steps
		In this sample I have created a single step called infrastructure settings and added all the required infrastructure controls required to create a set of Virtual Machines.
		* New or Existing Storage Account
		* VM Count
		* VM Size
		* Public IP and DNS
		* TODO: Add Control for New and Existing Virtual Network

3. Create the mapping to the Solution Templates parameters in the 'outputs' section
	This section provides the information required by the UI to map the createUiDefinition to the ARM Template to enable the end to end deployment. Ensure that every Solution Template parameter that requires an input from the UI is specified as part of this mapping section
