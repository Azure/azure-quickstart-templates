# Dynamically Generate Web Tests

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-dynamic-web-tests%2fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-dynamic-web-tests%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will help you quickly spin up any number of [Application Insights](https://azure.microsoft.com/en-us/services/application-insights/) web tests and setup email alerts. The [parameters file](./azuredeploy.parameters.json) takes any number of test descriptor objects. These objects look like the following:

```json
{
    "name": "test1",
    "url": "http://www.microsoft.com",
    "expected": 200,
    "frequency_secs": 300,
    "timeout_secs": 30,
    "failedLocationCount": 1,
    "description": "a description for test1",
    "guid": "cc1c4b95-0a39-48ce-9c7b-fa41f0fc0bee",
    "locations": [{
        "Id": "us-il-ch1-azr"
	 }]
}
```

The `guid` field is an arbitrary guid for the test. The `locations` field is a collection of locations to perform the test from. Here is a table of the valid locations, and their cooresponding `Id` code:

| Name | Id          |
| ------------- | ----------- |
| US : IL-Chicago      | us-il-ch1-azr |
| US : CA-San Jose     | us-ca-sjc-azr |
| US : TX-San Antonio     | us-tx-sn1-azr |
| US : VA-Ashburn     | us-va-ash-azr |
| US : FL-Miami     | us-fl-mia-edge |
| SG : Singapore     | apac-sg-sin-azr |
| SE : Stockholm     | emea-se-sto-edge |
| RU : Moscow     | emea-ru-msa-edge |
| NL : Amsterdam     | emea-nl-ams-azr |
| JP : Kawaguchi     | apac-jp-kaw-edge |
| IE : Dublin     | emea-gb-db3-azr |
| HK : Hong Kong     | apac-hk-hkn-azr |
| FR : Paris     | emea-fr-pra-edge |
| CH : Zurich     | emea-ch-zrh-edge |
| BR : Sao Paulo     | latam-br-gru-edge |
| AU : Sydney     | emea-au-syd-edge |


You can create any number of these test descriptors and pass them in as the parameter for `tests` as shown in the [parameters file](./azuredeploy.parameters.json).
