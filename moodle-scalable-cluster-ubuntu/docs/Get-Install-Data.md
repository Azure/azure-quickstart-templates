# Retrieve essential install details

Once a deployment has completed the ARM template will output some
values that you will need for managing your Moodle instalation. These
are available in the portal, but in this document we will retrieve
them using the AZ command line tools and through the AZ CLI tool. This
document describes the available parameters and how to retrieve them.

## Prerequisites

In order to configure our deployment and tools we'll set up some
[environment variables](./Environment-Variables.md) to ensure consistency.

## Output Paramater Overview

The available output parameters are:

  - **siteURL**: If you provided a `siteURL` parameter when deploying this
    will be set to the supplied value. Otherwise it will be the same as
    the loadBalancerDNS, see below.
  - **loadBalancerDNS**: This is the DNS name of your application load
    balancer. If you provided a `siteURL` parameter when deploying
    you'll need to add a DNS entry to its CNAMEs pointing to this address.
  - **moodleAdminPassword**: The generated password for the "admin" user
    in your Moodle install.
  - **controllerInstanceIP**: This is the IP address of the controller
    Virtual Machine. You will need to SSH into this to make changes to
    your Moodle code or view logs.
  - **databaseDNS**: This is the public DNS of your database instance. If
    you wish to set up local backups or access the DB directly, you'll
    need to use this.
  - **databaseAdminUsername**: The admin username for your database
    (this is not the same as your Moodle username).
  - **databaseAdminPassword**: The admin password for your
    database (this is not the same as your Moodle password).

## Retrieving Output Parameters Using the CLI

To get a complete list of outputs in json format use:

```bash
az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out json --query *.outputs
```

Individual outputs can be retrieved by filtering, for example, to get
just the value of the `siteURL` use:

``` bash
az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out json --query *.outputs.siteURL.value
```

However, since we are reqeusting JSON output (the default) the value
is enclosed in quotes. In order to remove these we can output as a tab
separated list (TSV):

``` bash
az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.siteURL
```

Now we can assign individual values to environment variables, for example:

``` bash
MOODLE_SITE_URL="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.siteURL.value)"
```

### Retrieving Moodle Site URL

The Site URL is the value used to configure Moodle's base URL. The
site URL can be provided as an input to the template via the parameter
`siteURL`, in which case you will not need to retrieve this from the
outputs. However, if you do not define this, or if you leave it as the
default "www.example.org" you will need to retrieve this value from
Azure using the following command:

```bash
MOODLE_SITE_URL="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.siteURL.value)"
```

#### Retrieving Moodle Site Load Balancer URL

The load balancer DNS is the publicly registered DNS name for your
Moodle DNS. If this is different from the site URL it is important to
ensure that you configure your DNS entry for site URL to point at the
load balancer.

```bash
MOODLE_LOAD_BALANCER_DNS="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.loadBalancerDNS.value)"
```

### Retrieving Moodle Administrator Password

Moodle admin password (username is "admin"):

```bash
MOODLE_ADMIN_PASSWORD="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.moodleAdminPassword.value)"
```

### Retriving Controller Virtual Machine Details

The controller VM runs management tasks for the cluster, such as cron jobs and syslog.

```bash
MOODLE_CONTROLLER_INSTANCE_IP="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.controllerInstanceIP.value)"
```

There is no username and password for this VM since a username and SSH
key are provided as input parameters to the template.

### Retreiving Database Information

#### Database URL

``` bash
MOODLE_DATABASE_DNS="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.databaseDNS.value)"
```
#### Database admin username

``` bash
MOODLE_DATABASE_ADMIN_USERNAME="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.databaseAdminUsername.value)"
```

#### Database admin password

``` bash
MOODLE_DATABASE_ADMIN_PASSWORD="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.databaseAdminPassword.value)"
```

### Retrieving Moodle Application VNET Information

First frontend VM IP:

``` bash
MOODLE_FIRST_FRONTEND_VM_IP="$(az group deployment show --resource-group $MOODLE_RG_NAME --name $MOODLE_DEPLOYMENT_NAME --out tsv --query *.outputs.firstFrontendVmIP.value)"
```

# Validation

After having run each of the commands in this document you should have
each of the output parameters available in environment variable:

``` bash
echo $MOODLE_SITE_URL
echo $MOODLE_LOAD_BALANCER_DNS
echo $MOODLE_ADMIN_PASSWORD
echo $MOODLE_CONTROLLER_INSTANCE_IP
echo $MOODLE_DATABASE_DNS
echo $MOODLE_DATABASE_ADMIN_USERNAME
echo $MOODLE_DATABASE_ADMIN_PASSWORD
echo $MOODLE_FIRST_FRONTEND_VM_IP
```

## Next Steps

  1. [Manage the Moodle cluster](./Manage.md)
