using './module.bicep'

// Test param file to scan the module using PSRules with default options

param enablePurgeProtection = false

param nameSuffix = 'mahi-dummy'
param sku = 'standard'

param roleAssignments = [
  {
    principalName: 'CLGROUP-MAHI-DUMMY'
    principalType: 'Group'
    roleName: 'Key Vault Administrator'
  }
  {
    principalType: 'ServicePrincipal'
    roleName: 'Key Vault Administrator'
    principalName: 'mi-mahi-dummy' //Name of uami or sami resource
  }
  /*
  // This element serves an example for assigning a key vault data plane permission to a user within the organization. best practice is to use group assignments.
  {
    principalName: 'foo@bar.com'
    principalType: 'User'
    roleName: 'Key Vault Administrator'
  }
  */
]

/*
// Optional. Only needed if private endpoint needs to be setup. By Default, module does not create private endpoint

param privateEndpoint = {
  subnetName: 'snet-pep-mahi-dummy'
  vnetName: 'vnet-mahi-dummy'
}
*/

/*
// Optional. Only needed if a subnet or subnets needed to be allowed to access the kv using Service endpoint
param virtualNetworkRules = [
  {
    subnetName: 'snet-mahi-func-dummy'
    vnetName: 'vnet-mahi-dumy'
    //vnetRGName: 'rg-mahi-other-dummy' //Needed if VNET resides in a rg other than the kv rg.
  }
  // Additional subnet elements
]
*/

/*
// Optional. Only needed if you want to allow specific IP addresses (public) to access the subnet resource
param ipRules = [
  '76.79.239.186' // Example IP address
  // Additional Public IP addresses that you want to be whitlisted if any
]
*/
