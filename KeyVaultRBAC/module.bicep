
extension msgraph

@description('Name of the key vault on which the role assignment needs to be made.')
param keyVaultName string

@description('Role Assignments to be made on the key vault.')
param roleAssignments RoleAssignment[]

var roleDefinitionGuid = {
  KeyVaultAdministrator: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  KeyVaultCertificateOfficer: 'a4417e6f-fecd-4de8-b567-7b0420556985'
  KeyVaultCertificateUser: 'db79e9a7-68ee-4b58-9aeb-b90e7c24fcba'
  KeyVaultCryptoOfficer: '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  KeyVaultCryptoServiceEncryptionUser: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
  KeyVaultCryptoUser: '12338af0-0e69-4776-bea7-57ae8d297424'
  KeyVaultDataAccessAdministrator: '8b54135c-b56d-4d72-a534-26097cfdc8d8'
  KeyVaultSecretOfficer: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  KeyVaultSecretUser: '4633458b-17de-408a-b874-0445c86b69e6'
}

// Get Role definition resource
resource role_definition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = [ for each in roleAssignments:  {
  name: roleDefinitionGuid[each.roleDefinitionName]
  scope: subscription()
}]

// Get key vault resource
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

@description('Gets the Entra ID group object')
resource group 'Microsoft.Graph/groups@v1.0' existing = [ for (each, i) in roleAssignments: if(each.principalType == 'Group') {
  uniqueName: each.?principalName! ?? 'dummy'
}]

@description('Gets the Entra ID user object.')
resource user 'Microsoft.Graph/users@v1.0' existing = [ for (each, i) in roleAssignments: if (each.principalType == 'User') {
  userPrincipalName: each.?principalName! ?? 'dummy'
}]

// Create RBAC assignment on KV
resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (each, i) in roleAssignments: {
    name: each.principalType == 'ServicePrincipal'? guid(kv.id, role_definition[i].id, each.principalId!) : guid(kv.id, role_definition[i].id, each.?principalName!)
    scope: kv
    properties: {
      principalId: each.principalType == 'ServicePrincipal' ? each.?principalId! : each.principalType == 'Group' ? group[i].?id! : user[i].?id!
      roleDefinitionId: role_definition[i].id
      principalType: each.principalType
      
    }
  }
]

@sealed()
type RoleAssignment = {
  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?
  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?
  @description('Optional. Description of the role assignment.')
  description: string?
  @description('Optional. Name (as GUID) of the role assignment. A guild will be generated if not explicitly provided.')
  name: string?
  @description('Name of the Role to be assigned for the user/group or servicePrincipal.')
  roleDefinitionName: ('KeyVaultAdministrator' | 'KeyVaultCertificateOfficer' | 'KeyVaultCertificateUser' | 'KeyVaultCryptoOfficer' | 'KeyVaultCryptoServiceEncryptionUser' | 'KeyVaultCryptoUser' | 'KeyVaultDataAccessAdministrator' | 'KeyVaultSecretOfficer' | 'KeyVaultSecretUser')
  @description('Optional. Principal/Object ID of the System (User-Assignmed) managed identity.')
  principalId: string?
  @description('Name of the EntraID group or user for which the role is being assigned.')
  principalName: string?
  @description('Type of the Principal for which the role is being assigned. If the prinicipal is a managed identity resource, it should be `ServicePrincipal`.')
  principalType: ('Group' | 'ServicePrincipal' | 'User')
}
