param toolsRoot string
param sourcesDriveRoot string
param defenderExclusions bool
param userDefenderExclusions array
param defenderExclusionPathList string
param allParamsForLogging object
param credentialProvider object
param osDriveMinSizeGB int
param disableAllDiskWriteCacheFlushing bool
param installLatestWinGet bool

@description('This will create a separate volume, format it with Dev Drive and place all repos and caches to that volume. Requires October 2023 patched Win11-22H2 or Win11-23H2 base image.')
param createDevDrive bool

param devDriveOptions object = {}

var updateWindowsArtifact = {
  name: 'WindowsUpdate'
}

var defaultDevDriveOptions = {
  // Whether to enable the PrjFlt minifilter on the Dev Drive. This slows down the
  // Dev Drive but allows enlisting repos that use GVFS/VFSForGit.
  EnableGVFS: false

  // Whether to enable filesystem minifilters that support mounting Windows containers
  // on the Dev Drive. This slows down the Dev Drive.
  EnableContainers: false
}
// Fill in missing Dev Drive config values with defaults.
var devDriveWithDefaults = union(defaultDevDriveOptions, devDriveOptions)

var optionalSetDevDriveConfiguration = createDevDrive && (devDriveWithDefaults.EnableGVFS || devDriveWithDefaults.EnableContainers)
  ? [
      {
        name: 'windows-set-DevDriveConfiguration'
        parameters: {
          EnableGVFS: devDriveWithDefaults.EnableGVFS
          EnableContainers: devDriveWithDefaults.EnableContainers
        }
      }
    ]
  : []

var optionalInstallLatestWinGet = installLatestWinGet
  ? [
      {
        name: 'windows-install-winget'
      }
    ]
  : []

var optionalConfigureWinGetForUser = installLatestWinGet
  ? [
      {
        Task: 'configure-winget'
      }
    ]
  : []

var runBeforeAll = concat(
  [
    {
      // Resize drive C: to the maximum possible size
      name: 'windows-expandOSdisk'
    }
  ],

  [
    // Fetch all updates before pulling anything else on the box. If needed, the VM will be automatically restarted after updates are installed.
    updateWindowsArtifact
  ],

  optionalSetDevDriveConfiguration,

  optionalInstallLatestWinGet,

  [
    {
      // Disable 'Reserved Storage' Windows feature that intends to help 'Windows Update' to reserve enough disk space and improve its reliability.
      // This operation showed to cost about 15-20 minutes of disk I/O in some cases.
      // Given that DevBox is supposed to be used as an ephemeral VM, it is OK to disable this feature and get VM creation time down
      name: 'windows-disable-reservedstorage'
    }
    {
      // Enable and disable setting in Windows update.
      name: 'windows-update-settings'
    }
    {
      // Enable curl retries for the image build user to improve artifact install resilience. File is written to C:\Users\packer\.curlrc and cleaned up automatically during sysprep.
      Name: 'windows-powershell-invokecommand'
      Parameters: {
        Script: 'Set-Content -Path `$env:USERPROFILE\\.curlrc -Value `"--retry 7`"; Get-Content -Path `$env:USERPROFILE\\.curlrc'
      }
    }
    {
      Name: 'windows-enable-long-paths'
    }
    {
      // Reboot after long path registry update
      Name: 'WindowsRestart'
    }
  ]
)

var optionalCreateDevDrive = createDevDrive
  ? [
      {
        // Create Dev Drive volume before installing anything else.
        Name: 'windows-create-ReFS'
        Parameters: {
          DevBoxRefsDrive: substring(sourcesDriveRoot, 0, 1)
          OsDriveMinSizeGB: osDriveMinSizeGB
          IsDevDrive: createDevDrive
        }
      }
    ]
  : []

var optionalDisableAllDiskWriteCacheFlushing = disableAllDiskWriteCacheFlushing
  ? [
      {
        Name: 'windows-disable-write-cache-flushing'
      }
    ]
  : []

var runInstalls = [
  {
    // Install git and configure 'manager-core' as system credential.helper
    name: 'windows-gitinstall'
    parameters: {
      SetCredHelper: 'true'
    }
  }
  {
    // Consumed by many tools, e.g. MSBuild, dotnet, and NuGet (https://github.com/Microsoft/artifacts-credprovider)
    name: 'windows-install-artifacts-credprovider'
    parameters: {
      addNetFx: 'true'
      installNet6: credentialProvider.installNet6
      version: credentialProvider.version
      optionalCopyNugetPluginsRoot: toolsRoot
    }
  }
]

