metadata name = 'User Assigned Managed Identity'

metadata description = 'This module creates a User Assigned Managed Identity resource.'

import {nameBuilder} from '../utilities.bicep'

@description('The location of the User-assigned managed identity resource. If not specified, the location of the resource group will be used.')
param location string?

@description('The suffix to append to the name of the User-assigned managed identity resource.')
param nameSuffix string

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' = {
  name: nameBuilder('managedIdentity', nameSuffix)
  location: location ?? resourceGroup().location
  properties: {
    isolationScope: 'None'
  }
}

// outputs
@description('Client ID of the User-assigned managed identity.')
output clientId string = uami.properties.clientId

@description('Resource ID of the User-assigned managed identity.')
output id string = uami.id

@description('Name of the User-assigned managed identity resourc created by the module.')
output name string = uami.name

@description('Principal ID of the User-assigned managed identity.')
output principalId string = uami.properties.principalId
