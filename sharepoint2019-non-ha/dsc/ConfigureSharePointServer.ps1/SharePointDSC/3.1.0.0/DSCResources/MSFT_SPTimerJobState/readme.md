# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to configure a timer job and make sure it is in a
specific state. The resource can be used to enable or disabled the job and
configure the schedule of the job.

The schedule parameter has to be written in the SPSchedule format
(https://technet.microsoft.com/en-us/library/ff607916.aspx).

Examples are:

- Every 5 minutes between 0 and 59
- Hourly between 0 and 59
- Daily at 15:00:00
- Weekly between Fri 22:00:00 and Sun 06:00:00
- Monthly at 15 15:00:00
- Yearly at Jan 1 15:00:00

NOTE:
Make sure you use the typename timer job name, not the display name! Use
"Get-SPTimerJob | Where-Object { $_.Title -eq "\<Display Name\>" } | Select typename"
to find the typename for each Timer Job.

NOTE2: You cannot use SPTimerJobState to change the Health Analyzer jobs, because
these are configured to specific times by default.
