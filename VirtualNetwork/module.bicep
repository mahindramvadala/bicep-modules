targetScope = 'resourceGroup'

import { VirtualNetworkSubnet, Lock, nameBuilder } from '../utilities.bicep'

@description('Optional. Specify whether the location alias should be added to the resource naming convention. Defaults to false.')
param addLocationAliasToName false | true = false

@description('Address space of the VNET resource.')
param cidr string

import { diagnosticSettingFullType } from 'br/public:avm/utl/types/avm-common-types:0.7.0'
@description('Optional. Enable diagnostic settings')
param diagnosticSettings diagnosticSettingFullType[]?

@description('Optional. Ddos Protection Plan details. To associate a ddos protection plan to the virtual network. This is only valid if the enableDddosProtectionPlan is set to true.')
param ddosProtectionPlan {
  @description('Optional. Name of the DDos Protection Plan resource.')
  name: string?

  @description('Optional. Resource Group where the ddos protection plan resource is deployed. Chose this if the rg is different than the one where VNET is being deployed.')
  resourceGroup: resourceInput<'Microsoft.Resources/resourceGroups@2024-11-01'>.name?

  @description('Optioanal. Subscription Guid. This is only needed if the plan is deployed in a subscription different than the one where the VNET is being deployed.')
  subscriptionId: resourceInput<'Microsoft.Subscription/subscriptionDefinitions@2017-11-01-preview'>.properties.subscriptionId?
}?

@description('Optional. Custom DNS servers to be used by the VNET. Defaults to Azure provided DNS.')
param dnsServers string[]?

@description('Optional. If true, ddos protection plan needs to be associated. To attach a plan to VNET, ddosProtectionPlan should not be empty.')
param enableDdosProtectionPlan bool = false

@description('Optional. If true, encryption will be enabled. This is only for the traffic betweens the VMs of the selective SKUsnthat are deployed within the VNet. Defaults to false.')
param enableEncryption bool = false

@description('Optional. Specify the lock settings for the resource.')
param lock Lock?

@description('Optional. Azure region where the VNET will be created. Defaults to location of resource group.')
param location resourceInput<'Microsoft.Network/virtualNetworks@2024-05-01'>.location = resourceGroup().location

/*
@description('Optional. Name of the log analytics workspace that is used to store the diagnostic settings of the VNET.')
param logAnalyticsWorkspaceName resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.name?

@description('Optional. Name of the Resource group where the log analytics workspace was deployed. Defaults to rg where the VNET will be created.')
param logAnalyticsWorkspaceRGName resourceInput<'Microsoft.Resources/resourceGroups@2024-11-01'>.name = resourceGroup().name
*/

@description('Name suffix of the Virtual Network resource being created. \'vnet-\' will be as the prefix.')
param nameSuffix string

@description('Optional. Subnets to be created. Defaults to [].')
param subnets VirtualNetworkSubnet[] = []

@description('Optional. Tags to be applied to the resource.')
param tags object?

// get DDOS protection resource
resource ddosPlan 'Microsoft.Network/ddosProtectionPlans@2023-09-01' existing = if (enableDdosProtectionPlan && !empty(ddosProtectionPlan)) {
  name: ddosProtectionPlan.?name ?? 'dummy'
  scope: resourceGroup(
    ddosProtectionPlan.?subscriptionId ?? subscription().id,
    ddosProtectionPlan.?resourceGroup ?? resourceGroup().name
  )
}

/*
// Get log analytics workspace
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  name: logAnalyticsWorkspaceName ?? 'dummy'
  scope: resourceGroup(logAnalyticsWorkspaceRGName)
}
*/

var locationAlias = addLocationAliasToName ? location : null

//@onlyIfNotExists()
// create vnet
resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: nameBuilder('virtualNetwork', nameSuffix, locationAlias)
  location: location
  tags: tags
  properties: {
    dhcpOptions: {
      dnsServers: dnsServers ?? []
    }
    encryption: {
      enabled: enableEncryption
    }
    addressSpace: {
      addressPrefixes: [
        cidr
      ]
    }
    ddosProtectionPlan: enableDdosProtectionPlan && !empty(ddosProtectionPlan)
      ? {
          id: enableDdosProtectionPlan && !empty(ddosProtectionPlan) ? ddosPlan.id : 'dummy'
        }
      : null
    enableDdosProtection: enableDdosProtectionPlan
    subnets: [
      for (each, i) in subnets ?? []: {
        name: each.?name
        properties: {
          addressPrefix: each.?addressPrefix
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
          routeTable: each.?routeTable
          privateEndpointNetworkPolicies: each.?privateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: each.?privateLinkServiceNetworkPolicies
          serviceEndpoints: each.?serviceEndpoints
          defaultOutboundAccess: each.?defaultOutboundAccess ?? false
        }
      }
    ]
  }
}

// config diagnostic settings
resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for each in diagnosticSettings ?? []: {
    name: each.?name ?? 'DiagnosticSettings'
    scope: vnet
    properties: {
      logAnalyticsDestinationType: each.?logAnalyticsDestinationType
      workspaceId: each.?workspaceResourceId
      storageAccountId: each.?storageAccountResourceId
      logs: [
        for log in each.?logCategoriesAndGroups ?? [{ categoryGroup: 'allLogs' }]: {
          enabled: log.?enabled ?? true
          category: log.?category
          categoryGroup: log.?categoryGroup
        }
      ]
      metrics: [
        for met in each.?metricCategories ?? [{ category: 'AllMetrics' }]: {
          category: met.?category
          enabled: met.?enabled ?? true
        }
      ]
    }
  }
]

// Configure locking on the VNET resource
@description('Optional. Enable or disbaling lock.')
resource vnet_lock 'Microsoft.Authorization/locks@2020-05-01' = if (lock != null) {
  name: lock.?name ?? 'BicepLock'
  properties: {
    level: lock.?level ?? 'NotSpecified'
    notes: lock.?notes
  }
}

//outputs
@description('Resource Id of the virtual network deployed by the module.')
output id string = vnet.id

@description('Name of the VNET deployed.')
output name string = vnet.name

@description('RG where the vnet is deployed.')
output rg string = resourceGroup().name

@description('Resource ID of the subnets deployed by the module.')
output subnets VirtualNetworkSubnetOutputObject[] = [
  for (each, i) in subnets ?? []: {
    id: vnet.properties.subnets[i].id
    name: vnet.properties.subnets[i].name
  }
]

type VirtualNetworkSubnetOutputObject = {
  id: string
  name: string
}
