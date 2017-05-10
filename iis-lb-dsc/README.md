# Deploys n number of Windows VM instances in an Availability Set with a Load Balancer and configures IIS with a DSC script.

Description of Template
=======================
This template allows you to create a set of Windows Virtual Machines in an Availability Set under a Load Balancer. It also configures a IIS with a DSC script

The template uses a DSC extension which executes the script located in IISDesiredStateConfiguration.zip in  a storage account.

Inside the IISDesiredStateConfiguration.zip is a powershell script with the same name and the following code:

    Configuration WebServer
    {
    
    Param ( [string] $vmName )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node $vmName
      {
    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature WebManagementConsole
    {
      Name = "Web-Mgmt-Console"
      Ensure = "Present"
    }
    WindowsFeature WebManagementService
    {
      Name = "Web-Mgmt-Service"
      Ensure = "Present"
    }
    WindowsFeature ASPNet45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }
    WindowsFeature HTTPRedirection
    {
      Name = "Web-Http-Redirect"
      Ensure = "Present"
    }
    WindowsFeature CustomLogging
    {
      Name = "Web-Custom-Logging"
      Ensure = "Present"
    }
    WindowsFeature LogginTools
    {
      Name = "Web-Log-Libraries"
      Ensure = "Present"
    }
    WindowsFeature RequestMonitor
    {
      Name = "Web-Request-Monitor"
      Ensure = "Present"
    }
    WindowsFeature Tracing
    {
      Name = "Web-Http-Tracing"
      Ensure = "Present"
    }
    WindowsFeature BasicAuthentication
    {
      Name = "Web-Basic-Auth"
      Ensure = "Present"
    }
    WindowsFeature WindowsAuthentication
    {
      Name = "Web-Windows-Auth"
      Ensure = "Present"
    }
    WindowsFeature ApplicationInitialization
    {
      Name = "Web-AppInit"
      Ensure = "Present"
    }
      }
    }



Setup the Storage Account for the DSC script
============================================
1. Create a storage account
2. Create a container in the blob (installscripts or something)
3. Download storage explorer and connect to the storage account
3. Create a powershell script called IISDesiredStateConfiguration.ps1 and copy the above code.  Save the script
4. Right click on the script and compress to .zip file
5. Copy the .zip file to the blob container with storage explorer
6. If you changed any names of the .zip or powershell you will have to update the json template with you file names
7. You will have to update the following parameters in the azuredeploy.parameters.json

    "dscStorageAccountName": {
      "value": ""
    },

    "dscStorageKey": {
      "value": ""
    },

    "blobLocation": {
      "value": ""
    }

