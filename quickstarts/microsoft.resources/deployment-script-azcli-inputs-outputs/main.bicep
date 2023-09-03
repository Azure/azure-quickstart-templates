@description('An example of a boolean parameter')
param myBool bool

@description('An example of an integer parameter')
param myInt int

@description('An example of a string parameter')
param myString string

@description('An example of an array parameter')
param myArray array

@description('An example of an object parameter')
param myObject object

var scriptArguments = [
  /*myBool*/ myBool ? 'true' : 'false'
  /*myInt*/ '${myInt}'
  /*myString*/ '"${replace(myString, '"', '\\"')}"'
  /*myArray*/ '"${replace(string(myArray), '"', '\\"')}"'
  /*myObject*/ '"${replace(string(myObject), '"', '\\"')}"'
]
var scriptContent = loadTextContent('./script.sh')

resource myScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'myScript'
#disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.50.0'
    retentionInterval: 'PT1H'
    scriptContent: scriptContent
    arguments: join(scriptArguments, ' ')
  }
}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: myScript
  name: 'default'
}

@description('The logs written by the script')
output logs array = split(logs.properties.log, '\n')

@description('An example of a boolean output')
output myBool bool = myScript.properties.outputs.myBool

@description('An example of an integer output')
output myInt int = myScript.properties.outputs.myInt

@description('An example of a string output')
output myString string = myScript.properties.outputs.myString

@description('An example of an array output')
output myArray array = myScript.properties.outputs.myArray

@description('An example of an object output')
output myObject object = myScript.properties.outputs.myObject
