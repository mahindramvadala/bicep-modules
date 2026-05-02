using './module.bicep'

// Test param file to scan the module using PSRules with default options

param nameSuffix = 'mahi-foobar'
param sku = 'standard'

/*
// Optional.
param roleAssignments = [
  {
    principalName: 'clgroup-foobar'
    //principalId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    principalType: 'Group'
    roleName: 'Key Vault Administrator'
  }
  {
    principalName: 'foobar-app'
    principalType: 'ServicePrincipal'
    roleName: 'Key Vault Administrator'
    //principalId: 'ffffffff-ffff-ffff-ffff-ffffffffffff' //PrincipalId of uami or sami resource
  }
  // This element serves an example for assigning a key vault data plane permission to a user within the organization. best practice is to use group assignments.
  {
    //principalId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    principalType: 'User'
    roleName: 'Key Vault Administrator'
    principalName: 'foo@bar.com'
  }
]
*/
/*
// Optional. Only needed if private endpoint needs to be setup. By Default, module does not create private endpoint

param privateEndpoint = {
  subnetName: 'snet-dummy'
  vnetName: 'vnet-dummy'
}
*/

/*
// Optional. Only needed if a subnet or subnets needed to be allowed to access the kv using Service endpoint
param virtualNetworkRules = [
  {
    subnetName: 'snet-func-dummy'
    vnetName: 'vnet-dumy'
    //vnetRGName: 'rg-other-dummy' //Needed if VNET resides in a rg other than the kv rg.
  }
  // Additional subnet elements
]
*/

/*
// Optional. Only needed if you want to allow specific IP addresses (public) to access the subnet resource
param ipRules = [
  '192.0.2.0/24' // Example IP addresses
  // Additional Public IP addresses that you want to be whitlisted if any
]
*/
