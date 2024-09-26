# ARM template usage to create 2 circuits:

# parameters to create 2 circuits on provider
$parameters = @{
    # circuit 1 parameters:
    circuit1Location          = "eastus"
    circuit1Name              = "circuit1"
    circuit1SkuTier           = "Standard"
    circuit1SkuFamily         = "MeteredData"
    circuit1BandwidthInMbps   = 1000
    circuit1ProviderName      = "AT&T Netbond"
    circuit1PeeringLocation   = "Amsterdam"
    # circuit 2 parameters:
    circuit2Location          = "eastus"
    circuit2Name              = "circuit2"
    circuit2SkuTier           = "Standard"
    circuit2SkuFamily         = "MeteredData"
    circuit2BandwidthInMbps   = 2000
    circuit2ProviderName      = "AT&T Netbond"
    circuit2PeeringLocation   = "Amsterdam"
}

# parameters to create 2 circuits on direct ports
$parameters = @{
    # circuit 1 parameters:
    circuit1Location             = "eastus"
    circuit1Name                 = "circuit1"
    circuit1SkuTier              = "Standard"
    circuit1SkuFamily            = "MeteredData"
    circuit1DirectId             = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRoutePorts/<portName>"
    circuit1BandwidthInGbps      = 1
    circuit1DirectEnableRateLimiting = $true
    # circuit 2 parameters:
    circuit2Location             = "eastus"
    circuit2Name                 = "circuit2"
    circuit2SkuTier              = "Standard"
    circuit2SkuFamily            = "MeteredData"
    circuit2DirectId             = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRoutePorts/<portName2>"
    circuit2BandwidthInGbps      = 1
    circuit2DirectEnableRateLimiting = $true
}

New-AzResourceGroupDeployment -Name "circuitdeployment" `
                              -ResourceGroupName "<rgName>" `
                              -TemplateFile .\NewAzHighAvailabilityExpressRouteCircuitsARMTemplate.json `
                              -TemplateParameterObject $parameters

# Usage of arm template to deploy 2 connections
$parameters = @{
    # Gateway parameters:
    location                        = "francecentral"                             
    virtualNetworkGatewayId1        = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/virtualNetworkGateways/erVng_migrated"  
    # connection 1 parameters:
    connectionName1                = "connection1"                 
    routingWeight1                 = 10                             
    expressRouteGatewayBypass1     = $false                             
    expressRouteId1                = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRouteCircuits/providercircuit1" 
    # connection 2 parameters:
    connectionName2                = "connection2"                     
    routingWeight2                 = 20                                
    expressRouteGatewayBypass2     = $false                            
    expressRouteId2                = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRouteCircuits/providercircuit2"  
}

$resourceGroupName = "<rgName>"
New-AzResourceGroupDeployment -Name "connectiondeployment" `
                              -ResourceGroupName "<rgName>" `
                              -TemplateFile .\NewHighAvailabilityVirtualNetworkGatewayConnectionsARMTemplate.json `
                              -TemplateParameterObject $parameters