var optionalDefenderExclusions = defenderExclusions
  ? [
      {
        name: 'windows-defender-exclusions'
        parameters: {
          ExclusionPaths: defenderExclusionPathList
        }
      }
    ]
  : []

var userDefenderTaskId = uniqueString(reduce(userDefenderExclusions, '', (cur, next) => '${cur}${next}'))
var userDefenderLogonTasks = empty(userDefenderExclusions)
  ? []
  : [
      {
        Task: 'add-defender-exclusions'
        UniqueID: 'defender-exclusions-${userDefenderTaskId}'
        Parameters: {
          DirsToExclude: userDefenderExclusions
        }
      }
    ]

// While creating Dev Drive, unallocated partition may get created if the image disk size is smaller
// than the storage assigned for Dev Box definition that is using the image.
// On first user logon this script will assign any unallocated space to last partition D on that VM.
var codeDriveUserLogonTasksAssignUnallocatedSpaceAndReassignDriveLetter = createDevDrive
  ? [
      {
        Task: 'assign-unallocated-space'
        Parameters: {
          DriveLetter: 'D'
        }
      }
      {
        // CloudPC will reassign the Dev Drive code drive to D:, remap to the drive letter
        // originally used for repo enlistments to preserve build caches and build outputs
        // that rely on full paths.
        Task: 'remap-code-drive'
        Parameters: {
          ToDriveLetter: substring(sourcesDriveRoot, 0, 1)
        }
      }
    ]
  : []

var addUserProfileDefenderExclusionsTask = defenderExclusions
  ? [
      {
        Task: 'add-defender-exclusions'
        UniqueID: 'defender-exclusions-msbuild'
        Parameters: {
          DirsToExclude: [
            '%TEMP%\\NuGetScratch'
            '%TEMP%\\MSBuildTemp%USERNAME%'
          ]
        }
      }
    ]
  : []

var firstLogonTasks = concat(
  // Make code drive ready first to allow other steps to access it if needed
  codeDriveUserLogonTasksAssignUnallocatedSpaceAndReassignDriveLetter,
  userDefenderLogonTasks,
  addUserProfileDefenderExclusionsTask,
  optionalConfigureWinGetForUser
)

// Desktop sync is disabled by default because when multiple Dev Box VMs are used, OneDrive synchronizes its content b/w all of them.
// This can cause having multiple copies of a shortcut or a file on desktop when they are created by an app installer or build env init scripts.
var disableOneDriveDesktopSync = [{ name: 'windows-configure-onedrive-sync' }]

var runAfterAll = concat(
  [
    {
      // Write image build information to file on the VM desktop and json in .tools folder
      name: 'windows-imagelog'
      Parameters: {
        BicepInfo: base64(string(allParamsForLogging))
      }
    }
    {
      // Enable Virtual Machine Platform feature.
      // Script suppresses reboot which is ok as this will be done later in the image capture anyway.
      // This change should reduce VM provisioning time on the image by 3 mins on avg and upto 10 mins at P99
      // by reducing the need to enable the feature and reboot.
      name: 'windows-enable-optionalfeatures'
      Parameters: {
        FeatureName: 'VirtualMachinePlatform'
      }
    }
    {
      name: 'windows-configure-user-tasks'
      parameters: {
        FirstLogonTasksBase64: base64(string(firstLogonTasks))
      }
    }
    // Fetch any updates that could be available for the installed software. If needed, the VM will be automatically restarted after updates are installed.
    updateWindowsArtifact
  ],
  // Run as late as possible in case there were any OneDrive updates installed that could have re-enabled OneDrive Desktop Sync
  disableOneDriveDesktopSync,
  [
    {
      Name: 'WindowsRestart'
    }
    {
      name: 'windows-prepare-for-sysprep'
    }
  ]
)

output artifacts object = {
  runBeforeAll: runBeforeAll
  optionalCreateDevDrive: optionalCreateDevDrive
  optionalDisableAllDiskWriteCacheFlushing: optionalDisableAllDiskWriteCacheFlushing
  runInstalls: runInstalls
  optionalDefenderExclusions: optionalDefenderExclusions
  runAfterAll: runAfterAll
}
