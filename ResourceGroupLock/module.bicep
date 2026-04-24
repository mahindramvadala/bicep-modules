metadata name = 'Resource Group Lock Bicep Module'

metadata description = 'This module provides the ability to apply CanNotDelete lock at the resource group to prevent accidental deletion of resources within it.'

@description('Optional. The level of the lock to be applied. Default is CanNotDelete.')
param level 'CanNotDelete' | 'ReadOnly'?

@description('Optional. Name of the lock being applied at the resource group level.')
param name string?

@maxLength(512)
@description('Optional. Notes about the lock.')
param notes string?

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: name ?? 'bicep-lock'
  properties: {
    level: level ??'CanNotDelete'
    notes: notes ?? 'Prevents accidental deletion of resources within the resource group.'
  }
}
