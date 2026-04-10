
metadata name = 'Key Vault Bicep module'

metadata description = 'Deploys a Key Vault with Private endpoint, firewall rules and access policies depending on the user input.'

extension msgraph

// import user-defined types from types.bicep
import { KeyVaultAccessPolicy, PrivateEndpoint, ResourceFirewallRules, nameBuilder } from '../utilities.bicep'

@description('Optional. Specify whether the location alias should be added to the resource naming convention. Defaults to false.')
param addLocationAliasToName false | true = false

@description('Optional. Access policies to be created on the key vault.')
param accessPolicies KeyVaultAccessPolicy[]?

@description('Optional. Vault\'s create mode to indicate whether the vault need to be recovered or not. Only needed if the vault needs to be recovered from the soft delete state. Defaults to false. ')
param recoverVault true | false = false

@allowed([
  false
  true
])
@description('If true, enables purge protection for the key vault.')
param enablePurgeProtection bool

@description('Optional. Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored. When false, the key vault will use the access policies. Defaults to `true`.')
param enableRbacAuth false | true = true

@description('Optional. List (or array) of IP addresses to be whitelisted to access the key vault via public network.')
param ipRules string[]?

@description('Optional. Azure region where the resource needs to be deployed. Defaults to location of the resource group where the key vault will be deployed.')
param location string?

@description('Name suffix of the key vault.')
param nameSuffix string

@allowed([
  'standard'
  'premium'
])
@description('Key vault SKU.')
param sku string

@minValue(7)
@maxValue(90)
@description('Optional. Soft delete retention in days. Defaults to 7 days.')
param softDeleteRetentionInDays int = 7

@description('Optional. Tags to be applied to the key vault resource.')
param tags object?

@description('Optional. Private endpoint configuration.')
param privateEndpoint PrivateEndpoint?

@description('Optional. Virtual Network rules to be applied to the resource so that the resources within the subnet can access the resource via Public network access using Service endpoint.')
param virtualNetworkRules ResourceFirewallRules?

@description('Var to enforce location alias as a part of the resource name.')
var locationAlias string? = addLocationAliasToName ? location : null

resource dns_zone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = if (privateEndpoint != null) {
  name: 'privatelink.vaultcore.azure.net'
  scope: resourceGroup()
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = [
  for each in virtualNetworkRules! ?? []: {
    name: '${each.?vnetName}/${each.subnetName}' ?? 'dummy/dummy'
    scope: resourceGroup(each.?vnetRGName ?? resourceGroup().name)
  }
]

// create key vault resource
resource kv 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: nameBuilder('keyVault', nameSuffix, locationAlias)
  location: location ?? resourceGroup().location
  tags: tags
  properties: {
    createMode: !recoverVault ? 'default' : 'recover'
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    enablePurgeProtection: enablePurgeProtection ? true : null
    enableRbacAuthorization: enableRbacAuth
    tenantId: subscription().tenantId
    publicNetworkAccess: (!empty(privateEndpoint) && empty(ipRules) && empty(virtualNetworkRules))
      ? 'Disabled'
      : 'Enabled'
    accessPolicies: [
      for each in accessPolicies! ?? []: {
        tenantId: subscription().tenantId
        objectId: each.?objectId
        permissions: each.?permissions
      }
    ]
    softDeleteRetentionInDays: softDeleteRetentionInDays
    sku: {
      name: sku
      family: 'A'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: empty(ipRules) && empty(virtualNetworkRules) && empty(privateEndpoint) ? 'Allow' : 'Deny'
      ipRules: [
        for each in ipRules ?? []: {
          value: each
        }
      ]
      virtualNetworkRules: [
        for (each, i) in virtualNetworkRules ?? []: {
          id: subnet[i].id
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
  }
}

// create private endpoint
module pe '../PrivateEndpoint/module.bicep' = if (privateEndpoint != null) {
  name: 'DeployPrivateEndpoint_${kv.name}'
  scope: resourceGroup(privateEndpoint.?rgName ?? resourceGroup().name)
  params: {
    location: location
    groupId: 'vault'
    nameSuffix: kv.name
    privateLinkServiceId: kv.id
    subnetName: privateEndpoint.?subnetName!
    tags: tags
    privateDnsZoneId: dns_zone.?id!
    vnetName: privateEndpoint.?vnetName!
    vnetRGName: privateEndpoint.?vnetRGName
  }
}

//outputs
@description('Resource Id of the key vault deployed by private endpoint.')
output id string = kv.id

@description('Name of the key vault where the private endpoint deployed by the module.')
output name string = kv.name
