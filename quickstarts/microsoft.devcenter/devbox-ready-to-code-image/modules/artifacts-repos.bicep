param ntfsDriveRoot string
param sourcesDriveRoot string
param sourcesDirWithoutDriveLetter string
param shortcutDriveRoot string
param toolsRoot string
param credentialProvider object
param repos array = []

var reposWithDefaults = [
  for repo in repos: {
    Url: repo.Url

    // If SourceControl is not specified, default to git
    SourceControl: repo.?SourceControl ?? 'git'

    Branch: repo.?Branch ?? ''
    Commit: repo.?Commit ?? ''
    Kind: repo.?Kind ?? 'Data'
    RestoreScriptEnvVars: repo.?RestoreScriptEnvVars ?? {}
    RestoreScript: repo.?RestoreScript ?? ''
    AdditionalRepoFeeds: repo.?AdditionalRepoFeeds ?? []
    Build: repo.?Build ?? {}
    HistoryDepth: repo.?HistoryDepth ?? 0
    DesktopShortcutEnableStr: contains(repo, 'DesktopShortcutEnable') ? '${repo.DesktopShortcutEnable}' : ''
    DesktopShortcutScriptPath: repo.?DesktopShortcutScriptPath ?? ''
    DesktopShortcutRunAsAdmin: repo.?DesktopShortcutRunAsAdmin ?? false
    DesktopShortcutIconPath: repo.?DesktopShortcutIconPath ?? ''
    DesktopShortcutName: repo.?DesktopShortcutName ?? ''
    EnableGitCommitGraph: repo.?EnableGitCommitGraph ?? true
    SparseCheckoutFolders: repo.?SparseCheckoutFolders ?? []
    RecurseSubmodules: repo.?RecurseSubmodules ?? false

    // Allow controlling whether to place the repo on a separate DevDrive, if it is created for the image. 
    AvoidDevDrive: repo.?AvoidDevDrive ?? false

    // Allow selecting custom directory for the repo root. Useful when hitting max path issues with the default root path.
    RepoRootWithoutDriveLetter: repo.?RepoRootWithoutDriveLetter ?? ''

    // Only used with Custom repo kind
    CustomScript: repo.?CustomScript ?? ''
    PackagesFeed: repo.?PackagesFeed ?? ''
  }
]

module modules 'artifacts-repo.bicep' = [
  for (repo, i) in reposWithDefaults: {
    name: 'artifacts-repo-${i}-${uniqueString(deployment().name, resourceGroup().name)}'
    params: {
      sourcesDriveRoot: sourcesDriveRoot
      sourcesDirWithoutDriveLetter: sourcesDirWithoutDriveLetter
      shortcutDriveRoot: shortcutDriveRoot

      ntfsDriveRoot: ntfsDriveRoot
      avoidDevDrive: repo.AvoidDevDrive
      repoRootWithoutDriveLetter: repo.RepoRootWithoutDriveLetter

      repoUrl: repo.Url
      repoSourceControl: repo.SourceControl
      repoBranch: repo.Branch
      repoCommit: repo.Commit
      repoKind: repo.Kind
      customScript: repo.CustomScript
      restoreScriptEnvVars: repo.RestoreScriptEnvVars
      restoreScript: repo.RestoreScript
      packagesFeed: repo.PackagesFeed
      additionalRepoFeeds: repo.AdditionalRepoFeeds
      build: repo.Build
      historyDepth: repo.HistoryDepth
      // By default, enable desktop shortcut for all repos except Data
      desktopShortcutEnable: empty(repo.DesktopShortcutEnableStr)
        ? repo.Kind != 'Data'
        : bool(repo.DesktopShortcutEnableStr)
      desktopShortcutScriptPath: repo.DesktopShortcutScriptPath
      desktopShortcutRunAsAdmin: repo.DesktopShortcutRunAsAdmin
      desktopShortcutIconPath: repo.DesktopShortcutIconPath
      desktopShortcutName: repo.DesktopShortcutName
      enableGitCommitGraph: repo.EnableGitCommitGraph
      recurseSubmodules: repo.RecurseSubmodules
      sparseCheckoutFolders: repo.SparseCheckoutFolders
    }
  }
]

output repoSetupSourcesObjects array = [
  for i in range(0, length(repos)): {
    Artifacts: modules[i].outputs.setupSources
  }
]

output repoWarmupObjects array = [
  for i in range(0, length(repos)): {
    Artifacts: modules[i].outputs.warmup
  }
]

module packagesConfig 'artifacts-packages-config.bicep' = {
  name: 'packagesConfig-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    toolsRoot: toolsRoot
    credentialProvider: credentialProvider
  }
}

output commonArtifacts array = packagesConfig.outputs.setStableEnvVars

var avoidDevDriveRepos = filter(reposWithDefaults, repo => repo.AvoidDevDrive == true)
output anyAvoidDevDriveRepos bool = (length(avoidDevDriveRepos) > 0)
