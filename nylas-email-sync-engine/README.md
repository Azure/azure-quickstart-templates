# Deploy Nylas email sync engine on Debian

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnylas-email-sync-engine%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnylas-email-sync-engine%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys the Nylas Sync Engine on a Debian VM in Azure. This allows you to sync your email with the Nylas N1 email client on a Linux OS like Ubuntu.

After the deployment completes, ssh into your VM and run via the commandline to start syncing:

```bash
$ cd /usr/local/sync-engine/
$ bin/inbox-auth <your-username>@<gmail or outlook or yahoo or aol>.com
```

The `inbox-auth` command will walk you through the process of obtaining an authorization token from Google or another service for syncing your mail. In the open-source version of the sync engine, your credentials are stored to the local MySQL database for simplicity. The open-source Nylas Sync Engine does not support Exchange, but the [hosted](https://www.nylas.com) version does.

The sync engine will automatically begin syncing your account with the underlying provider. The `inbox-sync` command allows you to manually stop or restart the sync by running `inbox-sync stop [YOUR_ACCOUNT]@example.com` or `inbox-sync start [YOUR_ACCOUNT]@example.com`. Note that an initial sync can take quite a while depending on how much mail you have.

### Nylas API Service

The Nylas API service provides a REST API for interacting with your data. To start it in your development environment, run command below from within your VM:

```bash
$ bin/inbox-api
```

This will start the API Server on port 5555. At this point **You're now ready to make requests!**

You can get a list of all connected accounts by requesting `http://<your-vms-public-ip>:5555/accounts`.

>1. Note the account_id value from this step as you'll be using this in a later step.

>2.  In it's current form this endpoint requires no authentication. To deploy this securely you will need to roll your own security layer (nginx reverse proxy etc.) in front of the endpoint.

For subsequent requests to retreive mail, contacts, and calendar data, your app should pass the `account_id` value from the previous step as the "username" parameter in HTTP Basic auth. For example:

```bash
$ curl --user 'ACCOUNT_ID_VALUE_HERE:' http://<your-vms-public-ip>:5555/threads
```

If you are using a web browser and would like to clear your cached HTTP Basic Auth values, simply visit `http://<your-vms-public-ip>:5555/logout` and click "Cancel".

After the sync engine is setup, you'll need to point your installation of the N1 email app to using your sync engine. Please follow the below guide for doing that:

`https://github.com/nylas/N1/blob/master/CONFIGURATION.md`

For more information on the Nylas sync engine, see https://github.com/nylas/sync-engine