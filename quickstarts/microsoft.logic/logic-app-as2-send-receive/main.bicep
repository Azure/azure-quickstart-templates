@description('Name of the Integration Account.')
@minLength(1)
@maxLength(80)
param contosoIntegrationAccountName string = 'ContosoIntegrationAccount'

@description('Name of the Integration Account.')
@minLength(1)
@maxLength(80)
param fabrikamIntegrationAccountName string = 'FabrikamIntegrationAccount'

@description('Name of the Logic App.')
@minLength(1)
@maxLength(80)
param contosoAS2ReceiveLogicAppName string = 'Contoso-AS2Receive'

@description('Name of the Logic App.')
@minLength(1)
@maxLength(80)
param fabrikamSalesAS2SendLogicAppName string = 'FabrikamSales-AS2Send'

@description('Name of the Logic App.')
@minLength(1)
@maxLength(80)
param fabrikamFinanceAS2SendLogicAppName string = 'FabrikamFinance-AS2Send'

@description('Name of the Logic App.')
@minLength(1)
@maxLength(80)
param fabrikamFinanceAS2ReceiveMDNLogicAppName string = 'FabrikamFinance-AS2ReceiveMDN'

@description('Location of the Logic App.')
param location string = resourceGroup().location

@description('Name of the AS2 connection.')
param contoso_AS2_Connection_Name string = 'Contoso-AS2'

@description('Name of the AS2 connection.')
param fabrikam_AS2_Connection_Name string = 'Fabrikam-AS2'

var as2Id = subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'as2')

resource contosoIntegrationAccount 'Microsoft.Logic/integrationAccounts@2019-05-01' = {
  properties: {}
  sku: {
    name: 'Standard'
  }
  tags: {
    displayName: 'Contoso Integration Account'
  }
  name: contosoIntegrationAccountName
  location: location
}

resource fabrikamIntegrationAccount 'Microsoft.Logic/integrationAccounts@2019-05-01' = {
  properties: {}
  sku: {
    name: 'Standard'
  }
  tags: {
    displayName: 'Fabrikam Integration Account'
  }
  name: fabrikamIntegrationAccountName
  location: location
}

resource contosoIntegrationAccountName_Contoso 'Microsoft.Logic/integrationAccounts/partners@2016-06-01' = {
  parent: contosoIntegrationAccount
  properties: {
    partnerType: 'B2B'
    content: {
      b2b: {
        businessIdentities: [
          {
            qualifier: 'ZZ'
            value: '99'
          }
          {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
        ]
      }
    }
  }
  name: 'Contoso'
}

resource fabrikamIntegrationAccountName_Contoso 'Microsoft.Logic/integrationAccounts/partners@2016-06-01' = {
  parent: fabrikamIntegrationAccount
  properties: {
    partnerType: 'B2B'
    content: {
      b2b: {
        businessIdentities: [
          {
            qualifier: 'ZZ'
            value: '99'
          }
          {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
        ]
      }
    }
  }
  name: 'Contoso'
}

resource contosoIntegrationAccountName_FabrikamSales 'Microsoft.Logic/integrationAccounts/partners@2016-06-01' = {
  parent: contosoIntegrationAccount
  properties: {
    partnerType: 'B2B'
    content: {
      b2b: {
        businessIdentities: [
          {
            qualifier: 'ZZ'
            value: '98'
          }
          {
            qualifier: 'AS2Identity'
            value: 'FabrikamSales'
          }
        ]
      }
    }
  }
  name: 'FabrikamSales'
}

resource fabrikamIntegrationAccountName_FabrikamSales 'Microsoft.Logic/integrationAccounts/partners@2016-06-01' = {
  parent: fabrikamIntegrationAccount
  properties: {
    partnerType: 'B2B'
    content: {
      b2b: {
        businessIdentities: [
          {
            qualifier: 'ZZ'
            value: '98'
          }
          {
            qualifier: 'AS2Identity'
            value: 'FabrikamSales'
          }
        ]
      }
    }
  }
  name: 'FabrikamSales'
}

resource contosoIntegrationAccountName_FabrikamFinance 'Microsoft.Logic/integrationAccounts/partners@2016-06-01' = {
  parent: contosoIntegrationAccount
  properties: {
    partnerType: 'B2B'
    content: {
      b2b: {
        businessIdentities: [
          {
            qualifier: 'ZZ'
            value: '97'
          }
          {
            qualifier: 'AS2Identity'
            value: 'FabrikamFinance'
          }
        ]
      }
    }
  }
  name: 'FabrikamFinance'
}

resource fabrikamIntegrationAccountName_FabrikamFinance 'Microsoft.Logic/integrationAccounts/partners@2016-06-01' = {
  parent: fabrikamIntegrationAccount
  properties: {
    partnerType: 'B2B'
    content: {
      b2b: {
        businessIdentities: [
          {
            qualifier: 'ZZ'
            value: '97'
          }
          {
            qualifier: 'AS2Identity'
            value: 'FabrikamFinance'
          }
        ]
      }
    }
  }
  name: 'FabrikamFinance'
}

resource contosoIntegrationAccountName_Contoso_FabrikamSales 'Microsoft.Logic/integrationAccounts/agreements@2016-06-01' = {
  parent: contosoIntegrationAccount
  properties: {
    hostPartner: 'Contoso'
    guestPartner: 'FabrikamSales'
    hostIdentity: {
      qualifier: 'AS2Identity'
      value: 'Contoso'
    }
    guestIdentity: {
      qualifier: 'AS2Identity'
      value: 'FabrikamSales'
    }
    agreementType: 'AS2'
    content: {
      aS2: {
        receiveAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: false
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamSales'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
        }
        sendAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: false
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamSales'
          }
        }
      }
    }
  }
  name: 'Contoso-FabrikamSales'
}

