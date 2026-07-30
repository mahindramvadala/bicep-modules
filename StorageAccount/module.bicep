metadata name = 'Storage Account Bicep module'

metadata description = '''
Deploys a Storage Account with secure defaults: HTTPS-only traffic, TLS 1.2 minimum, disabled public blob access, and AAD-scoped cross-tenant copy operations. Supports optional private endpoints per service sub-resource (blob, file, queue, table, dfs), IP and virtual network firewall rules, and RBAC role assignments.
'''

import { ResourceFirewallRules, RoleAssignment, nameBuilder } from '../utilities.bicep'

@description('Private endpoint configuration for a storage account service sub-resource.')
type StoragePrivateEndpoint = {
  @description('Optional. RG where the private endpoint will be deployed. Defaults to the RG of the storage account.')
  rgName: string?
  @description('Name of the subnet where the private endpoint is deployed.')
  subnetName: string
  @description('Name of the virtual network where the private endpoint subnet exists.')
  vnetName: string
  @description('Optional. RG where the VNET resides. Defaults to the RG of the private endpoint.')
  vnetRGName: string?
  @description('Storage service sub-resource to expose via the private endpoint.')
  groupId: ('blob' | 'file' | 'queue' | 'table' | 'dfs')
}

@description('Optional. Azure region where the resource needs to be deployed. Defaults to the location of the resource group.')
param location string?

@description('Name suffix of the storage account.')
param nameSuffix string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Storage account SKU.')
param sku string

@description('Optional. Indicates the type of storage account. Defaults to StorageV2.')
param kind ('StorageV2' | 'BlobStorage' | 'BlockBlobStorage' | 'FileStorage') = 'StorageV2'

@description('Optional. Access tier for the storage account. Applies to BlobStorage and StorageV2 kinds. Defaults to Hot.')
param accessTier ('Hot' | 'Cool' | 'Cold') = 'Hot'

@description('Optional. Tags to be applied to the storage account resource.')
param tags object?

@description('Optional. Private endpoint configurations for storage account service sub-resources.')
param privateEndpoints StoragePrivateEndpoint[]?

@description('Optional. List of IP addresses to whitelist for public network access to the storage account.')
param ipRules string[]?

@description('Optional. Virtual network rules for the storage account.')
param virtualNetworkRules ResourceFirewallRules?

@description('Optional. Azure role assignments to be applied on the storage account.')
param roleAssignments RoleAssignment[]?

var dnsZoneNameMap = {
  #disable-next-line no-hardcoded-env-urls
  blob: 'privatelink.blob.core.windows.net'
  #disable-next-line no-hardcoded-env-urls
  file: 'privatelink.file.core.windows.net'
  #disable-next-line no-hardcoded-env-urls
  queue: 'privatelink.queue.core.windows.net'
  #disable-next-line no-hardcoded-env-urls
  table: 'privatelink.table.core.windows.net'
  #disable-next-line no-hardcoded-env-urls
  dfs: 'privatelink.dfs.core.windows.net'
}

var storageRoleDefinitionIds = {
  'Storage Blob Data Owner': 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage Blob Data Reader': '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  'Storage Queue Data Contributor': '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  'Storage Queue Data Reader': '19e7f393-937e-4f77-808e-94535e297925'
  'Storage Queue Data Message Processor': '8a0f0c08-91a1-4084-bc3d-661d67233fed'
  'Storage Queue Data Message Sender': 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
  'Storage Table Data Contributor': '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  'Storage Table Data Reader': '76199698-9eea-4c19-bc75-cec21354c6b6'
  'Storage Table Delegator': 'acb5a2e5-2b21-4559-8d44-4e2d4d94d5a8'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = [
  for each in virtualNetworkRules ?? []: {
    name: '${each.vnetName}/${each.subnetName}'
    scope: resourceGroup(each.?vnetRGName ?? resourceGroup().name)
  }
]

resource sa 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: nameBuilder('storageAccount', nameSuffix)
  location: location ?? resourceGroup().location
  tags: tags
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: !empty(privateEndpoints ?? []) && empty(ipRules) && empty(virtualNetworkRules)
      ? 'Disabled'
      : 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: empty(ipRules) && empty(virtualNetworkRules) && empty(privateEndpoints) ? 'Allow' : 'Deny'
      ipRules: [
        for each in ipRules ?? []: {
          value: each
          action: 'Allow'
        }
      ]
      virtualNetworkRules: [
        for (each, i) in virtualNetworkRules ?? []: {
          id: subnet[i].id
          action: 'Allow'
        }
      ]
    }
  }
}

resource pe_dns_zones 'Microsoft.Network/privateDnsZones@2024-06-01' existing = [
  for each in privateEndpoints ?? []: {
    name: dnsZoneNameMap[each.groupId]
    scope: resourceGroup()
  }
]

module storage_pe '../PrivateEndpoint/module.bicep' = [
  for (each, i) in privateEndpoints ?? []: {
    name: 'DeployPrivateEndpoint_${sa.name}_${each.groupId}'
    scope: resourceGroup(each.?rgName ?? resourceGroup().name)
    params: {
      location: location ?? resourceGroup().location
      groupId: each.groupId
      nameSuffix: '${sa.name}-${each.groupId}'
      privateLinkServiceId: sa.id
      subnetName: each.subnetName
      tags: tags ?? {}
      privateDnsZoneIds: [
        pe_dns_zones[i].?id!
      ]
      vnetName: each.vnetName
      vnetRGName: each.?vnetRGName ?? resourceGroup().name
    }
  }
]

module entra_principals '../EntraIDObject/module.bicep' = [
  for (each, i) in roleAssignments ?? []: if (!empty(each.?principalName ?? '')) {
    params: {
      principalName: each.?principalName
      principalType: each.principalType
    }
  }
]

resource sa_roleassignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (each, i) in roleAssignments ?? []: {
    name: !empty(each.?principalId ?? '') && !empty(each.?principalName ?? '')
      ? fail('You can only use either "principalId" or "principalName" but cannot specify both.')
      : empty(each.?principalId ?? '') && empty(each.?principalName ?? '')
          ? fail('You must specify either "principalId" or "principalName".')
          : guid(sa.name, each.roleName, each.?principalId ?? each.?principalName ?? 'foobar')
    scope: sa
    properties: {
      principalId: each.?principalId ?? entra_principals[i].?outputs.id
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        storageRoleDefinitionIds[each.roleName]
      )
      principalType: each.principalType
      condition: each.?condition
      conditionVersion: each.?conditionVersion
      description: each.?description
    }
  }
]

@description('Resource ID of the storage account.')
output id string = sa.id

@description('Name of the storage account.')
output name string = sa.name

@description('Primary blob service endpoint of the storage account.')
output primaryBlobEndpoint string = sa.properties.primaryEndpoints.blob
