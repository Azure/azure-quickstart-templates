# Managing a Scalable Moodle Cluster in Azure

This document provides an overview of how to perform various
management tasks on a scalable Moodle cluster on Azure.

## Prerequisites

In order to configure our deployment and tools we'll set up some
[environment variables](./Environment-Variables.md) to ensure consistency.

In order to manage a cluster it is clearly necessary to first [deploy
a scalable Moodle cluster on Azure](./Deploy.md).

For convenience and readability this document also assumes that essential [deployment details for your cluster have been assigned to environment variables](./Get-Install-Data.md).

## Updating Moodle code/settings

Your controller Virtual Machine has Moodle code and data stored in
`/moodle`. The site code is stored in `/moodle/html/moodle/`. This
data is replicated across dual gluster nodes to provide high
availability. This directory is also mounted to your autoscaled
frontends so all changes to files on the controller VM are immediately
available to all frontend machines (when the `htmlLocalCopySwitch` in `azuredeploy.json`
is false--otherwise, see below). Note that any updates on Moodle code/settings
(e.g., additional plugin installations, Moodle version upgrade) have to be done
on the controller VM using shell commands, not through a web browser, because the
HTML directory's permission is read-only for the web frontend VMs (thus any web-based
Moodle code updates will fail).

Depending on how large your Gluster disks are sized, it may be helpful
to keep multiple older versions (/moodle/html1, /moodle/html2, etc) to
roll back if needed.

To connect to your Controller VM use SSH with a username of
'azureuser' and the SSH provided in the `sshPublicKey` input
parameter. For example, to retrieve a listing of files and directories
in the `/moodle` directory use:

```
ssh -o StrictHostKeyChecking=no azureadmin@$MOODLE_CONTROLLER_INSTANCE_IP ls -l /moodle
```

Results:

```
Warning: Permanently added '52.228.45.38' (ECDSA) to the list of known hosts.
total 12
drwxr-xr-x  2 www-data www-data 4096 Jan 17 00:59 certs
-rw-r--r--  1 root     root        0 Jan 17 02:22 db-backup.sql
drwxr-xr-x  3 www-data www-data 4096 Jan 17 00:54 html
drwxrwx--- 10 www-data www-data 4096 Jan 17 06:55 moodledata
```

**IMPORTANT NOTE**

It is important to realize that the `-o StrictHostKeyChecking=no`
option in the above SSH command presents a security risk. It is
included here to facilitate automated validation of these commands. It
is not recommended to use this option in production environments,
instead run the command mannually and validate the host key.
Subsequent executions of an SSH command will not require this
validation step. For more information there is an excellent
[superuser.com
Q&A](https://superuser.com/questions/421074/ssh-the-authenticity-of-host-host-cant-be-established/421084#421084).

### If you set `htmlLocalCopySwitch` to true (this is the default now)

Originally the `/moodle/html` directory was shared across all autoscaled
web VMs through the specified file server (Gluster or NFS), and this is
not good for web response time. Therefore, we introduced the
`htmlLocalCopySwitch` that'll copy the `/moodle/html` directory to
`/var/www/html` in each autoscaled web VM and reconfigures the web
server (apache/nginx)'s server root directory accordingly, when it's set
to true. This now requires directory sync between `/moodle/html` and
`/var/www/html`, and currently it's addressed by simple polling
(minutely). Therefore, if you are going to update your Moodle
code/settings with the switch set to true, please follow the
following steps:

* Put your Moodle site to maintenance mode.
  * This will need to be done on the contoller VM with some shell command.
  * It should be followed by running the following command to propagate the change to all autoscaled web VMs:
    ```bash
    $ sudo /usr/local/bin/update_last_modified_time_update.moodle_on_azure.sh
    ```
  * Once this command is executed, each autoscaled web VM will pick up (sync) the changes within 1 minute, so wait for one minute.
* Then you can start updating your Moodle code/settings, like installing/updating plugins or upgrading Moodle version or changing Moodle configurations. Again, note that this should be all done on the controller VM using some shell commands.
* When you are done updating your Moodle code/settings, run the same command as above to let each autoscaled web VM pick up (sync) the changes (wait for another minute here, for the same reason).

Please do let us know on this Github repo's Issues if you encounter any problems with this process.

## Getting an SQL dump

By default a daily sql dump of your database is taken at 02:22 and
saved to `/moodle/db-backup.sql`(.gz). This file can be retrieved
using SCP or similar. For example:

``` bash
scp azureadmin@$MOODLE_CONTROLLER_INSTANCE_IP:/moodle/db-backup.sql /tmp/moodle-db-backup.sql
```

To obtain a more recent SQL dump you run the commands appropriate for
your chosen database on the Controller VM. The following sections will
help with this task.

#### Postgres

Postgress provides a `pg_dump` command that can be used to take a
snapshot of the database via SSH. For example, use the following
command:

``` bash
ssh azureadmin@$MOODLE_CONTROLLER_INSTANCE_IP 'pg_dump -Fc -h $MOODLE_DATABASE_DNS -U $MOODLE_DATABASE_ADMIN_USERNAME moodle > /moodle/db-snapshot.sql'
```

See the Postgres documentation for full details of the [`pg_dump`](https://www.postgresql.org/docs/9.5/static/backup-dump.html) command.

#### MySQL

MySQL provides a `mysql_dump` command that can be used to take a
snapshot of the database via SSH. For example, use the following
command:

``` bash
ssh azureadmin@$MOODLE_CONTROLLER_INSTANCE_IP 'mysqldump -h $mysqlIP -u ${azuremoodledbuser} -p'${moodledbpass}' --databases ${moodledbname} | gzip > /moodle/db-backup.sql.gz'
```

## Backup and Recovery

If you have set the `azureBackupSwitch` in the input parameters to `1`
then Azure will provide VM backups of your Gluster node. This is
recommended as it contains both your Moodle code and your sitedata.
Restoring a backed up VM is outside the scope of this doc, but Azure's
documentation on Recovery Services can be found here:
https://docs.microsoft.com/en-us/azure/backup/backup-azure-vms-first-look-arm

## Resizing your Database

Note: This process involves site downtime and should therefore only be
carried out during a planned maintenance window.

At the time of writing Azure does not support resizing MySQL or
Postgres databases. You can, however, create a new database instance,
with a different size, and change your config to point to that. To get
a different size database you'll need to:

  1. [Place your Moodle site into maintenance
     mode](https://docs.moodle.org/34/en/Maintenance_mode). You can do
     this either via the web interface or the command line on the
     controller VM.
  2. Perform an SQL dump of your database. See above for more details.
  3. Create a new Azure database of the size you want inside your
     existing resource group.
  4. Using the details in your /moodle/html/moodle/config.php create a
     new user and database matching the details in config.php. Make
     sure to grant all rights on the db to the user.
  5. On the controller instance, change the db setting in
     /moodle/html/moodle/config.php to point to the new database.
  6. Take Moodle site out of maintenance mode.
  7. Once confirmed working, delete the previous database instance.

How long this takes depends entirely on the size of your database and
the speed of your VM tier. It will always be a large enough window to
make a noticeable outage.

## Changing the SSL cert

The self-signed cert generated by the template is suitable for very
basic testing, but a public website will want a real cert. After
purchasing a trusted certificate, it can be copied to the following
files to be ready immediately:

  - /moodle/certs/nginx.key: Your certificate's private key
  - /moodle/certs/nginx.crt: Your combined signed certificate and trust chain certificate(s).

## Next Steps

  1. [Retrieve configuration details using CLI](./Get-Install-Data.md)