resource fabrikamIntegrationAccountName_FabrikamSales_Contoso 'Microsoft.Logic/integrationAccounts/agreements@2016-06-01' = {
  parent: fabrikamIntegrationAccount
  properties: {
    hostPartner: 'FabrikamSales'
    guestPartner: 'Contoso'
    hostIdentity: {
      qualifier: 'AS2Identity'
      value: 'FabrikamSales'
    }
    guestIdentity: {
      qualifier: 'AS2Identity'
      value: 'Contoso'
    }
    agreementType: 'AS2'
    content: {
      aS2: {
        receiveAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: false
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamSales'
          }
        }
        sendAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: true
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamSales'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
        }
      }
    }
  }
  name: 'FabrikamSales-Contoso'
}

resource contosoIntegrationAccountName_Contoso_FabrikamFinance 'Microsoft.Logic/integrationAccounts/agreements@2016-06-01' = {
  parent: contosoIntegrationAccount
  properties: {
    hostPartner: 'Contoso'
    guestPartner: 'FabrikamFinance'
    hostIdentity: {
      qualifier: 'AS2Identity'
      value: 'Contoso'
    }
    guestIdentity: {
      qualifier: 'AS2Identity'
      value: 'FabrikamFinance'
    }
    agreementType: 'AS2'
    content: {
      aS2: {
        receiveAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: false
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamFinance'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
        }
        sendAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: false
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamFinance'
          }
        }
      }
    }
  }
  name: 'Contoso-FabrikamFinance'
}

