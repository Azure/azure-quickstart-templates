Describe "Get-FixedReadMe" {
    BeforeAll {
        $ErrorActionPreference = 'Stop'    
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/fix-readme-tests"

        $markdownWithoutBicep = @"
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry%2Fazuredeploy.json)
"@

        $markdownWithBicep = @"
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerregistry/container-registry/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry%2Fazuredeploy.json)
"@

        function Get-FixedReadMe(
            [string] $ReadmeContents,
            [string] $Markdown
        ) {
            $cmdlet = "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Get-FixedReadMe.ps1"            
            $result = . $cmdlet `
                -ReadmeContents $ReadmeContents `
                -ExpectedMarkdown $Markdown
            return $result
        }

        function Test([string] $ReadmeBaseName, [string] $Markdown) {
            $readmeName = "$dataFolder/$ReadmeBaseName.md" 
            $readme = Get-Content $readmeName -Raw
            $readmeExpectedName = "$dataFolder/$ReadmeBaseName.expected.md"
            $readmeExpected = Get-Content $readmeExpectedName -Raw

            $result = Get-FixedReadMe $readme $markdown
            $result | Should -Be $readmeExpected
        }
    }
    
    It 'adds links when none are found' {
        Test "README.nolinks" $markdownWithBicep
    }

    It 'makes no changes if already valid' {
        Test "README.nochanges" $markdownWithBicep
    }

    It 'adds bicep badge if missing' {
        Test "README.nobicep" $markdownWithBicep
    }

    It 'removes bicep badge if shouldn''t be there' {
        Test "README.removebicep" $markdownWithoutBicep
    }

    It 'ignores extra line breaks' {
        Test "README.extralinebreaks" $markdownWithBicep
    }

    It 'fixes order' {
        Test "README.outoforder" $markdownWithBicep
    }

    It 'fixes bad links' {
        Test "README.outoforder" $markdownWithBicep
    }
}
