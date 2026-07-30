import { Identity } from '../utilities.bicep'

@sys.description('Name of the foundry account where the project needs to be created.')
param accountName string

@sys.description('Capability host config.')
param capabililyHost capabilityHostType

@sys.description('Optional. Description for the project.')
param description string?

@sys.description('Optional. Identity type. Defaults to system assigned.')
param identity Identity?

@sys.description('Optional. Region of the project. Defaults to the location of the resource group (or foundry account).')
param location string?

@sys.description('Name of the project')
param name string

@sys.description('Get the foundry account resource.')
resource foundry_account 'Microsoft.CognitiveServices/accounts@2026-03-01' existing = {
  name: accountName
  scope: resourceGroup()
}

@sys.description('Create projects within Foundry account using the parameter "projects".')
resource foundry_projects 'Microsoft.CognitiveServices/accounts/projects@2026-03-01' = {
  name: name
  parent: foundry_account
  location: location ?? resourceGroup().location
  identity: identity ?? {
    type: 'SystemAssigned'
  }
  properties: {
    description: description
    displayName: name
  }
  resource caphost 'capabilityHosts' = if(capabililyHost.enabled == 'Yes') {
    name: '${name}-caphost'
    properties: capabililyHost.?properties
  }
}

@discriminator('enabled')
type capabilityHostType = disableCapabilityHost | enableCapabilityHost

type enableCapabilityHost = {
  @sys.description('Enable or disable capabillity host.')
  enabled: 'Yes'
  @sys.description('Connections to be used.')
  properties: {
  aiServicesConnections: string[]?
  storageConnections: string[]
  threadStorageConnections: string[]
  vectorStoreConnections: string[]
}
}

type disableCapabilityHost = {
  @sys.description('Enable or disable capabillity host.')
  enabled: 'No'
}
