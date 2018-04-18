[![Build status](https://ci.appveyor.com/api/projects/status/cg28qxeco39wgo9l/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xcomputermanagement/branch/master)

# xComputerManagement

The xComputerManagement module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit, which is a collection of DSC Resources produced by the PowerShell Team.
This module contains the xComputer resource.
This DSC Resource allows you to rename a computer and add it to a domain or workgroup.

All of the resources in the DSC Resource Kit are provided AS IS, and are not supported through any Microsoft standard support program or service.
The ""x" in xComputerManagement stands for experimental, which means that these resources will be fix forward and monitored by the module owner(s).

Please leave comments, feature requests, and bug reports in the Q & A tab for this module.

If you would like to modify xComputerManagement module, feel free.
When modifying, please update the module name, resource friendly name, and MOF class name (instructions below).
As specified in the license, you may copy or modify this resource as long as they are used on the Windows Platform.

PowerShell Blog (this is a good starting point).
There are also great community resources, such as PowerShell.org, or PowerShell Magazine.
For more information on the DSC Resource Kit, check out this blog post.

## Installation
To install xComputerManagement module

Unzip the content under $env:ProgramFiles\WindowsPowerShell\Modules folder
To confirm installation:

Run Get-DSCResource to see that xComputer is among the DSC Resources listed
Requirements
This module requires the latest version of PowerShell (v4.0, which ships in Windows 8.1 or Windows Server 2012R2).
To easily use PowerShell 4.0 on older operating systems, install WMF 4.0.
Please read the installation instructions that are present on both the download page and the release notes for WMF 4.0

## Description
The xComputerManagement module contains the xComputer DSC Resource.
This DSC Resource allows you to configure a computer by changing its name and modifying its domain or workgroup.

## Details
xComputer resource has following properties:

* Name: The desired computer name
* DomainName: The name of the domain to join
* JoinOU: The distinguished name of the organizational unit that the computer account will be created in
* WorkGroupName: The name of the workgroup
* Credential: Credential to be used to join or leave domain
* CurrentOU: A read-only property that specifies the organizational unit that the computer account is currently in

## Versions

### Unreleased

### 1.4.0.0
* Adding Name parameter validation

### 1.3.0

* xComputer
    * Fixed issue with Test-TargetResource when not specifying Domain or Workgroup name
    * Added tests

### 1.2.2

Added types to Get/Set/Test definitions to allow xResourceDesigner validation to succeed

### 1.2

Added functionality to enable moving computer from one domain to another
Modified Test-DscConfiguration logics when testing domain join

### 1.0.0.0

Initial release with the following resources
* xComputer


## Examples
### Change the Name and the Workgroup Name

This configuration will set a machine name and changes the workgroup it is in.

```powershell
configuration Sample_xComputer_ChangeNameAndWorkGroup 
{ 
    param 
    ( 
        [string[]]$NodeName ='localhost', 
 
        [Parameter(Mandatory)] 
        [string]$MachineName, 
         
        [Parameter(Mandatory)] 
        [string]$WorkGroupName 
    ) 
      
    #Import the required DSC Resources  
    Import-DscResource -Module xComputerManagement 
 
    Node $NodeName 
    { 
        xComputer NewNameAndWorkgroup 
        { 
            Name          = $MachineName 
            WorkGroupName = $WorkGroupName 
        } 
    } 
}  
```

### Switch from a Workgroup to a Domain
This configuration sets the machine name and joins a domain.
Note: this requires a credential.

```powershell
configuration Sample_xComputer_WorkgroupToDomain 
{ 
    param 
    ( 
        [string[]]$NodeName="localhost", 
 
        [Parameter(Mandatory)] 
        [string]$MachineName, 
 
        [Parameter(Mandatory)] 
        [string]$Domain, 
 
        [Parameter(Mandatory)] 
        [pscredential]$Credential 
    ) 
 
    #Import the required DSC Resources 
    Import-DscResource -Module xComputerManagement 
 
    Node $NodeName 
    { 
        xComputer JoinDomain 
        { 
            Name          = $MachineName  
            DomainName    = $Domain 
            Credential    = $Credential  # Credential to join to domain 
        } 
    } 
} 
 
<#**************************** 
To save the credential in plain-text in the mof file, use the following configuration data 
 
$ConfigData = @{   
                 AllNodes = @(        
                              @{     
                                 NodeName = "localhost" 
                                 # Allows credential to be saved in plain-text in the the *.mof instance document.
                            
                                 PSDscAllowPlainTextPassword = $true 
                              } 
                            )  
              } 
 
Sample_xComputer_WorkgroupToDomain -ConfigurationData $ConfigData -MachineName <machineName> -credential (Get-Credential) -Domain <domainName> 
****************************#> 
```

### Change the Name while staying on the Domain

This example will change the machines name while remaining on the domain.
Note: this requires a credential.

```powershell
function Sample_xComputer_ChangeNameInDomain 
{ 
    param 
    ( 
        [string[]]$NodeName="localhost", 
 
        [Parameter(Mandatory)] 
        [string]$MachineName, 
 
        [Parameter(Mandatory)] 
        [pscredential]$Credential 
    ) 
 
    #Import the required DSC Resources  
    Import-DscResource -Module xComputerManagement 
 
    Node $NodeName 
    { 
        xComputer NewName 
        { 
            Name          = $MachineName 
            Credential    = $Credential # Domain credential 
        } 
    } 
} 
 
<#**************************** 
To save the credential in plain-text in the mof file, use the following configuration data 
 
$ConfigData = @{   
                AllNodes = @(        
                             @{     
                                NodeName = "localhost"; 
 
                                # Allows credential to be saved in plain-text in the the *.mof instance document.
                            
                                PSDscAllowPlainTextPassword = $true; 
                          } 
                 )       
            }     
 
Sample_xComputer_ChangeNameInDomain -ConfigurationData $ConfigData -MachineName <machineName>  -Credential (Get-Credential) 
 
*****************************#> 
```

### Change the Name while staying on the Workgroup
This example will change the machines name while remaining on the workgroup.

```powershell
function Sample_xComputer_ChangeNameInWorkgroup 
{ 
    param 
    ( 
        [string[]]$NodeName="localhost", 
 
        [Parameter(Mandatory)] 
        [string]$MachineName 
    ) 
 
    #Import the required DSC Resources      
    Import-DscResource -Module xComputerManagement 
 
    Node $NodeName 
    { 
        xComputer NewName 
        { 
            Name = $MachineName 
        } 
    } 
}  
```

### Switch from a Domain to a Workgroup
This example switches the computer from a domain to a workgroup.
Note: this requires a credential.

```powershell
function  Sample_xComputer_DomainToWorkgroup 
{ 
    param 
    ( 
        [string[]]$NodeName="localhost", 
 
        [Parameter(Mandatory)] 
        [string]$MachineName, 
 
        [Parameter(Mandatory)] 
        [string]$WorkGroup, 
 
        [Parameter(Mandatory)] 
        [pscredential]$Credential 
    ) 
 
    #Import the required DSC Resources      
    Import-DscResource -Module xComputerManagement 
 
    Node $NodeName 
    { 
        xComputer JoinWorkgroup 
        { 
            Name          = $MachineName 
            WorkGroupName = $WorkGroup 
            Credential    = $Credential # Credential to unjoin from domain 
        } 
    } 
} 
 
<#**************************** 
To save the credential in plain-text in the mof file, use the following configuration data 
 
$ConfigData = @{   
                AllNodes = @(        
                             @{     
                                NodeName = "localhost"; 
                                # Allows credential to be saved in plain-text in the the *.mof instance document.
                            
                                PSDscAllowPlainTextPassword = $true; 
                              } 
                           )       
                } 
 
Sample_xComputer_DomainToWorkgroup -ConfigurationData $ConfigData -MachineName <machineName> -credential (Get-Credential) -WorkGroup <workgroupName> 
****************************#> 
```

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).
