module vnet 'VirtualNetwork/module.bicep' = {
  params: {
    cidr: '10.1.0.0/24'
    nameSuffix: 'mahindra-snapshot-demo'
  }
}
