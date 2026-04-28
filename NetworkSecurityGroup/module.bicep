// Bicep module to create network security group (NSG) resource.

import { NetworkSecurityGroupRule } from '../utilities.bicep'

@description('Optional. Azure region where the NSG resource will be created. Defaults to the resource group location.')
param location string?

@description('Name suffix of the network security group resource that needs to be created. "nsg-" will be added as the prefix by the module.')
param nameSuffix string

@description('List of security rules to apply to the NSG. Accepts [] as the value to create the NSG with the default security rules.')
param securityRules NetworkSecurityGroupRule[]

@description('Optiomal. Tags applied to the NSG resource.')
param tags object?

// create NSG resource
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: !startsWith(nameSuffix, 'nsg-')
    ? 'nsg-${nameSuffix}'
    : fail('Parameter nameSuffix must not start with "nsg-". the prefix nsg- will be added by the module.')
  location: location ?? resourceGroup().location
  tags: tags
  properties: {
    flushConnection: true
    securityRules: [
      for each in securityRules: {
        name: each.?name
        properties: {
          access: each.?access
          direction: each.?direction
          priority: each.?priority
          protocol: each.?protocol
          sourceAddressPrefixes: contains(each.?sourceAddressPrefix, ',')
            ? array(split(each.?sourceAddressPrefix, ','))
            : []
          sourceAddressPrefix: !contains(each.?sourceAddressPrefix, ',') ? each.?sourceAddressPrefix : null
          description: each.?description ?? null
          destinationAddressPrefixes: contains(each.?destinationAddressPrefix, ',')
            ? array(split(each.?destinationAddressPrefix, ','))
            : []
          destinationAddressPrefix: !contains(each.?destinationAddressPrefix, ',')
            ? each.?destinationAddressPrefix
            : null
          destinationPortRange: !contains(each.?destinationPortRange, ',') ? each.?destinationPortRange : null
          destinationPortRanges: contains(each.?destinationPortRange, ',')
            ? array(split(each.?destinationPortRange, ','))
            : []
          sourcePortRange: '*'
        }
      }
    ]
  }
}

// outputs
@description('Resource ID of the network security group created by the module.')
output id string = nsg.id

@description('Name of the network security group resource that was provisioned.')
output name string = nsg.name
