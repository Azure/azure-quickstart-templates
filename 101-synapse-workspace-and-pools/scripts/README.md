# Get Object ID PowerShell Script

## Purpose
This script is used to do the following:

- Get the Object ID of the Azure Active Directory user who will be deploying the Azure Synapse Proof-of-Concept and testing it.

This Object ID is then placed as a parameter into the ARM Template file

## Steps
- Click through into the GetObjectID.ps1 file in GitHub
- Right click on the 'Raw' button on the right hand side of GitHub and 'Save Target/Link As...'

![GitHub Raw](https://raw.githubusercontent.com/JamJarchitect/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/5.png)

- Save the file as a PowerShell Script (*.ps1)

![Save As](https://raw.githubusercontent.com/JamJarchitect/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/6.png)

- Start Windows PowerShell as Administrator and go to the folder where you downloaded the PowerShell Script
- Once you've changed the directory to the download location of the script, run the script. In the screenshot below I downloaded the script to the C:\temp\ directory, changed my PowerShell location to it and running the script but putting in `.\GetObjectID.ps1`

![PowerShell Run](https://raw.githubusercontent.com/JamJarchitect/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/7.png)

- The will then check for the Azure AD PowerShell module needed for this script
    - If this module does not exist, it will then install the module
    - **NOTE:** You may be asked to agree to licenses and receive module installation warnings
- Once installed, the script will ask you to log into Azure Active Directory. Log in with the account that will be deploying the template and testing the Proof-of-Concept
- The end result is an Object ID which you will use as a parameter in your ARM Template Deployment. Below is a screenshot of a demo run of the script:

![PowerShell Run](https://raw.githubusercontent.com/JamJarchitect/azure-quickstart-templates/master/101-synapse-workspace-and-pools/images/8.png)

