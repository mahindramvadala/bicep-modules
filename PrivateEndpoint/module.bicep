// Private Endpoint module

@description('Target sub-resource of the resource type for which the private endpoint will need to be created.')
param groupId string

@description('Optional. Azure region where the private endpoint will be deployed. Defaults to location of rg where the private endpoint resource is being deployed.')
param location string = resourceGroup().location

@description('Name suffix of the private endpoint. \'pe-\' gets added as the prefix.')
param nameSuffix string

@description('Resource Id of the private dns zone.')
param privateDnsZoneId string

@description('Target resource id for which the private endpoint needs to be configured.')
param privateLinkServiceId string

@description('Name of the subnet where the private endpoint will be deployed.')
param subnetName string

@description('Optional. Tags to be applied to private endpoint needs to be configured.')
param tags object = {}

@description('Name of the VNET where the private endpoint needs to be deployed.')
param vnetName string

@description('Optinal. RG where the VNET used by the private endpoint resides. Defaults to rg where the key vault resource is being deployed.')
param vnetRGName string = resourceGroup().name

// get subnet resource
resource pe_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: resourceGroup(vnetRGName)
}

// create Private Endpoint
resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: toLower('pe-${nameSuffix}')
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-pe-${nameSuffix}'
    privateLinkServiceConnections: [
      {
        name: toLower('pe-${nameSuffix}')
        properties: {
          groupIds: [
            groupId
          ]
          privateLinkServiceId: privateLinkServiceId
        }
      }
    ]
    subnet: {
      id: pe_subnet.id
    }
  }
  //register the private endpoint with the Private DNS zone
  resource peDnsZone 'privateDnsZoneGroups' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'registered_via_bicepmodule'
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
}

//outputs
@description('Resource Id of the private endpoint resource.')
output id string = pe.id

@description('Name of the private endpoint resource created by the module.')
output name string = pe.name