resource contosoAS2ReceiveLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: contosoAS2ReceiveLogicAppName
  location: location
  tags: {
    displayName: 'Contoso AS2 Receive'
  }
  properties: {
    state: 'Enabled'
    integrationAccount: {
      id: contosoIntegrationAccount.id
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      actions: {
        Check_MDN_Expected: {
          type: 'If'
          expression: '@equals(body(\'Decode_AS2_message\')?[\'AS2Message\']?[\'MdnExpected\'], \'Expected\')'
          actions: {
            Check_MDN_Type: {
              type: 'If'
              expression: '@equals(body(\'Decode_AS2_message\')?[\'OutgoingMdn\']?[\'MdnType\'], \'Async\')'
              actions: {
                Send_200_OK_for_Async_MDN: {
                  type: 'Response'
                  inputs: {
                    statusCode: 200
                  }
                }
                Send_Async_MDN: {
                  type: 'Http'
                  inputs: {
                    method: 'POST'
                    uri: '@{body(\'Decode_AS2_message\')?[\'OutgoingMdn\']?[\'ReceiptDeliveryOption\']}'
                    headers: '@body(\'Decode_AS2_message\')?[\'OutgoingMdn\']?[\'OutboundHeaders\']'
                    body: '@base64ToBinary(body(\'Decode_AS2_message\')?[\'OutgoingMdn\']?[\'Content\'])'
                  }
                  runAfter: {
                    Send_200_OK_for_Async_MDN: [
                      'Succeeded'
                    ]
                  }
                }
              }
              else: {
                actions: {
                  Send_Sync_MDN: {
                    type: 'Response'
                    inputs: {
                      statusCode: 200
                      headers: '@body(\'Decode_AS2_message\')?[\'OutgoingMdn\']?[\'OutboundHeaders\']'
                      body: '@base64ToBinary(body(\'Decode_AS2_message\')?[\'OutgoingMdn\']?[\'Content\'])'
                    }
                  }
                }
              }
            }
          }
          runAfter: {
            Decode_AS2_message: [
              'Succeeded'
            ]
          }
          else: {
            actions: {
              Send_200_OK: {
                type: 'Response'
                inputs: {
                  statusCode: 200
                }
              }
            }
          }
        }
        Decode_AS2_message: {
          type: 'ApiConnection'
          inputs: {
            host: {
              api: {
                runtimeUrl: 'https://logic-apis-${location}.azure-apim.net/apim/as2'
              }
              connection: {
                name: '@parameters(\'$connections\')[\'as2\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: '@triggerBody()'
            path: '/decode'
            headers: '@triggerOutputs()[\'headers\']'
          }
        }
      }
      parameters: {
        '$connections': {
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
        }
      }
      contentVersion: '1.0.0.0'
    }
    parameters: {
      '$connections': {
        value: {
          as2: {
            id: as2Id
            connectionId: '${resourceGroup().id}/providers/Microsoft.Web/connections/${contoso_AS2_Connection_Name}'
            connectionName: contoso_AS2_Connection_Name
          }
        }
      }
    }
  }
  dependsOn: [

    contoso_AS2_Connection
  ]
}

resource fabrikamSalesAS2SendLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: fabrikamSalesAS2SendLogicAppName
  location: location
  tags: {
    displayName: 'Fabrikam Sales AS2 Send'
  }
  properties: {
    state: 'Enabled'
    integrationAccount: {
      id: fabrikamIntegrationAccount.id
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      actions: {
        HTTP: {
          inputs: {
            method: 'POST'
            uri: contosoAS2ReceiveLogicApp.listCallbackUrl().value
            headers: {
              'AS2-From': 'FabrikamSales'
              'AS2-To': 'Contoso'
              'Message-Id': '@guid()'
              'content-type': 'text/plain'
            }
            body: 'Fabrikam Sales - sample message'
          }
          type: 'Http'
        }
      }
      parameters: {
        '$connections': {
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            frequency: 'Hour'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      contentVersion: '1.0.0.0'
    }
    parameters: {
      '$connections': {
        value: {
          as2: {
            id: as2Id
            connectionId: '${resourceGroup().id}/providers/Microsoft.Web/connections/${fabrikam_AS2_Connection_Name}'
            connectionName: fabrikam_AS2_Connection_Name
          }
        }
      }
    }
  }
  dependsOn: [

    fabrikam_AS2_Connection

  ]
}

resource fabrikamFinanceAS2SendLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: fabrikamFinanceAS2SendLogicAppName
  location: location
  tags: {
    displayName: 'Fabrikam Finance AS2 Send'
  }
  properties: {
    state: 'Enabled'
    integrationAccount: {
      id: fabrikamIntegrationAccount.id
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      actions: {
        Encode_to_AS2_message: {
          inputs: {
            body: 'Fabrikam Finance - sample message'
            host: {
              api: {
                runtimeUrl: 'https://logic-apis-${location}.azure-apim.net/apim/as2'
              }
              connection: {
                name: '@parameters(\'$connections\')[\'as2\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/encode'
            queries: {
              as2From: 'FabrikamFinance'
              as2To: 'Contoso'
            }
          }
          type: 'ApiConnection'
        }
        HTTP: {
          inputs: {
            body: '@base64ToBinary(body(\'Encode_to_AS2_message\')?[\'AS2Message\']?[\'Content\'])'
            headers: '@body(\'Encode_to_AS2_message\')?[\'AS2Message\']?[\'OutboundHeaders\']'
            method: 'POST'
            uri: contosoAS2ReceiveLogicApp.listCallbackUrl().value
          }
          runAfter: {
            Encode_to_AS2_message: [
              'Succeeded'
            ]
          }
          type: 'Http'
        }
      }
      parameters: {
        '$connections': {
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            frequency: 'Hour'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      contentVersion: '1.0.0.0'
    }
    parameters: {
      '$connections': {
        value: {
          as2: {
            id: as2Id
            connectionId: '${resourceGroup().id}/providers/Microsoft.Web/connections/${fabrikam_AS2_Connection_Name}'
            connectionName: fabrikam_AS2_Connection_Name
          }
        }
      }
    }
  }
  dependsOn: [

    fabrikam_AS2_Connection

  ]
}

resource fabrikamFinanceAS2ReceiveMDNLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: fabrikamFinanceAS2ReceiveMDNLogicAppName
  location: location
  tags: {
    displayName: 'Fabrikam Finance AS2 Receive MDN'
  }
  properties: {
    state: 'Enabled'
    integrationAccount: {
      id: fabrikamIntegrationAccount.id
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      actions: {
        Decode_AS2_message: {
          type: 'ApiConnection'
          inputs: {
            host: {
              api: {
                runtimeUrl: 'https://logic-apis-${location}.azure-apim.net/apim/as2'
              }
              connection: {
                name: '@parameters(\'$connections\')[\'as2\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: '@triggerBody()'
            path: '/decode'
            headers: '@triggerOutputs()[\'headers\']'
          }
        }
        Response: {
          inputs: {
            statusCode: 200
          }
          runAfter: {
            Decode_AS2_message: [
              'Succeeded'
            ]
          }
          type: 'Response'
        }
      }
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
        }
      }
      contentVersion: '1.0.0.0'
    }
    parameters: {
      '$connections': {
        value: {
          as2: {
            id: as2Id
            connectionId: '${resourceGroup().id}/providers/Microsoft.Web/connections/${fabrikam_AS2_Connection_Name}'
            connectionName: fabrikam_AS2_Connection_Name
          }
        }
      }
    }
  }
  dependsOn: [

    fabrikam_AS2_Connection
    contosoAS2ReceiveLogicApp
  ]
}

resource fabrikamIntegrationAccountName_FabrikamFinance_Contoso 'Microsoft.Logic/integrationAccounts/agreements@2016-06-01' = {
  parent: fabrikamIntegrationAccount
  properties: {
    hostPartner: 'FabrikamFinance'
    guestPartner: 'Contoso'
    hostIdentity: {
      qualifier: 'AS2Identity'
      value: 'FabrikamFinance'
    }
    guestIdentity: {
      qualifier: 'AS2Identity'
      value: 'Contoso'
    }
    agreementType: 'AS2'
    content: {
      aS2: {
        receiveAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: false
              signMdn: false
              sendMdnAsynchronously: false
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamFinance'
          }
        }
        sendAgreement: {
          protocolSettings: {
            messageConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: true
              keepHttpConnectionAlive: true
              unfoldHttpHeaders: true
            }
            acknowledgementConnectionSettings: {
              ignoreCertificateNameMismatch: false
              supportHttpStatusCodeContinue: false
              keepHttpConnectionAlive: false
              unfoldHttpHeaders: false
            }
            mdnSettings: {
              needMdn: true
              signMdn: false
              sendMdnAsynchronously: true
              receiptDeliveryUrl: fabrikamFinanceAS2ReceiveMDNLogicApp.listCallbackUrl().value
              dispositionNotificationTo: 'http://localhost'
              signOutboundMdnIfOptional: false
              sendInboundMdnToMessageBox: true
              micHashingAlgorithm: 'SHA2256'
            }
            securitySettings: {
              overrideGroupSigningCertificate: false
              enableNrrForInboundEncodedMessages: false
              enableNrrForInboundDecodedMessages: false
              enableNrrForOutboundMdn: false
              enableNrrForOutboundEncodedMessages: false
              enableNrrForOutboundDecodedMessages: false
              enableNrrForInboundMdn: false
            }
            validationSettings: {
              overrideMessageProperties: false
              encryptMessage: false
              signMessage: false
              compressMessage: false
              checkDuplicateMessage: false
              interchangeDuplicatesValidityDays: 5
              checkCertificateRevocationListOnSend: false
              checkCertificateRevocationListOnReceive: false
              encryptionAlgorithm: 'DES3'
            }
            envelopeSettings: {
              messageContentType: 'text/plain'
              transmitFileNameInMimeHeader: false
              fileNameTemplate: '%FILE().ReceivedFileName%'
              suspendMessageOnFileNameGenerationError: true
              autogenerateFileName: false
            }
            errorSettings: {
              suspendDuplicateMessage: false
              resendIfMdnNotReceived: false
            }
          }
          senderBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'FabrikamFinance'
          }
          receiverBusinessIdentity: {
            qualifier: 'AS2Identity'
            value: 'Contoso'
          }
        }
      }
    }
  }
  name: 'FabrikamFinance-Contoso'
}

resource contoso_AS2_Connection 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: contoso_AS2_Connection_Name
  location: location
  properties: {
    api: {
      id: as2Id
    }
    displayName: 'Contoso AS2 connection'
    parameterValues: {
      integrationAccountId: contosoIntegrationAccount.id
      integrationAccountUrl: contosoIntegrationAccount.listCallbackUrl().value
    }
  }
}

resource fabrikam_AS2_Connection 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: fabrikam_AS2_Connection_Name
  location: location
  properties: {
    api: {
      id: as2Id
    }
    displayName: 'Fabrikam AS2 connection'
    parameterValues: {
      integrationAccountId: fabrikamIntegrationAccount.id
      integrationAccountUrl: fabrikamIntegrationAccount.listCallbackUrl().value
    }
  }
}
