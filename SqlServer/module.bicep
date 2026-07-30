metadata name = 'Sql Server bicep module'

metadata description = 'This module deploys an Azure SQL Server instance.'

import { nameBuilder, Identity, VirtualNetworkRules, PrivateEndpoint } from '../utilities.bicep'

@description('Optional. Create mode of the SQL Server. Defaults to Normal.')
param createMode 'Normal' | 'Restore'?

@description('Optional. Name of the Entra ID group to be assigned as the SQL administrator.')
param entraIdGroupName string?

@description('Optional. Managed identity to be assigned to the SQL Server. If not provided, no managed identity will be assigned.')
param identity Identity?

@description('''
- Optional. List of Public Ips or CIDR ranges to allow access to the SQL Server. If not provided, no public access will be allowed.
- For example:
  [
    '192.0.2.0/24'
  ]
''')
param ipRules string[]?

@description('Optional. Azure region where the SQL Server will be deployed. Defaults to the location of the resource group where the resource is deployed.')
param location string?

@description('Optional. Private endpoint configuration for the SQL Server. If not provided, no private endpoint will be created.')
param privateEndpoint PrivateEndpoint?

@description('Name suffix of the Sql server.')
param nameSuffix string = 'sat-ai'

@description('Optional. List of virtual network rules to allow access to the SQL Server. If not provided, no virtual network access will be allowed. Specificed subnets must have Microsoft.Sql service endpoint enabled.')
param vnetRules VirtualNetworkRules?

var resourceName = nameBuilder('sqlDatabaseServer', nameSuffix)

@description('Retrieve virtual network subnet resources.')
resource sqlserver_firewall_snet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' existing = [
  for each in vnetRules! ?? []: {
    name: '${each.?vnetName}/${each.?subnetName}'
    scope: resourceGroup(
      each.?vnetSubscriptionId ?? subscription().subscriptionId,
      each.?vnetRGName ?? resourceGroup().name
    )
  }
]

module entra_group '../EntraIDObject/module.bicep' = if (!empty(entraIdGroupName ?? '')) {
  params: {
    principalName: entraIdGroupName!
    principalType: 'Group'
  }
}

@description('Create an Azure SQL Server.')
resource sql_server 'Microsoft.Sql/servers@2025-02-01-preview' = {
  name: resourceName
  location: location ?? resourceGroup().location
  identity: identity
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      tenantId: tenant().tenantId
      sid: entra_group.?outputs.?id ?? deployer().objectId
      principalType: !empty(deployer().?userPrincipalName ?? '') ? 'User' : 'ServicePrincipal'
      login: !empty(entraIdGroupName ?? '')
        ? entraIdGroupName!
        : !empty(deployer().?userPrincipalName ?? '') ? deployer().?userPrincipalName : deployer().objectId
    }
    createMode: createMode ?? 'Normal'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: !empty(ipRules ?? []) || !empty(vnetRules ?? []) ? 'SecuredByPerimeter' : 'Disabled'
    retentionDays: -1
    isIPv6Enabled: 'Disabled'
    primaryUserAssignedIdentityId: null
    restrictOutboundNetworkAccess: 'Disabled'
  }
  resource firewall_rules 'firewallRules' = [
    for (each, i) in ipRules! ?? []: {
      name: '${i}'
      properties: {
        startIpAddress: parseCidr(each).firstUsable
        endIpAddress: parseCidr(each).lastUsable
      }
    }
  ]
  resource vnet_rules 'virtualNetworkRules' = [
    for (each, i) in vnetRules! ?? []: {
      name: 'Allow_subnet_${i}'
      properties: {
        virtualNetworkSubnetId: sqlserver_firewall_snet[i].id
        ignoreMissingVnetServiceEndpoint: false
      }
    }
  ]
  resource outbound_firewall_rules 'outboundFirewallRules' = {
    name: 'D'
  }
}

module sqlserver_privatendpoint '../PrivateEndpoint/module.bicep' = if (!empty(privateEndpoint) ?? {}) {
  scope: resourceGroup(privateEndpoint.?rgName ?? resourceGroup().name)
  params: {
    groupId: 'sqlServer'
    nameSuffix: sql_server.name
    privateDnsZoneIds: [
      #disable-next-line no-hardcoded-env-urls
      resourceId('Microsoft.Network/privateDnsZones', 'privatelink.database.windows.net')
    ]
    privateLinkServiceId: sql_server.id
    subnetName: privateEndpoint.?subnetName!
    vnetName: privateEndpoint.?vnetName!
  }
}
