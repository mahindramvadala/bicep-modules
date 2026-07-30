/*
module mlw 'MLWorkspace/module.bicep' = {
  params: {
    appInsightsName: 'appi-sat-ai'
    keyVaultName: 'kv-sat-ai'
    nameSuffix: 'mahi-lavada4'
    storageAccountName: 'stsatai'
    managedVirtualNetwork: {
      isolationMode: 'AllowInternetOutbound'
      kind: 'V2'
      outboundRules: [
        {
          name: 'search-mgd-pep'
          properties: {
            destination: {
              serviceResourceId: resourceId('Microsoft.Search/searchServices', 'srch-sat-ai')
              subresourceTarget: 'searchService'
            }
            type: 'PrivateEndpoint'
            category: 'UserDefined'
          }
        }
      ]
    }
  }
}

param mlName string = 'mlw-mahi-latest'

resource orule 'Microsoft.MachineLearningServices/workspaces/managedNetworks/outboundRules@2026-03-15-preview' = {
  name: '${mlName}/default/search-managed-endpoint'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: resourceId('Microsoft.Search/searchServices', 'srch-sat-ai')
      subresourceTarget: 'searchService'
    }
    category: 'UserDefined'
  }
}

*/

param nameSuffix string = 'satvai'

var dnsZones = [
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.core.windows.net'
  'privatelink.file.core.windows.net'
]

module dnszones 'PrivateDnsZone/module.bicep' = [
  for each in dnsZones: {
    params: {
      name: each
      virtualNetworks: [
        {
          name: vnet.outputs.name
        }
        {
          name: 'vnet-sat-hub'
          resourceGroup: 'rg-hub'
        }
      ]
    }
  }
]

module vnet 'VirtualNetwork/module.bicep' = {
  params: {
    cidr: '10.100.0.0/24'
    nameSuffix: nameSuffix
    peerings: [
      {
        name: 'spoke-hub'
        peerCompleteVnets: true
        remoteVnetName: 'vnet-sat-hub'
        remoteVnetRGName: 'rg-hub'
        useRemoteGateways: true
      }
    ]
    subnets: [
      {
        name: 'snet-pep'
        addressPrefix: '10.100.0.0/26'
      }
      {
        name: 'snet-ai'
        addressPrefix: '10.100.0.64/26'
        defaultOutboundAccess: true
        //delegation: 'Microsoft.App/environments'
      }
    ]
  }
}

module kv 'KeyVault/module.bicep' = {
  dependsOn: [
    dnszones
  ]
  params: {
    sku: 'standard'
    nameSuffix: nameSuffix
    privateEndpoint: {
      subnetName: vnet.outputs.subnets[0].name
      vnetName: vnet.outputs.name
    }
  }
}

module sa 'StorageAccount/module.bicep' = {
  dependsOn: [
    dnszones
  ]
  params: {
    sku: 'Standard_LRS'
    nameSuffix: nameSuffix
    privateEndpoints: [
      {
        groupId: 'blob'
        subnetName: vnet.outputs.subnets[0].name
        vnetName: vnet.outputs.name
      }
      {
        groupId: 'file'
        subnetName: vnet.outputs.subnets[0].name
        vnetName: vnet.outputs.name
      }
    ]
  }
}

/*
module mlw_managed 'MLWorkspace/module.bicep' = {
  dependsOn: [
    dnszones
  ]
  params: {
    appInsightsName: 'appi-sat-ml'
    keyVaultName: kv.outputs.name
    nameSuffix: 'mngd-${nameSuffix}'
    storageAccountName: sa.outputs.name
    allowPublicAccessWhenBehindVnet: false
    privateEndpoint: {
      subnetName: vnet.outputs.subnets[0].name
      vnetName: vnet.outputs.name
    }
    managedVirtualNetwork: {
      isolationMode: 'AllowInternetOutbound'
      kind: 'V1'
    }
    compute: [
      {
        name: 'managedmom'
        properties: {
          properties: {
            assignedUserObjectId: deployer().objectId
            vmSize: 'Standard_DS1_v2'
          }
          computeType: 'ComputeInstance'
        }
      }
    ]
  }
}
*/

module ml 'MLWorkspace/module.bicep' = {
  params: {
    appInsightsName: 'appi-sat-ml'
    keyVaultName: kv.outputs.name
    nameSuffix: nameSuffix
    storageAccountName: sa.outputs.name
    allowPublicAccessWhenBehindVnet: false
    privateEndpoint: {
      subnetName: vnet.outputs.subnets[0].name
      vnetName: vnet.outputs.name
    }
    compute: [
      {
        name: 'mom'
        properties: {
          properties: {
            assignedUserObjectId: deployer().objectId
            vmSize: 'Standard_DS1_v2'
            subnetId: vnet.outputs.subnets[1].id
          }
          computeType: 'ComputeInstance'
        }
      }
    ]
  }
}
