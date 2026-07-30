using './module.bicep'

// Test param file to scan the module using PSRules with default options

param nameSuffix = 'mahi-foobarr'
param sku = 'Standard_LRS'
param kind = 'StorageV2'
param accessTier = 'Hot'

/*
// Optional: Role assignments on the storage account
param roleAssignments = [
  {
    principalName: 'clgroup-foobar'
    principalType: 'Group'
    roleName: 'Storage Blob Data Contributor'
  }
  {
    principalName: 'foobar-app'
    principalType: 'ServicePrincipal'
    roleName: 'Storage Blob Data Reader'
    //principalId: 'ffffffff-ffff-ffff-ffff-ffffffffffff' // Principal ID of a managed identity or Entra ID application
  }
  {
    principalType: 'User'
    roleName: 'Storage Blob Data Reader'
    principalName: 'foo@bar.com'
  }
]

// Optional: IP firewall rules
param ipRules = [
  '203.0.113.10'
]

// Optional: Virtual network firewall rules
param virtualNetworkRules = [
  {
    subnetName: 'snet-default'
    vnetName: 'vnet-spoke-dev'
  }
]

// Optional: Private endpoints per storage sub-resource
param privateEndpoints = [
  {
    groupId: 'blob'
    subnetName: 'snet-privateendpoints'
    vnetName: 'vnet-spoke-dev'
  }
  {
    groupId: 'file'
    subnetName: 'snet-privateendpoints'
    vnetName: 'vnet-spoke-dev'
  }
]
*/
