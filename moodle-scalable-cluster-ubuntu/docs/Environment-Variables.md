# Environment Variables

In order to configure our deployment and tools we'll set up some
environment variables to ensure consistency. If you are running these
scripts through SimDem you can customize these values by copying and
editing `env.json` into `env.local.json`.

We'll need a unique name for our Resource Group in Azure, but when
running in an automated mode it is useful to have a (mostly) unique
name for your deployment and related resources. We'll use a timestamp.
If the environmnt variable `MOODLE_RG_NAME` is not set we will
create a new value using a timestamp:


``` shell
if [ -z "$MOODLE_RG_NAME" ]; then MOODLE_RG_NAME=moodle_$(date +%Y-%m-%d-%H); fi
```

Other configurable values for our Azure deployment include the
location and depoloyment name. We'll standardize these, but you can
use different values if you like.

``` shell
MOODLE_RG_LOCATION=southcentralus
MOODLE_DEPLOYMENT_NAME=MasterDeploy
```

We also need to provide an SSH key. Later we'll generate this if it
doesn't already exist but to enable us to reuse an existing key we'll
store it's filename in an Environment Variable.

``` shell
MOODLE_SSH_KEY_FILENAME=~/.ssh/moodle_id_rsa
```

We need a workspace for storing configuration files and other
per-deployment artifacts:

``` shell
MOODLE_AZURE_WORKSPACE=~/.moodle
```

## Create Workspace

Ensure the workspace for this particular deployment exists:

```
mkdir -p $MOODLE_AZURE_WORKSPACE/$MOODLE_RG_NAME
```

## Validation

After working through this file there should be a number of
environment variables defined that will be used to provide a common
setup for all our Moodle on Azure work.

The resource group name defines the name of the group into which all
resources will be, or are, deployed. 

```bash
echo "Resource Group for deployment: $MOODLE_RG_NAME"
```

Results:

```
Resource Group for deployment: southcentralus
```

The resource group location is:

```bash
echo "Deployment location: $MOODLE_RG_LOCATION"
```

Results:

```
Deployment location: southcentralus
```

When deploying a Moodle cluster the deployment will be given a name so
that it can be identified later should it be neceessary to debug.


```bash
echo "Deployment name: $MOODLE_DEPLOYMENT_NAME"
```

Results:

```
Deployment name: MasterDeploy
```

The SSH key to use can be found in a file, if necessary this will be
created as part of these scripts.

``` shell
echo "SSH key filename: $MOODLE_SSH_KEY_FILENAME"
```

Results:

```
SSH key filename: ~/.ssh/moodle_id_rsa
```

Configuration files will be written to / read from a customer directory:

``` shell
echo "Workspace directory: $MOODLE_AZURE_WORKSPACE"
```

Results:

```
Workspace directory: ~/.moodle
```

Ensure the workspace directory exists:


``` bash
if [ ! -f "$MOODLE_AZURE_WORKSPACE/$MOODLE_RG_NAME" ]; then echo "Worspace exists"; fi
```

Results:

```
Workspace exists
```
