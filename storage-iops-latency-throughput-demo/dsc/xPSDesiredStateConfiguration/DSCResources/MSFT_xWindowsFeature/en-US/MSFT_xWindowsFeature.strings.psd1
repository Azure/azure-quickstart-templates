# Localized strings for MSFT_xWindowsFeature.psd1

ConvertFrom-StringData @'
    FeatureNotFoundError = The requested feature {0} could not be found on the target machine.
    MultipleFeatureInstancesError = Failure to get the requested feature {0} information from the target machine. Wildcard pattern is not supported in the feature name.
    FeatureInstallationFailureError = Failure to successfully install the feature {0} .
    FeatureUninstallationFailureError = Failure to successfully uninstall the feature {0} .
    QueryFeature = Querying for feature {0} using Server Manager cmdlet Get-WindowsFeature.
    InstallFeature = Trying to install feature {0} using Server Manager cmdlet Add-WindowsFeature.
    UninstallFeature = Trying to uninstall feature {0} using Server Manager cmdlet Remove-WindowsFeature.
    RestartNeeded = The Target machine needs to be restarted.
    GetTargetResourceStartMessage = Begin executing Get functionality on the {0} feature.
    GetTargetResourceEndMessage = End executing Get functionality on the {0} feature.
    SetTargetResourceStartMessage = Begin executing Set functionality on the {0} feature.
    SetTargetResourceEndMessage = End executing Set functionality on the {0} feature.
    TestTargetResourceStartMessage = Begin executing Test functionality on the {0} feature.
    TestTargetResourceEndMessage = End executing Test functionality on the {0} feature.
    ServerManagerModuleNotFoundMessage = ServerManager module is not installed on the machine.
    SkuNotSupported = Installing roles and features using PowerShell Desired State Configuration is supported only on Server SKU's. It is not supported on Client SKU.
    EnableServerManagerPSHCmdletsFeature = Windows Server 2008R2 Core operating system detected: ServerManager-PSH-Cmdlets feature has been enabled.
    UninstallSuccess = Successfully uninstalled the feature {0}.
    InstallSuccess = Successfully installed the feature {0}.
'@
