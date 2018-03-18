# Managing a Scalable Mahara Cluster in Azure

This document provides an overview of how to perform various
management tasks on a scalable Mahara cluster on Azure.

## Prerequisites

In order to configure our deployment and tools we'll set up some
[environment variables](./Environment-Variables.md) to ensure consistency.

In order to manage a cluster it is clearly necessary to first [deploy
a scalable Mahara cluster on Azure](./Deploy.md).

For convenience and readability this document also assumes that essential [deployment details for your cluster have been assigned to environment variables](./Get-Install-Data.md).

## Updating Mahara code/settings

Your controller Virtual Machine has Mahara code and data stored in
`/mahara`. The site code is stored in `/mahara/html/mahara/`. This
data is replicated across dual gluster nodes to provide high
availability. This directory is also mounted to your autoscaled
frontends so all changes to files on the controller VM are immediately
available to all frontend machines.

Depending on how large your Gluster disks are sized, it may be helpful
to keep multiple older versions (/mahara/html1, /mahara/html2, etc) to
roll back if needed.

To connect to your Controller VM use SSH with a username of
'azureuser' and the SSH provided in the `sshPublicKey` input
parameter. For example, to retrieve a listing of files and directories
in the `/mahara` directory use:

```
ssh -o StrictHostKeyChecking=no azureadmin@$MAHARA_CONTROLLER_INSTANCE_IP ls -l /mahara
```

Results:

```
Warning: Permanently added '52.228.45.38' (ECDSA) to the list of known hosts.
total 12
drwxr-xr-x  2 www-data www-data 4096 Jan 17 00:59 certs
-rw-r--r--  1 root     root        0 Jan 17 02:22 db-backup.sql
drwxr-xr-x  3 www-data www-data 4096 Jan 17 00:54 html
drwxrwx--- 10 www-data www-data 4096 Jan 17 06:55 maharadata
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

## Getting an SQL dump

By default a daily sql dump of your database is taken at 02:22 and
saved to `/mahara/db-backup.sql`(.gz). This file can be retrieved
using SCP or similar. For example:

``` bash
scp azureadmin@$MAHARA_CONTROLLER_INSTANCE_IP:/mahara/db-backup.sql /tmp/mahara-db-backup.sql
```

To obtain a more recent SQL dump you run the commands appropriate for
your chosen database on the Controller VM. The following sections will
help with this task.

#### Postgres

Postgress provides a `pg_dump` command that can be used to take a
snapshot of the database via SSH. For example, use the following
command:

``` bash
ssh azureadmin@$MAHARA_CONTROLLER_INSTANCE_IP 'pg_dump -Fc -h $MAHARA_DATABASE_DNS -U $MAHARA_DATABASE_ADMIN_USERNAME mahara > /mahara/db-snapshot.sql'
```

See the Postgres documentation for full details of the [`pg_dump`](https://www.postgresql.org/docs/9.5/static/backup-dump.html) command.

#### MySQL

MySQL provides a `mysql_dump` command that can be used to take a
snapshot of the database via SSH. For example, use the following
command:

``` bash
ssh azureadmin@$MAHARA_CONTROLLER_INSTANCE_IP 'mysqldump -h $mysqlIP -u ${azuremaharadbuser} -p'${maharadbpass}' --databases ${maharadbname} | gzip > /mahara/db-backup.sql.gz'
```

## Backup and Recovery

If you have set the `azureBackupSwitch` in the input parameters to `1`
then Azure will provide VM backups of your Gluster node. This is
recommended as it contains both your Mahara code and your sitedata.
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

  1. [Place your Mahara site into maintenance
     mode](https://docs.mahara.org/34/en/Maintenance_mode). You can do
     this either via the web interface or the command line on the
     controller VM.
  2. Perform an SQL dump of your database. See above for more details.
  3. Create a new Azure database of the size you want inside your
     existing resource group.
  4. Using the details in your /mahara/html/mahara/config.php create a
     new user and database matching the details in config.php. Make
     sure to grant all rights on the db to the user.
  5. On the controller instance, change the db setting in
     /mahara/html/mahara/config.php to point to the new database.
  6. Take Mahara site out of maintenance mode.
  7. Once confirmed working, delete the previous database instance.

How long this takes depends entirely on the size of your database and
the speed of your VM tier. It will always be a large enough window to
make a noticeable outage.

## Changing the SSL cert

The self-signed cert generated by the template is suitable for very
basic testing, but a public website will want a real cert. After
purchasing a trusted certificate, it can be copied to the following
files to be ready immediately:

  - /mahara/certs/nginx.key: Your certificate's private key
  - /mahara/certs/nginx.crt: Your combined signed certificate and trust chain certificate(s).

## Next Steps

  1. [Retrieve configuration details using CLI](./Get-Install-Data.md)
