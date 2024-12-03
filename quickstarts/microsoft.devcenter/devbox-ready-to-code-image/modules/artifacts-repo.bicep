@description('C:\\ or Q:\\ - drive where by default cloned repos are placed')
param sourcesDriveRoot string

@description('Always "src" - root where by default cloned repos are placed, without drive letter and leading or trailing slashes')
param sourcesDirWithoutDriveLetter string

@description('C:\\ or Q:\\ - drive where by default cloned repos will be located when user logs in')
param shortcutDriveRoot string

@description('Always place the repo on NTFS - used when the repo doesn\'t support Dev Drive')
param avoidDevDrive bool

@description('Always C:\\ - drive where to clone a repo if the code drive should be avoided')
param ntfsDriveRoot string

@description('Repo root path without drive letter and leading or trailing slashes.')
param repoRootWithoutDriveLetter string

param repoUrl string

type SourceControl = 'git' | 'gvfs'

@description('The source control system of the repository.')
param repoSourceControl SourceControl

param repoBranch string
param repoCommit string
param restoreScriptEnvVars object
param restoreScript string
param additionalRepoFeeds array
param build object
param historyDepth int
param desktopShortcutEnable bool
param desktopShortcutScriptPath string
param desktopShortcutRunAsAdmin bool
param desktopShortcutIconPath string
param desktopShortcutName string
param recurseSubmodules bool
param enableGitCommitGraph bool
param sparseCheckoutFolders array

// Only used with Custom repo kind
param packagesFeed string
param customScript string

@description(''' Supported repository types:
  - MSBuild - Microsoft public build engine that is integrated with Nuget ecosystem.
  - Custom - any other build environment that doesn't fit into either of the two above.
  - Data - the repo should be simply cloned but no other processing for it is needed.
''')
@allowed(['MSBuild', 'Custom', 'Data'])
param repoKind string

var repoName = last(split(repoUrl, '/'))

var repoDriveRoot = avoidDevDrive ? ntfsDriveRoot : sourcesDriveRoot
var repoRootDir = empty(repoRootWithoutDriveLetter)
  ? '${repoDriveRoot}${sourcesDirWithoutDriveLetter}\\${repoName}'
  : '${repoDriveRoot}${repoRootWithoutDriveLetter}'

var repoShortcutDriveRoot = avoidDevDrive ? ntfsDriveRoot : shortcutDriveRoot
var repoShortcutDir = empty(repoRootWithoutDriveLetter)
  ? '${repoShortcutDriveRoot}${sourcesDirWithoutDriveLetter}\\${repoName}'
  : '${repoShortcutDriveRoot}${repoRootWithoutDriveLetter}'

var codeRepoArtifacts = [
  {
    name: 'windows-dotnetcore-sdk'
    parameters: {
      globalJsonFilePath: '${repoRootDir}\\global.json'
    }
  }
  {
    name: 'windows-install-dotnet-sdk'
    parameters: {
      globalJsonPath: '${repoRootDir}\\global.json'
    }
  }
]

var setTempEnvVars = [
  for envVar in items(restoreScriptEnvVars): {
    name: 'windows-setenvvar'
    parameters: {
      Variable: envVar.key
      Value: envVar.value
      PrintValue: 'true'
    }
  }
]

var unsetTempEnvVars = [
  for envVar in items(restoreScriptEnvVars): {
    name: 'windows-unsetenvvar'
    parameters: {
      Variable: envVar.key
    }
  }
]

module msbuildRepo 'artifacts-packages-restore.bicep' = if (repoKind == 'MSBuild') {
  name: 'msbuildRepo-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    repoRootDir: repoRootDir
    restoreScript: restoreScript
  }
}

module customBuildRepo 'artifacts-custom-build-env.bicep' = if (repoKind == 'Custom') {
  name: 'customBuildRepo-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    repoRootDir: repoRootDir
    packagesFeed: packagesFeed
    additionalRepoFeeds: additionalRepoFeeds
    customScript: customScript
  }
}

var cloneSubmodulesArg = recurseSubmodules ? '--recurse-submodules --shallow-submodules' : ''
// Provide consistent user experience for branches in cloned repos with --no-single-branch, regardless of whether --depth is used
var optionalCloningParameters = historyDepth > 0
  ? '--depth ${historyDepth} --no-single-branch --no-tags ${cloneSubmodulesArg}'
  : '${cloneSubmodulesArg}'

var fetchSubmodulesArg = recurseSubmodules ? '--recurse-submodules' : ''
// Do not limit the number of commits to pull for repos that were cloned with limited history to avoid 'fatal: refusing to merge unrelated histories'
var optionalFetchParameters = historyDepth > 0 ? '--no-tags ${fetchSubmodulesArg}' : '${fetchSubmodulesArg}'

var syncRepo = {
  name: 'windows-clone-update-repo'
  parameters: union(
    {
      RepoUrl: repoUrl
      Repository_SourceControl: repoSourceControl
      Repository_TargetDirectory: repoRootDir
      Repository_cloneIfNotExists: 'true'
      Repository_optionalCloningParameters: optionalCloningParameters
      Repository_optionalFetchParameters: optionalFetchParameters
      CommitId: !empty(repoCommit) ? repoCommit : 'latest'
      EnableGitCommitGraph: enableGitCommitGraph
    },
    !empty(repoBranch) ? { BranchName: repoBranch } : {},
    !empty(sparseCheckoutFolders) ? { SparseCheckoutFolders: join(sparseCheckoutFolders, ',') } : {}
  )
}

var buildRepoArtifact = (repoKind == 'MSBuild') && ((!contains(build, 'Disable')) || (!build.Disable))
  ? [
      {
        name: 'windows-build-repo'
        parameters: union(
          {
            RepoRoot: repoRootDir
          },
          !empty(additionalRepoFeeds) ? { AdditionalRepoFeeds: join(additionalRepoFeeds, ',') } : {},
          contains(build, 'InitBuildScript') ? { InitBuildScript: build.InitBuildScript } : {},
          contains(build, 'RunBuildScript') ? { RunBuildScript: build.RunBuildScript } : {},
          contains(build, 'AdditionalBuildArguments')
            ? { AdditionalBuildArguments: build.AdditionalBuildArguments }
            : {},
          contains(build, 'Dirs') ? { Dirs: join(build.Dirs, ',') } : {}
        )
      }
    ]
  : []

var createDevEnvShortCut = [
  {
    name: 'windows-create-devenv-shortcut'
    parameters: union(
      {
        RepoRoot: repoShortcutDir
        RepoKind: repoKind
        ShortcutRunAsAdmin: desktopShortcutRunAsAdmin
      },
      !empty(desktopShortcutScriptPath) ? { DesktopShortcutScriptPath: desktopShortcutScriptPath } : {},
      !empty(desktopShortcutIconPath) ? { DesktopShortcutIconPath: desktopShortcutIconPath } : {},
      !empty(desktopShortcutName) ? { DesktopShortcutName: desktopShortcutName } : {}
    )
  }
]
output setupSources array = [syncRepo]

output warmup array = concat(
  (repoKind == 'MSBuild') ? codeRepoArtifacts : [],
  setTempEnvVars,
  repoKind == 'MSBuild' ? msbuildRepo.outputs.artifacts : [],
  desktopShortcutEnable ? createDevEnvShortCut : [],
  repoKind == 'Custom' ? customBuildRepo.outputs.artifacts : [],
  buildRepoArtifact,
  unsetTempEnvVars
)
