# Azure Resource Manager QuickStart Templates

This repo contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at [azure.com](https://azure.microsoft.com/en-us/documentation/templates/.)

See the [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md#contribution-guide) for how to use or contribute to this repo.

## NOTE

A draft of the new [**best practices document**](/1-CONTRIBUTION-GUIDE/best-practices.md) has been merged.

## Upcoming Changes

We are going to be making a few changes in the structure and practices of this repo over the next few months, including (but not limited to :wink:) the following:

- Restructure the samples into sub folders to remove the noise from the root (if you made it this far you know what I mean) and provide some clarity about the samples in the repo
- Include samples for QuickStarts as well as Azure Applications (managed and unmanaged)
- Provide samples for Azure Policy
- Merging best practices with the Azure marketplace (there are some contradictory practices in place today)
- Provide static analysis automation of templates (contributions welcome [here](https://github.com/Azure/arm-ttk/blob/master/README.md))
- Updating documentation to reflect these changes

## Why is this important

If you contribute to the repo, some practices will be changing and it will be important to follow the readme since many of the samples will be grandfathered into the old practices.  Also, if you consume the repo through the API the structure will be changing.  Today many callers assume a folder contains a sample, after the restructuring the metadata.json file will be the key to finding samples.  This is actually true today if you want to start updating your code.

## When

We want to give everyone notice of the changes so they will be slowly rolled out over the next few months.  We'll post more detailed dates once we have them.

### Final Note

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
