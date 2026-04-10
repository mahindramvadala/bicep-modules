

resource sa 'Microsoft.Storage/storageAccounts@2025-08-01' = {
  name:
  location: 
  sku: {
    name: 
  }
  kind: 
  properties: {
    networkAcls: {
      defaultAction: 
      virtualNetworkRules: [
        {
          id: ''
          action: 'Allow'
        }
      ]
    }
  }
}
