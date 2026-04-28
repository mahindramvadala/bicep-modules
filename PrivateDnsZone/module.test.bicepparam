using './module.bicep'

param name = 'privatelink.azconfig.io'

/*
param tags = {} //Optional. Only needed if tags need to be associated to the resource using Bicep
*/

param virtualNetworks = [] // If empty, no vnet will be linked to the Private DNS zone

/*
// Value for the param virtualNetworks should be like this in case vnet(s) need to be linked.

param virtualNetworks = [
  {
    name: 'vnet-mahi-dummy'
    //resourceGroup: 'vnet-mahi-dummy-rg' //Optional. Needed if VNET resides in a different rg than the private dns zone resource.
    //subscriptionId: '00000000-0000-0000-0000-000000000000' //Optional. Only needed if vnet resides in a different subscription than the private dns zone resource.
  }
  // further elements in the array (if any) based on the requirement
]
*/
