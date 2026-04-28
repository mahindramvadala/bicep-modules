using './module.bicep'

/*

Param file to test/scan the module using PSRules

Assumes deploying private endpoint for a key vault (dummy resource)

*/

param groupId = 'vault'
param nameSuffix = 'kv-mahi-dummy'
param privateDnsZoneId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroup/rg-mahi-dummy/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param privateLinkServiceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroup/rg-mahi-dummy/Microsoft.KeyVault/vaults/kv-mahi-dummy'
param subnetName = 'snet-mahi-dummy-pep'
param vnetName = 'vnet-mahi-dummy'
//param vnetRGName = 'rg-mahi-dummy' //Optional
//param tags = {} // Optional
