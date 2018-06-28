[![Build status](https://ci.appveyor.com/api/projects/status/u3h1665qqneo98bh/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xsystemsecurity/branch/master)

# xSystemSecurity

The **xSystemSecurity** module contains the **xUAC** and **xIEEsc** DSC resources for configuring and managing UAC and IE Enhanced Security Configuration. 

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


# Resources

* **xUAC** handles how and when the User Account Control Windows Prompt shows up or doesn't show up. 
* **xIEEsc** enables or disables IE Enhanced Security Configuration.

### xUAC

* **Setting**: The desired User Account Control Setting: { AlwaysNotify | NotifyChanges | NotifyChangesWithoutDimming | NeverNotify | NeverNotifyAndDisableAll }
    - **AlwaysNotify**: You will be notified before programs make changes to your computer or to Windows settings that require the permissions of an administrator.
    When you're notified, your desktop will be dimmed, and you must either approve or deny the request in the UAC dialog box before you can do anything else on your computer. 
    The dimming of your desktop is referred to as the secure desktop because other programs can't run while it's dimmed.
    This is the most secure setting.
    When you are notified, you should carefully read the contents of each dialog box before allowing changes to be made to your computer.
    - **NotifyChanges**: You will be notified before programs make changes to your computer that require the permissions of an administrator.
    You will not be notified if you try to make changes to Windows settings that require the permissions of an administrator.
    You will be notified if a program outside of Windows tries to make changes to a Windows setting.
    It's usually safe to allow changes to be made to Windows settings without you being notified. 
    However, certain programs that come with Windows can have commands or data passed to them, and malicious software can take advantage of this by using these programs to install files or change settings on your computer. 
    You should always be careful about which programs you allow to run on your computer.
    - **NotifyChangesWithoutDimming**: You will be notified before programs make changes to your computer that require the permissions of an administrator.
    You will not be notified if you try to make changes to Windows settings that require the permissions of an administrator.
    You will be notified if a program outside of Windows tries to make changes to a Windows setting.
    This setting is the same as "NotifyChanges" but you are not notified on the secure desktop.
    Because the UAC dialog box isn't on the secure desktop with this setting, other programs might be able to interfere with the dialog's visual appearance. 
    This is a small security risk if you already have a malicious program running on your computer.
    - **NeverNotify**: You will not be notified before any changes are made to your computer. 
    If you are logged on as an administrator, programs can make changes to your computer without you knowing about it.
    If you are logged on as a standard user, any changes that require the permissions of an administrator will automatically be denied.
    If you select this setting, you will need to restart the computer to complete the process of turning off UAC. 
    Once UAC is off, people that log on as administrator will always have the permissions of an administrator.
    This is the least secure setting. When you set UAC to never notify, you open up your computer to potential security risks.
    If you set UAC to never notify, you should be careful about which programs you run, because they will have the same access to the computer as you do. 
    This includes reading and making changes to protected system areas, your personal data, saved files, and anything else stored on the computer. 
    Programs will also be able to communicate and transfer information to and from anything your computer connects with, including the Internet.
    - **NeverNotifyAndDisableAll**: You will not be notified before any changes are made to your computer. 
    If you are logged on as an administrator, programs can make changes to your computer without you knowing about it.
    If you are logged on as a standard user, any changes that require the permissions of an administrator will automatically be denied.
    If you select this setting, you will need to restart the computer to complete the process of turning off UAC. 
    Once UAC is off, people that log on as administrator will always have the permissions of an administrator.
    This is the least secure setting same as “NeverNotify”, but in addition EnableLUA registry key is disabled.
    EnableLUA controls the behavior of all UAC policy settings for the computer. 
    If you change this policy setting, you must restart your computer
    We do not recommend using this setting, but it can be selected for systems that use programs that are not certified for Windows® 8, Windows Server® 2012, Windows® 7 or Windows Server® 2008 R2 because they do not support UAC.

### xIEEsc

* **UserRole**: Enable or Disable ESC for **Administrators** or **Users**.
* **IsEnabled**: Determines if ESC is **Enabled** or **Disabled**.

Please refer to [this article](http://technet.microsoft.com/en-us/library/dd883248(v=ws.10).aspx) for the effects and security impact of Enhanced Security Configuration. 


## Versions

### Versions

### 1.1.0.0

* Fixed encoding

### 1.0.0.0

* Initial release with the following resources 
    - xUAC
    - xIEEsc 

## Examples
### Disable User Account Control 

This configuration will never show the UAC prompt and will disable all User Account Control settings. 
This setting when changed requires a restart of the computer.

```powershell
Configuration NeverNotifyAndDisableAll
{
    Import-DSCResource -Module MSFT_xSystemSecurity -Name xUac

    Node localhost
    {
        xUAC NeverNotifyAndDisableAll
        {
            Setting = "NeverNotifyAndDisableAll"
        }
    }
} 
```

### Disable IE Enhanced Security Configuration

This configuration will disable IE Enhanced Security Configuration. 

```powershell
Configuration DisableLocalIEEsc
{
    Import-DSCResource -Module MSFT_xSystemSecurity -Name xIEEsc

    Node localhost
    {
        xIEEsc DisableIEEsc
        {
            IsEnabled = $false
            UserRole = "Users"
        }
    }
}
```
