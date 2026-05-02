using './module.bicep'

// Test param file to scan the module using PSRules with default options

param keyVaultName = 'kv-mahi-foobar'

param roleAssignments = [
  {
    principalType: 'User'
    roleName: 'Key Vault Administrator'
    principalName: 'foo@bar.com'
    //principalId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
  }
  //
]
