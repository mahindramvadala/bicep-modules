resource mlw 'Microsoft.MachineLearningServices/workspaces@2026-03-15-preview' existing = {
  name: 'mlw-mahi-lavada2'
}

/*
resource orule 'Microsoft.MachineLearningServices/workspaces/outboundRules@2026-03-15-preview' = {
  name: 'satsearch'
  parent: mlw
  properties: {
    type: 'PrivateEndpoint'
    category: 'UserDefined'
    destination: {
      serviceResourceId: resourceId('Microsoft.Search/searchServices', 'srch-sat-ai')
      sparkEnabled: true
      subresourceTarget: 'searchService'
    }
  }
}
*/


