// Retrieves the virtual network resource ID from the subnet resource ID
@description('Gets the virtual network resource ID from the subnet resource ID')
@export()
func getVirtualNetworkIdFromSubnetId(subnetId string) string => join(take(split(subnetId, '/'), 9), '/')

// Retrieves the virtual network name from the subnet resource ID
@description('Gets the virtual network resource ID from the subnet resource ID')
@export()
func getVirtualNetworkNameFromSubnetId(subnetId string) string => split(subnetId, '/')[8]

