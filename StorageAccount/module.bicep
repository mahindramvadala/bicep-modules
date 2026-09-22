import { nameBuilder } from '../utilities.bicep'

param accessTier string?

param enableHierarchicalNamespace false | true?

param enableSftp false | true?

//param ipRules resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.networkAcls.ipRules?

param kind resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.kind?

//param resourceAccessRules resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.networkAcls.resourceAccessRules?

//param virtualNetworkRules resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.networkAcls.virtualNetworkRules?

param nameSuffix string

param networkAcls {
  ipRules: object[]
  virtualNetworkRules: object[]
}?

param privateEndpoint {
  subnetName: string
  virtualNetworkName: string
  virtualNetworkRGName: string?
  rgName: string?
  groupId: ('blob' | 'file' | 'queue' | 'table' | 'dfs' | 'web')[]
}?

param sku resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.sku.name?

var name = nameBuilder('storageAccount', nameSuffix)

var privateDnsZone = {
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
  #disable-next-line no-hardcoded-env-urls
  web: 'privatelink.web.core.windows.net'
}

resource pritave_dns_zone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = [
  for each in privateEndpoint.?groupId ?? []: {
    name: privateDnsZone[each]
    scope: resourceGroup()
  }
]

resource storage_account 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: sku ?? 'Standard_LRS'
  }
  kind: kind ?? 'StorageV2'
  properties: {
    #disable-next-line BCP036
    accessTier: accessTier ?? 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    allowSharedKeyAccess: false
    isHnsEnabled: enableHierarchicalNamespace ?? false
    publicNetworkAccess: !empty(privateEndpoint ?? {}) && (empty(networkAcls.?ipRules ?? []) && empty(networkAcls.?virtualNetworkRules ?? [])) ?'Disabled' : 'Enabled' //!empty(privateEndpoint ?? {}) && (empty(union(this.existingResource().?properties.networkAcls.ipRules ?? [], networkAcls.?ipRules ?? [])) || empty(union(this.existingResource().?properties.networkAcls.virtualNetworkRules ?? [], networkAcls.?virtualNetworkRules ?? []))) ? 'Disabled' : 'Enabled'
    networkAcls: {
      defaultAction: !empty(networkAcls.?ipRules ?? []) || !empty(networkAcls.?virtualNetworkRules ?? []) ? 'Deny' : 'Allow' /*((empty(union(
          this.existingResource().?properties.networkAcls.virtualNetworkRules ?? [],
          networkAcls.?virtualNetworkRules ?? []
        )) && empty(union(this.existingResource().?properties.networkAcls.ipRules ?? [], networkAcls.?ipRules ?? []))) && empty(privateEndpoint ?? {}))
        ? 'Allow'
        : 'Deny'
        */
      bypass: 'AzureServices'
      ipRules: networkAcls.?ipRules ?? [] //union(this.existingResource().?properties.?networkAcls.?ipRules ?? [], networkAcls.?ipRules ?? [])
      virtualNetworkRules: networkAcls.?virtualNetworkRules ?? [] /*union(
        this.existingResource().?properties.networkAcls.virtualNetworkRules ?? [],
        networkAcls.?virtualNetworkRules ?? []
      )
      */
    }
    dnsEndpointType: 'Standard'
    supportsHttpsTrafficOnly: true
    routingPreference: {
      routingChoice: 'MicrosoftRouting'
    }
    isSftpEnabled: (enableHierarchicalNamespace ?? false) && (enableSftp ?? false) ? true : false
  }
}

@description('Create Private endpoint(s) for the Storage account.')
module storage_account_pep '../PrivateEndpoint/module.bicep' = [
  for (each, i) in privateEndpoint.?groupId ?? []: if (!empty(privateEndpoint ?? {})) {
    params: {
      groupId: each
      nameSuffix: storage_account.name
      privateDnsZoneIds: [
        pritave_dns_zone[i].id
      ]
      privateLinkServiceId: storage_account.id
      subnetName: privateEndpoint.?subnetName!
      vnetName: privateEndpoint.?virtualNetworkName!
    }
  }
]

//outputs
#disable-next-line no-explicit-any
output endpoints any = storage_account.properties.primaryEndpoints

output id string = storage_account.id

output name string = storage_account.name

output rg string = resourceGroup().name

@secure()
output primaryKey string = storage_account.listKeys().keys[0].value

@secure()
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};AccountKey=${storage_account.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
