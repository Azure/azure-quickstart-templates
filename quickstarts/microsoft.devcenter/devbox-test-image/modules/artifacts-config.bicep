param imageBuildProfile object
param createSeparateSourcesDrive bool

// Always use the upper case letter because this is how it shows up in paths when Windows file system is enumerated.
// Some case-sensitive tools care about the drive latter case even on Windows (for example git.exe when looking for safe.directory match)
param ntfsDriveRoot string = 'C:\\'
param sourcesDriveRoot string = createSeparateSourcesDrive ? 'Q:\\' : ntfsDriveRoot

var sourcesDirWithoutDriveLetter = 'src'
var sourcesDir = '${sourcesDriveRoot}${sourcesDirWithoutDriveLetter}'

var shortcutDriveRoot = sourcesDriveRoot

output ntfsDriveRoot string = ntfsDriveRoot
output sourcesDriveRoot string = sourcesDriveRoot
output shortcutDriveRoot string = shortcutDriveRoot

output sourcesDirWithoutDriveLetter string = sourcesDirWithoutDriveLetter

output defenderExclusionPathList string = sourcesDir

output ntfsSourcesDirExclusionPath string = '${ntfsDriveRoot}${sourcesDirWithoutDriveLetter}'

// Location for tools and caches redirected from various places under %USERPROFILE% so they can be used by the end user.
output toolsRoot string = '${sourcesDriveRoot}.tools'

output baseImageFull string = '/MicrosoftVisualStudio/visualstudioplustools/vs-2022-ent-general-win11-m365-gen2/latest'

var defaultImageBuildProfile = {
  diskSize: 512
}

output imageBuildProfile object = union(defaultImageBuildProfile, imageBuildProfile)
