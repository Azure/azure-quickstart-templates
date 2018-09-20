# Change Log

## 2018.6

* Adopt to April 2018 Azure Monitor pricing model
* Use lower case of severity for alerts

## 2018.1

* Upgrade all alerts to KQL and remove workaround due to language limitation
* Add alerts for new KPIs including internal MySQL KPIs
* Remove views for etcd server from default views list according to component change in PCF2.0
* Rename alerts and saved searches for clarity

## 2017.12

* Add version and changelog to the template
* Refine document, add instruction of customizing and upgrade
* Minor updates to nested templates, change to `parallel` mode for faster deployment

## 2017.11

* Refine document, add instruction of system metrics provider
* Fix view reference error, deploying now use master branch of repository [Microsoft Azure Log Analytics Nozzle](https://github.com/Azure/oms-log-analytics-firehose-nozzle)
* Default system metrics provider changed to `Microsoft Azure OMS Agent`

## 2017.10

* Support system metrics and allow users to choose between `Microsoft Azure OMS Agent` and `BOSH Health Metrics Forwarder`
* Bundle all views to solutions in which system metrics providers will have monopolized solution
* Reformat templates, remove redundant parameters

## 2017.9

* Add all cloud foundry [official KPI](https://docs.pivotal.io/pivotalcf/1-11/monitoring/kpi.html) as alerts

## 2017.8

* Officially release templates with documents

## 2017.6

* Initial version with default views, alerts and saved searches
