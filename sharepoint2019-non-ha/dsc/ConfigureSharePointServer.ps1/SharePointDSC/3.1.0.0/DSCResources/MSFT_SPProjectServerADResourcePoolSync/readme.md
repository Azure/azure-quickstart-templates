# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to control the settings of the Active Directory
resource pool sync for Project Server, for a specific PWA instance.
You can control which AD groups should be imported from and control
settings about reactivitating users.

NOTE:
The schedule for this import is controlled via a standard
SharePoint server timer job, and as such it can be controlled with
the SPTimerJobState resource. Below is an example of how to set
this resource to run the AD import job daily. The name of the job
here may change if you have multiple Project Server service apps
in the same farm.

    SPTimerJobState RunProjectSeverADImport
    {
        Name                    = "ActiveDirectorySync"
        Enabled                 = $true
        Schedule                = "daily between 03:00:00 and 03:00:00"
        PsDscRunAsCredential    = $SetupAccount
    }
