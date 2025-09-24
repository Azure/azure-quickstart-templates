---
description: This template build demonstrates how to build Ready-To-Code Dev Box images using Azure Image Builder.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: devbox-ready-to-code-image
languages:
- bicep
- json
---
# Ready-To-Code Dev Box Images

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.devcenter/devbox-ready-to-code-image/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-ready-to-code-image%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.devcenter%2Fdevbox-ready-to-code-image%2Fazuredeploy.json)

This sample demonstrates building `Ready-To-Code` images containing everything a developer needs (configuration, source, packages, binaries) to minimize the time used for setting up a new Dev Box. The sample relies on Dev Box Image Template to provide flexible approach for building images using Azure Image Builder.

For more details see as well [Dev Box Ready-To-Code Dev Box images template](https://devblogs.microsoft.com/engineering-at-microsoft/dev-box-ready-to-code-dev-box-images-template/) blog post.

## Deployed Resources
The sample builds 3 images to demonstrate various configuration options of the Dev Box Image Template. For each image the template creates the following Azure resources:
- **Azure Image Builder Template**: the image factory used for building an image version.
- **Deployment Script**: that managed building of an image and reports results.
- **VM Image Definition**: where the final image is placed.

## Prerequisites
The sample requires the following Azure resources (defined in [prereq.main.bicep](./prereqs/prereq.main.bicep))
- **Builder Identity**: Azure User-Assigned Managed Identity used for deploying resources described above. In the sample for simplicity the identity is given `Contributor` access to the resource group where all resources are created. To better lock down the image building resources it is recommended configuring the identity with more scoped set of permissions, for example as described [here](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/image-builder#create-a-user-assigned-managed-identity-and-grant-permissions). Make sure to register Azure Resource Providers needed by `Azure Image Builder` as described [here](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/image-builder#register-the-providers).
- **Image Identity**: Azure User-Assigned Managed Identity used to clone repositories from private `Azure DevOps` projects during an image configuration, as well as to download packages for the repositories. GitHub repositories configured for an image are assumed to be public, as well as their packages.
- **Azure Compute Gallery**: where the Dev Box Image Template creates `VM Image Definitions` resources.

## Azure DevOps Image Building Pipeline
For users of `Azure DevOps` the sample provides [build_images.yml](./azuredevops/build_images.yml) pipeline definition to demonstrate end-to-end automated approach for building and updating Dev Box images.

While setting up the pipeline, create a new `Azure DevOps Service Connection` named `DevBoxReadyToCodeSampleConnection`, of type `Azure Resource Manager`, scope level `Subscription` and associate it the subscription and resource group containing the prerequisites described above as described [here](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops).

Define `PipelineVars_*` variables in the `# Required variables` section of [build_images.yml](./azuredevops/build_images.yml).

## Sample images
The sample includes the following demo images (named after the key git repositories they configure):
- [MSBuildSdks](./images/MSBuildSdks.bicep)
    - Simplest image definition that clones .NET repository https://github.com/microsoft/MSBuildSdks, restores packages for it and builds the repository.
- [eShop](./images/eShop.bicep)
    - Clones repositories https://github.com/dotnet/eShop and https://github.com/Azure-Samples/eShopOnAzure
    - Demonstrates usage of custom restore/build/test commands when configuring `Ready-To-Code` repository.
- [axios](./images/axios.bicep)
    - Installs for all users tools like Node.js and NPM packages.
    - installs for all users WinGet packages.
    - Clones repositories https://github.com/axios/axios and https://github.com/Azure/azure-quickstart-templates
    - Uses NPM to restore packages and build the `axios` repository.
    - Configures desktop shortcuts for the repositories.

In addition, all demo images automatically inherit the default functionality like the following from the Dev Box Image Template:
- Base image from [Azure Marketplace](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/microsoftvisualstudio.visualstudioplustools) with the latest Visual Studio 2022, Microsoft 365 Apps and many other useful developer tools.
- Chained (AKA base) images support is available.
- For better build performance [Dev Drive](https://devblogs.microsoft.com/engineering-at-microsoft/dev-drive-is-now-available/) is configured as drive Q: with all cloned repositories and their artifacts.
- Dev Box Image Template makes sure that tools like Visual Studio 2022. Visual Studio Code, SysInternals Suite, Git, Azure Artifacts Credential Provider, WinGet are installed and configured regardless of the base image selected.
- Smart defaults are applied for better developer scenarios performance.
- Latest Windows OS updates are installed.

Most of the template features are configured via its parameter, declared in module [devbox-image.bicep](./modules/devbox-image.bicep)

## How To Get Started?
To start exploring different configuration options of Dev Box Image Template, here are steps to build [sample images](#sample-images) in your own Azure subscription:
- Set up the [prerequisites](#prerequisites).
- Place the content of [azuredevops](./azuredevops/) directory into a new or existing repository.
- Set up the Azure DevOps [pipeline](#azure-devops-image-building-pipeline).
- Run the pipeline to produce the images.
- [Configure](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service) your `Dev Center` resources using the generated image(s).

## Repository Configuration
The most powerful feature of the Dev Box Image Template is the ability to configure `Ready-To-Code` git repositories. Each image definition can specify a custom set of properties for each repository using `repo` parameter. The following are the key supported properties:
- **Url**: Azure DevOps URL of the repository. This is the ONLY required property.
- **SourceControl**: The source control system of the repository. Allowed values `git|gvfs`. The default is `git`.
- **Branch**: when specified, the branch is checked out for the repo instead of the default one.
- **Commit**: when specified, the commit is fetched and checked out for a repo.
- **HistoryDepth**: Depth for git clone/fetch/pull operations. Setting to 0, which is the default, causes full repo history to be downloaded.
- **RecurseSubmodules** *(default: `false`)*: Whether to recurse into submodules when cloning the repo.
- **RepoRootWithoutDriveLetter**: By default a repo is cloned to `Q:\src\<repo-name>` (or `C:\src\<repo-name>`, if `createDevDrive` template property is set to `false`). Setting this property for example to `Sources` will clone the repo to `Q:\Sources`.
- **AvoidDevDrive**: Whether to clone the repo on the separate Dev Drive (doesn't apply if `createDevDrive` template property is set to `false`).
- **Kind** *(default: `Data`)*: Allowed values `MSBuild|Custom|Data`. Type of the build engine that suites best for the repo.
- **RestoreScriptEnvVars**: Key/value pairs representing environment variables to set temporarily while a repo is being 'warmed up', i.e. when for example its packages are being restored or it is being built.
- **RestoreScript**: Command to use during `restore` phase of repo configuration. When `Kind` is set to `MSBuild` then the default value is `msbuild /t:restore`.
- **AdditionalRepoFeeds**: List of additional Azure DevOps feed URLs that couldn't be discovered automatically by the template scripts.
- **CustomScript**: Only used for `Kind: Custom`. Passed to 'cmd.exe /c' for execution after the environment for restoring packages is configured.
- **PackagesFeed**: Only used for `Kind: Custom`. The feed that is used when restoring packages for the repo. The feed must be in Azure DevOps Nuget format even if Nuget packages are not used by the repo (for example when only NPM ones used). The feed will typically have multiple upstreams.
- **Build**
    - **Disable** (default: `false`): When set to `true`, the build phase of repo configuration will be skipped.
    - **InitBuildScript**: Custom batch script (potentially with arguments) used to initialize the build environment. By default Visual Studio's VsDevCmd.bat is used for MSBuild repos.
    - **AdditionalBuildArguments**: Additional command line arguments passed to the build engine.
    - **Dirs**: Comma separated list of sub directories in the repo to build. By default the whole repo is built from the root.
- **DesktopShortcutEnable** (default: `Kind != Data` ): Whether a desktop shortcut should be created for the repo? By default, a shortcut is created for all repo kinds except `Data`.
- **DesktopShortcutScriptPath**: Repo relative or absolute path to `.bat`, `.cmd` or `.ps1` file (without arguments) to use when creating a desktop shortcut for the repo. By default Visual Studio's VsDevCmd.bat is used for MSBuild repos.
- **DesktopShortcutRunAsAdmin** (default: `false`): Whether configure the repo shortcut to start as admin.
- **DesktopShortcutIconPath**: Optional relative or full icon path to be used for the shortcut. By default the icon is not set.
- **DesktopShortcutName**: Optional name of the shortcut.  By default the name is the repo is used.
- **EnableGitCommitGraph** (default: `true`): Generates a commit graph for faster git operations on large repos.

`Tags: DevCenter, Dev Box, ARM Template, Microsoft.DevCenter/devcenters, Azure Image Builder, Ready-To-Code`
