// Private Dns Zone bicep module
metadata name = 'Private DNS Zone bicep module.'

metadata description = 'This module helps create a Private DNS zone resource and links the virtual networks with the resource to successfully resolve the private endpoints for the specific resource type.'

import { VirtualNetwork } from '../utilities.bicep'

@allowed([
  'privatelink.azconfig.io'
  'privatelink.azurewebsites.net'
  'privatelink.azurecr.io'
  #disable-next-line no-hardcoded-env-urls
  'privatelink.blob.core.windows.net'
  'privatelink.cosmos.azure.com'
  #disable-next-line no-hardcoded-env-urls
  'privatelink.database.windows.net'
  #disable-next-line no-hardcoded-env-urls
  'privatelink.file.core.windows.net'
  #disable-next-line no-hardcoded-env-urls
  'privatelink.queue.core.windows.net'
  #disable-next-line no-hardcoded-env-urls
  'privatelink.table.core.windows.net'
  'privatelink.servicebus.windows.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.search.windows.net'
  'privatelink.datfactory.azure.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.eventhub.azure.net'
])
@description('Name of the Private DNS Zone to be created.')
param name string

@description('Optional. Tags to be applied to the Private DNS Zone resource,')
param tags object = {}

@description('List of virtual Networks to be linked with the Private DNS Zone.')
param virtualNetworks VirtualNetwork[]

var vnet = [
  for each in virtualNetworks: resourceId(
    each.?subscriptionId ?? subscription().subscriptionId,
    each.?resourceGroup ?? resourceGroup().name,
    'Microsoft.Network/virtualNetworks',
    each.name
  )
]

// create Private Dns Zone resource
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {}
  resource vnetLink 'virtualNetworkLinks' = [
    for (each, i) in virtualNetworks: {
      name: 'link-${each.name}'
      location: 'global'
      properties: {
        registrationEnabled: false
        virtualNetwork: {
          id: vnet[i]
        }
      }
    }
  ]
}

//outputs
@description('Resource Id of the Private DNS zone created by the module.')
output id string = dnsZone.id

@description('Name of the private DNS zone created.')
output name string = dnsZone.name
