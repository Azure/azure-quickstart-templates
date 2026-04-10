param devTools object
param imageContainsLatestVisualStudio bool

// Artifacts that are typically installed only on the base image
output installOnce array = concat(
  [
    {
      name: 'windows-vscodeinstall'
    }
    {
      // Install Sysinternals Suite to c:\.tools directory and add Shortcuts to desktop
      name: 'windows-sysinternals-suite'
      Parameters: {
        AddShortcuts: true
      }
    }
  ],

  // Make sure the latest Visual Studio is always present on the resulting image
  (devTools.AlwaysInstallVisualStudio || (!imageContainsLatestVisualStudio))
    ? [
        {
          Name: 'windows-visualstudio-bootstrapper'
          Parameters: union(
            {
              Workloads: devTools.VisualStudioWorkloads
              SKU: devTools.VisualStudioSKU
              VSBootstrapperURL: devTools.VisualStudioBootstrapperURL
            },
            !empty(devTools.?VisualStudioInstallationDirectory)
              ? { InstallationDirectory: devTools.VisualStudioInstallationDirectory }
              : {}
          )
        }
        // Installing a VC package by VS may require a reboot in which case VSIXInstaller would start failing with SoftRebootStatusCheck. Proactively reboot after running any VS setup.
        {
          name: 'WindowsRestart'
        }
      ]
    : []
)
