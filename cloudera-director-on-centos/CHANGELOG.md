# Change Log

## 1.1.5 - 2017-03-22

* Add a change log: CHANGELOG.md
* Add barrier=0 option to disk mount scripts
* Avoid using hard-coded endpoints for Storage Accounts

## 1.1.6 - 2017-08-25

* Change generated Cloudera Director instance templates from STANDARD_DS14
to STANDARD_DS14_v2 to support newer Azure regions

## 1.1.7 - 2018-03-12
* Add GUID for tracking
* Update director to use CentOS 7.4
* Remove deprecated OS image
* Disable storage of secrets in cluster configuration file

## 1.2.1 - 2017-03-26

* Do not fail deployment if user gives Azurecredentials that fail
authentication or authorization. Instead, log the errors and allow the
deployment to complete, with the expectation that users will have to fix
their credentials and resubmit the director config.
