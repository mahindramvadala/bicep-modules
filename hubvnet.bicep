

module vnet 'VirtualNetwork/module.bicep' = {
  params: {
    cidr: '10.0.0.0/24'
    nameSuffix: 'sat-hub'
    gatewaySubnetAddressPrefix: '10.0.0.0/26'
    vpnClientAddressPoolPrefix: '172.16.0.0/24'
    peerings: [
      {
        name: 'hub-spoke'
        peerCompleteVnets: true
        remoteVnetName: 'vnet-satvai'
        remoteVnetRGName: 'rg-sat-mlworkspace'
        useRemoteGateways: false
      }
    ]
  }
}
