param repoRootDir string
param packagesFeed string
param additionalRepoFeeds array
param customScript string

output artifacts array = [
  {
    name: 'windows-custom-build-env-invokecommand'
    parameters: union(
      {
        RepoRoot: repoRootDir
        RepoPackagesFeed: packagesFeed
        Script: customScript
      },
      !empty(additionalRepoFeeds)
        ? {
            AdditionalRepoFeeds: join(additionalRepoFeeds, ',')
          }
        : {}
    )
  }
]
