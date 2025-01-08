#ChangeLog

# v1.1.0 (2018-10-14)
- Upgrade Azure CPI version to v35.4.0. Please see new features in [bosh-azure-cpi-release v35.4.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.4.0)
- Support AzureChinaCloud
- Bump bosh-cli to 5.1.2

# v1.0.4 (2018-06-21)
- Support deploy concourse automatically
- Upgrade versions
    - Upgrade Bosh version to 265.2.0, with manifest files changed
    - Upgrade Concourse version to 3.12.0, with manifest files changed
    - Upgrade Azure CPI version to 35.0.0, with manifest files changed

# v1.0.3 (2017-01-15)
- Updated bosh release, stemcells, azure cpi to latest version
- Updated concourse release and garden-runc
- Previous 1.0.2 no longer worked. Used azure-quickstart-templates/bosh setup as template for changes to scripts and manifests
- Added randomized passwords in bosh.yml

# v1.0.2 (2016-08-11)
- Use CustomData to pass information to CustomScript

# v1.0.1 (2016-08-04)
- Add concourse worker disk size options

# v1.0.0 (2016-07-05)
- Improve deployment routine for Concourse 
- Upgrade versions
    - Upgrade Bosh-init version to 0.95
    - Upgrade Bosh version to 257.1
    - Upgrade stemcell version to 3232.5
	- Upgrade Azure CPI version to v13, with manifest files changed
	- Upgrade Concourse version to 1.3.0, with manifest files changed to Bosh Manifest V2
- Adjust project structure

# Preview Version (2016-04-20)
