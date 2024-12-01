param repoRootDir string
param restoreScript string

var restorePackages = [
  {
    name: 'windows-msbuild-env-invokecommand'
    parameters: {
      RepoRoot: repoRootDir
      Script: empty(restoreScript) ? 'msbuild /t:restore' : restoreScript
    }
  }
]

output artifacts array = restorePackages
