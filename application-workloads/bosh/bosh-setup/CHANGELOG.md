# v6.0.0 (2018-11-15)

- Upgrade Azure CPI version to v35.5.0. Please see new features in [bosh-azure-cpi-release v35.5.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.5.0)
  - Azure CPI v35.5.0 doesn't require the stemcell container to be public
- Use cf-deployment [6.0.0](https://github.com/cloudfoundry/cf-deployment/tree/v6.0.0)

# v5.0.0 (2018-08-31)

- Upgrade Azure CPI version to v35.4.0. Please see new features in [bosh-azure-cpi-release v35.4.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.4.0)
- Use cf-deployment [v4.0.0](https://github.com/cloudfoundry/cf-deployment/tree/v4.0.0)
- Bump bosh-deployment
- Use Azure Storage as blobstore in Azure Stack
- Bump bosh-cli to 5.1.2

# v4.1.0 (2018-08-02)

- Use cf-deployment [v3.0.0](https://github.com/cloudfoundry/cf-deployment/tree/v3.0.0)
- Update runtime-config for BOSH DNS
- Deploy UAA and credhub in BOSH director
- Use General Purpose v2 storage account
- Support ubuntu-xenial stemcell
- Add load balancing rule for UDP port for standard LB
- Use `Standard_D11_v2` for compilation VMs

# v4.0.0 (2018-06-23)

- Use cf-deployment [v2.2.0](https://github.com/cloudfoundry/cf-deployment/tree/v2.2.0)
- Use bosh-deployment [v1.0.0](https://github.com/cloudfoundry/bosh-deployment/tree/v1.0.0)
- Use standard load balancer by default
- Add a new parameter to specify cloud foundry system domain
- Use Azure CLI v2 when uploading artifacts in Azure China

# v3.10.0 (2018-06-13)

- Upgrade Azure CPI version to v35.3.0. Please see new features in [bosh-azure-cpi-release v35.3.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.3.0)
- Bump [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/tree/1102ce016d4772dcb69c26ae4f301e023503953b)
- Bump cf-deployment to [v1.40.0](https://github.com/cloudfoundry/cf-deployment/tree/v1.40.0)
- Use the ops file [use-external-blobstore.yml](https://raw.githubusercontent.com/cloudfoundry/cf-deployment/v2-fast/operations/use-external-blobstore.yml)
- Fixed the version of Azure CLI

# v3.9.0 (2018-05-26)

- Bump cf-deployment to [v1.36.0](https://github.com/cloudfoundry/cf-deployment/tree/v1.36.0)
- Update the signing key for installing azure-cli
- Use compiled packages for Azure China Cloud

# v3.8.0 (2018-05-14)

- Bump cf-deployment to [v1.31.0](https://github.com/cloudfoundry/cf-deployment/tree/v1.31.0)
- Redirect the logs to both `~/install.log` and standard output.

# v3.7.0 (2018-05-01)

- Upgrade Azure CPI version to v35.2.0. Please see new features in [bosh-azure-cpi-release v35.2.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.2.0)
- Bump cf-deployment to [v1.27.0](https://github.com/cloudfoundry/cf-deployment/tree/v1.27.0)
- Add `AzureChinaCloudAD` as AzureStack authentication
- Use Azure CLI to prepare the storage account. Now the template doesn't depend on any python packages.

# v3.6.0 (2018-04-02)

- Bump [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/tree/b848368815a2c81c59c8710850e7b56bc4649152)
- Bump cf-deployment to [v1.23.0](https://github.com/cloudfoundry/cf-deployment/tree/v1.23.0)
  - Bump stemcell to `3541.10`
- Enable `keep_unreachable_vms` and `keep_failed_vms` by default

# v3.5.0 (2018-03-05)

- Upgrade Azure CPI version to v35.1.0. Please see new features in [bosh-azure-cpi-release v35.1.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.1.0)
- Bump [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/tree/5360bcf33409007c85e8b46d4ad0ab0535e3bb5b)
  - Bump director's additional disk
- Bump cf-deployment to [v1.16.0](https://github.com/cloudfoundry/cf-deployment/tree/v1.16.0)
  - Bump stemcell to `3541.5`
  - Bump bosh-cli to `2.0.48`
  - Bump cf-cli to `6.34.1`
- Use compiled releases for cf-deployment

# v3.4.0 (2018-01-30)

- Bump cf-deployment to [`v1.9.0`](https://github.com/cloudfoundry/cf-deployment/tree/v1.9.0).
- Bump bosh release to `264.7.0`
- Bump stemcell in bosh-deployment to `3468.21`
- Bump stemcell in cf-deployment to `3468.19`

# v3.3.0 (2018-01-09)

- Upgrade Azure CPI version to v35.0.0. Please see new features in [bosh-azure-cpi-release v35.0.0](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v35.0.0)
- Bump cf-deployment to [`v1.6.0`](https://github.com/cloudfoundry/cf-deployment/tree/v1.6.0).
- Support [Availability Zones](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview).
- Set the default value of `autoDeployCloudFoundry` to `disabled`

# v3.2.0 (2017-12-20)

- Bump [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/218e6d5030d89ca9f31c50b8b308e2a78d2a0997/bosh.yml) and [cf-deployment](https://github.com/cloudfoundry/cf-deployment/blob/v1.4.0/cf-deployment.yml).
- Upgrade Azure CPI version to v34. Please see new features in [bosh-azure-cpi-release v34](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v34)

# v3.1.0 (2017-12-12)

- Bump [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/ad5e958d15973269345909349fc00378abae4ba7/bosh.yml) and [cf-deployment](https://github.com/cloudfoundry/cf-deployment/blob/v1.3.1/cf-deployment.yml).
- Upgrade Azure CPI version to v33 except AzureStack. Please see new features in [bosh-azure-cpi-release v33](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v33)

# v3.0.0 (2017-11-23)

- The template is using [BOSH CLI v2](https://bosh.io/docs/cli-v2.html), [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment/blob/cb8e7f60145738e103eb2dc0ad3372288986dc0c/bosh.yml) and [cf-deployment](https://github.com/cloudfoundry/cf-deployment/blob/v1.0.0/cf-deployment.yml).
- Upgrade Azure CPI version to v29. Please see new features in [bosh-azure-cpi-release v29](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v29)

# v2.8.0 (2017-8-11)

- Upgrade Azure CPI version to v26. Please see new features in [bosh-azure-cpi-release v26](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v26)
- Correct the range of CloudFoundry subnet.

# v2.7.0 (2017-7-10)

- Upgrade Azure CPI version to v25. Please see new features in [bosh-azure-cpi-release v25](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v25)
- Support the deployment in AzureStackTP3.

# v2.6.1 (2017-6-2)

- Upgrade bosh to v262
- Upgrade bosh stemcell to v3421.3
- Add ssl cert & key for the director job
- Add `user_add` job to add a cpidebug user to the bosh director

# v2.6.0 (2017-5-15)

- Upgrade Azure CPI version to v24. Please see new features in [bosh-azure-cpi-release v24](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v24)
- Upgrade bosh stemcell to v3363.22
- Change the account type of the default storage account to `Standard_LRS`.

# v2.5.0 (2017-3-20)

- Support AzureGermanCloud
- Upgrade Azure CPI version to v22. Please see new features in [bosh-azure-cpi-release v22](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v22)

# v2.4.4 (2017-02-10)

- On AzureChinaCloud, set PowerDNS server on BOSH VM as DNS server. For *.{cf-ip}.xip.io, PowerDNS server will respond without querying Azure DNS. For the real domains and *.{other-ip-other-than-cf-ip}.xip.io, PowerDNS server will go to Azure DNS at the first time, and cache the resolving result.

# v2.4.3 (2017-02-08)

- Use Azure blob storage as blobstore by default
- Upgrade bosh to v260.5
- Upgrade cf-cli to v6.23.1

# v2.4.2 (2017-01-10)

- Upgrade cf-release to v250
- Upgrade bosh stemcell to v3312.12
- Fix issue https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues/235

# v2.4.0 (2016-12-21)

- Upgrade Azure CPI version to v20. Please see new features in [bosh-azure-cpi-release v20](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v20)
- Use Azure DNS instead of CNNIC DNS for AzureChinaCloud

# v2.3.0 (2016-11-22)

- Upgrade cf-release to v244 for template of multiple-vm-cf.yml, keep cf-release v238 as a stable version for single-vm-cf.yml.
- Use stubs to generate manifest for multiple-vm-cf.yml.
- Add a scripts to generate certifications and passwords for manifests.

# v2.2.0 (2016-11-09)

- Support AzureUSGovernment
- Upgrade Azure CPI version to v19. Please see new features in [bosh-azure-cpi-release v19](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v19).

# v2.1.1 (2016-10-20)

- Upgrade CustomScript to 2.0
- Add a retry logic for uploading stemcell and release
- Use https for the mirror site
- Bug fixes
  - Install prerequisites at the beginning to avoid a silent error when install msrest

# v2.1.0 (2016-10-11)

- Upgrade versions
  - Upgrade Azure CPI version to v17. Please see new features in [bosh-azure-cpi-release v17](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v17).

# v2.0.2 (2016-09-29)

- Uses local pip repo for AzureChinaCloud to install pip packages

# v2.0.1 (2016-08-24)

- Expose the VM size of BOSH VM as a parameter

# v2.0.0 (2016-08-16)

- Upgrade versions
  - Upgrade Azure CPI version to v14. Please see new features in [bosh-azure-cpi-release v14](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v14).
  - Upgrade bosh version to 257.3
  - Upgrade bosh stemcell to version 3262.7
- Bug fixes
  - Fix bugs when passing client_secret
- Improvements
  - Provide version control for the scripts and manifests in AzureChinaCloud

# v1.9.1 (2016-08-08)

- Use CustomData to pass information to CustomScript

# v1.9.0 (2016-08-01)

- Enable diego by default on the manifests
  - diego version: 0.1476.0
  - garden-linux version: 0.338.0
  - cflinuxfs2-rootfs: 1.16.0

# v1.8.3 (2016-07-19)

- Add --sha1 for bosh upload command (stemcell && CF release)
- Switch to mirror.azure.cn to download releases and stemcells in AzureChinaCloud
- Write more logs to install.log in dev-box

# v1.8.2 (2016-07-18)

- Add powerdns in bosh.yml

# v1.8.1 (2016-07-11)

- Generate strong passwords for bosh.yml
- Add a prompt to input the password for Cloud Foundry manifests

# v1.8.0 (2016-07-06)

- Upgrade cf-release to v238
- Upgrade bosh stemcell to version 3232.11

# v1.7.0 (2016-06-23)

- Upgrade versions
  - Upgrade Azure CPI version to v13. Please see new features in [bosh-azure-cpi-release v13](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v13).
- Add a secondary DNS server

# v1.6.1 (2016-06-16)

- Fix the timeout issue of "pip install" in China
- Add the acceptance test and smoke test for Cloud Foundry

# v1.6.0 (2016-06-08)

- Upgrade versions
  - Upgrade Azure CPI version to v12. Please see new features in [bosh-azure-cpi-release v12](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v12).
- Disable snapshot by default.

# v1.5.0 (2016-05-23)

- Upgrade versions
  - Upgrade Azure CPI version to v11. Please see new features in [bosh-azure-cpi-release v11](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v11).
- Fix https://github.com/Azure/azure-quickstart-templates/issues/1958.

# v1.4.2 (2016-05-06)

- Upgrade versions
  - Upgrade bosh version to 256.2
- Remove redis from bosh.yml as of bosh v256+

# v1.4.1 (2016-04-28)

- Add a retry for apt-get update
- Add https://gems.ruby-china.org/ as a gem source

# v1.4.0 (2016-04-21)

- Add AzureChinaCloud support
- Upgrade versions
  - Upgrade Azure CPI version to v10. Please see new features in [bosh-azure-cpi-release v10](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v10).

# v1.3.0 (2016-04-01)
- Does not bind network security groups to subnets but bind network security groups to VMs.
- Upgrade versions
  - Upgrade Azure CPI version to v9. Please see new features in [bosh-azure-cpi-release v9](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v9).

# v1.2.0 (2016-03-28)
- Add a subnet for Diego
- Create network security groups for all subnets
- Upgrade versions
  - Upgrade Azure CPI version to v8. Please see new features in [bosh-azure-cpi-release v8](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/releases/tag/v8).

# v1.1.3 (2016-03-08)
- Upgrade versions
  - Upgrade bosh version to 255.3
  - Upgrade cf version to 231

# v1.1.2 (2016-03-01)
- Change the default value of "autoDeployBosh" to "enabled"
- Run "apt-get update" at the beginning of "setup_env"

# v1.1.1 (2016-02-23)
- Upgrade versions
  - Upgrade bosh version to 255.1

# v1.1 (2016-02-13)
- New features
  - Support deploying Bosh automatically
- Parameters and Variables
  - Remove the parameter "newStorageAccountName" and generate it by uniqueString()
  - Create the dev-box with SSH Keys
  - Make service principal parameters required and fixed-length
  - Move the parameter "vmSize" into a variable
  - Move the parameters about vnet & subnet to variables
  - Change the CIDR of the subnet for Cloud Foundry to /20
- Render the manifest of Bosh
  - Autofill the service principal
- Render the manifest of Cloud Foundry
  - Autofill the virtual network name, the subnet name and so on.
- Upgrade versions
  - Upgrade bosh_cli version to 1.3169.0
  - Upgrade bosh-init version to 0.0.81
  - Upgrade API version to the latest 2020-11-01
  - Upgrade to Ubuntu Server 14.04.3 LTS
  - Upgrade the default "storageAccountType" into Standard_RAGRS
  - Upgrade the version of CustomScript Extension to 1.4
    - Download the scripts and manifests via fileUris
    - Put commandToExecute into protectedSettings to protect users' credentials
- Add CI pipeline to test bosh-setup deployment

# v1.0 (2015-11-02) - GA Version

# Preview II Version (2015-08-25)

# Preview Version (2015-05-29)
