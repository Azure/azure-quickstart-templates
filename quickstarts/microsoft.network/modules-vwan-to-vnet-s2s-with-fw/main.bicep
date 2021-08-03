targetScope = 'subscription'

@description('Specify the location for the hub Virtual Network and its related resources')
param location string = 'westeurope'

@description('Specify the location for the vWAN and its related resources')
param vwanlocation string = 'eastus'

@description('Specify the name prefix for all resources and resource groups')
param nameprefix string = 'contoso'

@secure()
@description('Pre-Shared Key used to establish the site to site tunnel between the Virtual Hub and On-Prem VNet')
param psk string = uniqueString(subscription().id)

var vnetname = '${nameprefix}-vnet'
var vpngwname = '${vnetname}-vpn-gw'
var vpngwpipname = '${vnetname}-vpn-gw'
var vpnconname = '${vnetname}-to-${vhubname}-cn'
var lgwname = '${vwanlocation}-site-lgw'
var fwname = '${vnetname}-fw'
var fwpolicyname = '${nameprefix}-${location}-fw-policy'
var fwpipname = '${vnetname}-fw-pip'
var fwprefixname = '${vnetname}-fw-ipprefix'
var vwanname = '${nameprefix}-vwan'
var vhubname = '${nameprefix}-vhub-${vwanlocation}'
var vhubfwname = '${vhubname}-fw'
var vhubfwpolicyname = '${nameprefix}-${vwanlocation}-fw-policy'
var vhubvpngwname = '${vhubname}-vpn-gw'

resource hubrg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${nameprefix}-hubvnet-rg'
  location: vwanlocation
}

resource vwanrg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${nameprefix}-vwan-rg'
  location: location
}

module vnet './vnet.bicep' = {
  name: vnetname
  scope: hubrg
  params: {
    vnetname: vnetname
    location: location
    addressprefix: '10.0.0.0/20'
    serversubnetprefix: '10.0.0.0/24'
    bastionsubnetprefix: '10.0.1.0/24'
    firewallsubnetprefix: '10.0.2.0/24'
    gatewaysubnetprefix: '10.0.3.0/24'
  }
}

module vpngw './vnetvpngw.bicep' = {
  name: 'vpngw-deploy'
  scope: hubrg
  params: {
    location: location
    vpngwname: vpngwname
    subnetref: vnet.outputs.subnets[2].id
    vpngwpipname: vpngwpipname
    asn: 65010
  }
}

module fwpolicy './azfwpolicy.bicep' = {
  name: 'fwpolicy-deploy'
  scope: hubrg
  params: {
    policyname: fwpolicyname
    location: location
  }
}

module fwpip './azfwpip.bicep' = {
  name: 'pip-deploy'
  scope: hubrg
  params: {
    location: location
    pipname: fwpipname
    ipprefixlength: 31
    ipprefixname: fwprefixname
  }
}

module fw './azfw.bicep' = {
  name: 'fw-deploy'
  scope: hubrg
  params: {
    location: location
    fwname: fwname
    fwtype: 'VNet'
    fwpolicyid: fwpolicy.outputs.id
    publicipid: fwpip.outputs.id
    subnetid: vnet.outputs.subnets[3].id
  }
}

module vwan './vwan.bicep' = {
  name: 'vwan-deploy'
  scope: vwanrg
  params: {
    location: vwanlocation
    wanname: vwanname
    wantype: 'Standard'
  }
}

module vhub './vhub.bicep' = {
  name: 'vhub-deploy'
  scope: vwanrg
  params: {
    location: vwanlocation
    hubname: vhubname
    hubaddressprefix: '10.10.0.0/24'
    wanid: vwan.outputs.id
  }
}

module vhubfwpolicy './azfwpolicy.bicep' = {
  name: 'vhubfwpolicy-deploy'
  scope: vwanrg
  params: {
    policyname: vhubfwpolicyname
    location: vwanlocation
  }
}

module vhubfw './azfw.bicep' = {
  name: 'vhubfw-deploy'
  scope: vwanrg
  params: {
    location: vwanlocation
    fwname: vhubfwname
    fwtype: 'vWAN'
    hubid: vhub.outputs.id
    hubpublicipcount: 1
    fwpolicyid: vhubfwpolicy.outputs.id
  }
}

module vhubvpngw './vhubvpngw.bicep' = {
  name: 'vhubvpngw'
  scope: vwanrg
  params: {
    location: vwanlocation
    hubvpngwname: vhubvpngwname
    hubid: vhub.outputs.id
    asn: 65515
  }
}

module vwanvpnsite './vwanvpnsite.bicep' = {
  name: 'vwanvpnsite-deploy'
  scope: vwanrg
  params: {
    vpnsitename: '${location}-vpnsite'
    location: vwanlocation
    addressprefix: vnet.outputs.vnetaddress[0]
    bgppeeringpddress: vpngw.outputs.vpngwbgpaddress
    ipaddress: vpngw.outputs.vpngwip
    remotesiteasn: vpngw.outputs.bgpasn
    wanid: vwan.outputs.id
  }
}

module vhubs2s './vhubvpngwcon.bicep' = {
  name: 'vhubs2s-deploy'
  scope: vwanrg
  params: {
    hubvpngwname: vhubvpngw.outputs.name
    psk: psk
    vpnsiteid: vwanvpnsite.outputs.id
  }
}

module vnets2s './vnetsitetosite.bicep' = {
  name: 'vnets2s-deploy'
  scope: hubrg
  params: {
    location: location
    localnetworkgwname: lgwname
    addressprefixes: [
      vhub.outputs.vhubaddress
    ]
    connectionname: vpnconname
    bgppeeringpddress: vhubvpngw.outputs.gwprivateip
    gwipaddress: vhubvpngw.outputs.gwpublicip
    remotesiteasn: vhubvpngw.outputs.bgpasn
    psk: psk
    vpngwid: vpngw.outputs.id
  }
}
