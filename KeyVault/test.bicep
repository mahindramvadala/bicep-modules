
param nameSuffix string = 'unittest'

test kv_std_default '../KeyVault/module.bicep' = {
  params: {
    sku: 'standard'
    nameSuffix: nameSuffix
  }
}

test kv_std_firewall_iprules '../KeyVault/module.bicep' = {
  params: {
    sku: 'standard'
    nameSuffix: nameSuffix
    ipRules: [
      '192.0.2.0/24'
    ]
  }
}

test kv_std_firewall_with_vnetRules '../KeyVault/module.bicep' = {
  params: {
    sku: 'standard'
    nameSuffix: nameSuffix
    virtualNetworkRules: [
      {
        subnetName: 'snet-demo'
        vnetName: 'vnet-demo-1'
      }
      {
        subnetName: 'snet-demo'
        vnetName: 'vnet-demo-2'
      }
    ]
  }
}

test kv_std_privateendpoint '../KeyVault/module.bicep' = {
  params: {
    sku: 'standard'
    nameSuffix: nameSuffix
    ipRules: [
      '192.0.2.0/24'
    ]
    privateEndpoint: {
      subnetName: 'snet-pep'
      vnetName: 'vnet-demo'
    }
  }
}

test kv_std_complete '../KeyVault/module.bicep' = {
  params: {
    sku: 'standard'
    nameSuffix: nameSuffix
    ipRules: [
    '192.0.2.0/24'
    ]
    privateEndpoint: {
      subnetName: 'snet-pep-demo'
      vnetName: 'vnet-demo'
    }
    roleAssignments: [
      {
        principalName: 'CLGROUP-DEMO'
        principalType: 'Group'
        roleName: 'Key Vault Administrator'
      }
    ]
    virtualNetworkRules: [
      {
        subnetName: 'snet-demo'
        vnetName: 'vnet-demo'
      }
    ]
  }
}
