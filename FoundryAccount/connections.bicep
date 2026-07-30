metadata name = 'Bicep module to create Connections for a Foundry account.'

param connections Connections

param foundryAccountName string

resource foundry_account 'Microsoft.CognitiveServices/accounts@2026-01-15-preview' existing = {
  name: foundryAccountName
}

@batchSize(1)
@description('Connections to be created for the Foundry resource.')
resource foundry_connection 'Microsoft.CognitiveServices/accounts/connections@2025-12-01' = [
  for each in connections! ?? []: {
    name: each.?name
    parent: foundry_account
    properties: each.properties
  }
]

type Connections = {
  name: string
  properties: resourceInput<'Microsoft.CognitiveServices/accounts/connections@2025-12-01'>.properties
}[]

// outputs
@description('Names of the connections created through this module.')
output name string[] = [ for (each, i) in connections: foundry_connection[i].name ]

@description('Resource IDs of the connections created through this module.')
output id string[] = [ for (each, i) in connections: foundry_connection[i].id ]
