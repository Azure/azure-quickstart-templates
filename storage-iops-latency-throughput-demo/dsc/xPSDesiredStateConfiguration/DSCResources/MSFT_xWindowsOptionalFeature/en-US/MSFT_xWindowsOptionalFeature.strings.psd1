# Localized resources for xWindowsOptionalFeature

ConvertFrom-StringData @'
    DismNotAvailable = PowerShell module DISM could not be imported.
    NotSupportedSku = This resource is available only on Windows client operating systems and Windows Server 2012 or later.
    ElevationRequired = This resource must run as an Administrator.
    ValidatingPrerequisites = Validating resource prerequisites...
    CouldNotConvertFeatureState = Could not convert feature state '{0}' into Absent or Present.
    RestartNeeded = Target machine needs to restart.
    GetTargetResourceStartMessage = Started Get-TargetResource on the {0} feature.
    GetTargetResourceEndMessage = Finished Get-TargetResource on the {0} feature.
    SetTargetResourceStartMessage = Started Set-TargetResource on the {0} feature.
    SetTargetResourceEndMessage = Finished Set-TargetResource on the {0} feature.
    TestTargetResourceStartMessage = Started Test-TargetResource on the {0} feature.
    TestTargetResourceEndMessage = Finished Test-TargetResource on the {0} feature.
    FeatureInstalled = Installed feature {0}.
    FeatureUninstalled = Uninstalled feature {0}.
    ShouldProcessEnableFeature = Enable Windows optional feature
    ShouldProcessDisableFeature = Disable Windows optional feature
'@
