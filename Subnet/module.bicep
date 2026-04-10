// import custom data type for subnets
import { VirtualNetworkSubnet } from '../utilities.bicep'

@description('Subnets to be created. Use ctrl + space to know the available properties offered by the custom data type.')
param subnets VirtualNetworkSubnet[]

@description('Name of the VNET where the subnet(s) need to be created.')
param virtualNetworkName resourceInput<'Microsoft.Network/virtualNetworks@2025-05-01'>.name

@description('Create subnets within the specified virtula Network')
resource snet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = [
  for (each, i) in subnets: {
    name: '${virtualNetworkName}/${each.name}'
    properties: {
      addressPrefix: each.name
      delegations: each.?delegation != null
        ? [
            {
              name: each.?delegation
              properties: {
                serviceName: each.?delegation
              }
            }
          ]
        : []
      natGateway: each.?natGateway
      networkSecurityGroup: each.?networkSecurityGroup
      defaultOutboundAccess: each.?defaultOutboundAccess ?? true
      privateEndpointNetworkPolicies: each.?privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: each.?privateLinkServiceNetworkPolicies
      routeTable: each.?routeTable
      serviceEndpoints: each.?serviceEndpoints
    }
  }
]

// outputs
@description('List of resource Ids of the subnets that were created.')
output id string[] = [for (each, i) in subnets: snet[i].id]

@description('List of names of the subnets that were created.')
output name string[] = [for (each, i) in subnets: snet[i].name]

output rg string = resourceGroup().name
