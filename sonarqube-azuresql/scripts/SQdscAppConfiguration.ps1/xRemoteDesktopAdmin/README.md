[![Build status](https://ci.appveyor.com/api/projects/status/iwctay9q3t2c72r8/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xremotedesktopadmin/branch/master)

# xRemoteDesktopAdmin

The **xRemoteDesktopAdmin** module contains the **xRemoteDesktopAdmin** DSC resource for configuring remote desktop settings and the Windows firewall on a local or remote machine.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Description

The **xRemoteDesktopAdmin** module contains the **xRemoteDesktopAdmin** DSC Resource. 
This DSC Resource allows you to configure remote desktop settings to either allow or prevent users to setup a remote desktop connection to a specific machine. 
In addition, it can optionally leverage the xPSDesiredStateConfiguration resources **xFirewall** and **xGroup**.
This allows you to configure remote desktop settings and create the necessary firewall rules to allow a remote session and add a domain user to the local Remote Desktop Users group.


## Resources

### xRemoteDesktopAdmin

* **Ensure**: Ensures that “remote connections to this computer” are allowed or disallowed: { Absent | Present }
* **UserAuthentication**: Enables or disables “Network Level Authentication”. Valid values are:
  * Secure
  * NonSecure


## Versions

### 1.1.0.0

* Updated OutputType to System.Boolean for Test-TargetResource and removed for Set-TargetResource.
xRemoteDesktopSessionHost

### 1.0.3.0

* Updated examples

### 1.0.2.0

* Update to correct issue in Set-TargetResource when checking Ensure 

### 1.0.0.0

* Initial release with the following resource:
    * xRemoteDesktopAdmin


## Examples

### [ExampleConfiguration-RemoteDesktopAdmin.ps1](Examples/ExampleConfiguration-RemoteDesktopAdmin.ps1)

This configuration configures the target system to allow for remote connections (i.e. allows an RDP session to be setup), enables Network Level Authentication and creates a Windows firewall rule to allow incoming RDP traffic.

### [ExampleConfiguration-RemoteDesktopAdminWithUnEncryptedPassword.ps1](Examples/ExampleConfiguration-RemoteDesktopAdminWithUnEncryptedPassword.ps1)

This configuration extends the previous configuration by adding a domain user to the local Remote Desktop Users group using a credential stored in clear text (for testing purposes only).
Note: this Example requires the built-in **Group** resource. 

### [ExampleConfiguration-RemoteDesktopAdminWithEncryptedPassword.ps1](Examples/ExampleConfiguration-RemoteDesktopAdminWithEncryptedPassword.ps1)

This configuration extends the previous configuration by adding a domain user to the local Remote Desktop Users group using certificates to encrypt credentials. Please refer to [this blog post](please refer to http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx) for more info on how to use certificates to encrypt passwords.
