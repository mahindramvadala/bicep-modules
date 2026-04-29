using './module.bicep'

/*
Param file to test/scan the module using PSRules
This example shows deploying private endpoint for a key vault resource (all values are dummy values)
*/

param groupId = 'vault'
param nameSuffix = 'kv-dummy'
param privateDnsZoneId = 'dummy' //'/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroup/ps-rule-test-rg/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param privateLinkServiceId = 'dummy' //'/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroup/ps-rule-test-rg/Microsoft.KeyVault/vaults/kv-dummy'
param subnetName = 'snet-dummy'
param vnetName = 'vnet-dummy'
//param vnetRGName = 'rg-network-dummy' //Optional
//param tags = {} // Optional
