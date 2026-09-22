/*
module vnet 'VirtualNetwork/module.bicep' = {
  params: {
    cidr: '10.0.0.0/24'
    nameSuffix: 'lavadaaa'
    subnets: [
      {
        name: 'pep-snet'
        addressPrefix: '10.0.0.0/27'
      }
      {
        name: 'default'
        addressPrefix: '10.0.0.32/27'
        serviceEndpoints: [
          {
            locations: [
              '*'
            ]
            service: 'Microsoft.Storage.Global'
          }
        ]
      }
    ]
  }
}

module sa 'StorageAccount/module.bicep' =  {
  params: {
    //sku: 'Standard_LRS'
    nameSuffix: 'lavadaaa'
    virtualNetworkRules: [
      {
        subnetName: 'default'
        vnetName: vnet.outputs.name
      }
    ]
    privateEndpoint: {
      groupId: [
        'blob'
      ]
      subnetName: 'pep-snet'
      virtualNetworkName: vnet.outputs.name
    }
  }
}
*/

param nameSuffix string = 'satvai2'

module sa 'StorageAccount/module.bicep' = {
  name: 'DeployStorageAccount'
  params: {
    accessTier: 'Hot'
    nameSuffix: nameSuffix
  }
}

module update_sa 'StorageAccount/module.bicep' = {
  params: {
    accessTier: 'Hot'
    nameSuffix: nameSuffix
    networkAcls: {
      ipRules: [
        {
          value: '142.126.208.12'
        }
      ]
      virtualNetworkRules: []
    }
  }
}
