using './module.bicep'

// Test param file for PSRule scanning

param keyVaultName = 'kv-dummy'
param roleAssignments = [
  {
    principalName: 'foo@bar.com'
    principalType: 'User'
    roleName: 'Key Vault Secrets User'
  }
  // ctrl +space to add another assignment element
]
