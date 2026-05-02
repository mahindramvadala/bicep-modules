metadata name = 'Key Vault RBAC bicep module.'

metadata description = '''
- This module creates Role (RBAC) Assignments on the key vault for a service principal or a group or a user.
- It can be consumed in your bicep file to simplify creation of role assignments on the key vault.
- For the role assignments related to entra id user, it uses the Bicep graph extension to get the object id of the provided user.
- For the role assignments related to Entra ID group or Service principal such as EntraID application or Managed identity, it uses the Microsoft Graph API based script to get the object id.
- Optionally, for the role assignments related to a Service principal (such as managed identity or Entra ID Application), you can also provide the principalId if the corresponding resource is being deployed through Bicep along with the kv role assignments.
'''

import { RoleAssignment } from '../utilities.bicep'

@description('Name of the key vault on which the role assignment needs to be made.')
param keyVaultName string

@description('Role Assignments to be made on the key vault.')
param roleAssignments RoleAssignment[]

var roleDefinitionGuid = {
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Certificates Officer': 'a4417e6f-fecd-4de8-b567-7b0420556985'
  'Key Vault Certificate User': 'db79e9a7-68ee-4b58-9aeb-b90e7c24fcba'
  'Key Vault Crypto Officer': '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  'Key Vault Crypto Service Encryption User': 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
  'Key Vault Crypto User': '12338af0-0e69-4776-bea7-57ae8d297424'
  'Key Vault Data Access Administrator': '8b54135c-b56d-4d72-a534-26097cfdc8d8'
  'Key Vault Secrets Officer': 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
}

module entridprincipal '../EntraIDObject/module.bicep' = [
  for (each, i) in roleAssignments! ?? []: if (!empty(each.?principalName ?? '')) {
    params: {
      principalName: each.?principalName
      principalType: each.?principalType
    }
  }
]

// Get key vault resource
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

// Create RBAC assignment on KV
resource kv_roleassignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (each, i) in roleAssignments! ?? []: {
    name: !empty(each.?principalId ?? '') && !empty(each.?principalName ?? '')
      ? fail('You can only use either "principalId" and "principalName" property but cannot specify both of them.')
      : empty(each.?principalId ?? '') && empty(each.?principalName ?? '')
          ? fail('You must specify either "principalId" or "principalName" property.')
          : startsWith(toLower(each.roleName), 'key')
              ? guid(keyVaultName, each.roleName, each.?principalId ?? each.?principalName ?? 'foobar')
              : fail('Only Key Vault specific role definitions are allowed.')
    scope: kv
    properties: {
      principalId: each.?principalId ?? entridprincipal[i].?outputs.id
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        roleDefinitionGuid[each.roleName]
      ) //roleDefinitions(each.roleName).id
      principalType: each.principalType
      condition: each.?condition
      conditionVersion: each.?conditionVersion
      description: each.?description
    }
  }
]

//output roleAssignmentIds string[] = [for (each, i) in roleAssignments: rbac[i].id]
