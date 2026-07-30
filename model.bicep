
param accountName string  = 'aif-satva'

resource aif 'Microsoft.CognitiveServices/accounts@2026-03-01' existing = {
  name: accountName
}
resource gpt_54_nano_model 'Microsoft.CognitiveServices/accounts/deployments@2026-03-01' = {
  name: 'gpt-5.4-nano'
  parent: aif
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
   properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5.4-nano'
      version: '2026-03-17'
      publisher: 'OpenAI'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    serviceTier: 'Default'
   }
}
