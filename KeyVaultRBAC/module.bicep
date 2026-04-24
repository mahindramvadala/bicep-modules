metadata name = 'Key Vault RBAC bicep module.'

metadata description = '''
- This module creates Role (RBAC) Assignments on the key vault for a service principal or a group or a user.
- It can be consumed in your bicep file to simplify creation of role assignments on the key vault.
- For the role assignments related to entra id user, it uses the Bicep graph extension to get the object id of the provided user.
- For the role assignments related to Entra ID group or Service principal such as EntraID application or Managed identity, it uses the Microsoft Graph API based script to get the object id.
- Optionally, for the role assignments related to a Service principal (such as managed identity or Entra ID Application), you can also provide the principalId if the corresponding resource is being deployed through Bicep along with the kv role assignments.
'''

extension msgraph

import { RoleAssignment, roleAssignmentName } from '../utilities.bicep'

@description('Name of the key vault on which the role assignment needs to be made.')
param keyVaultName string

@description('Role Assignments to be made on the key vault.')
param roleAssignments RoleAssignment[]

var roleAssignmentGuid string[] = [
  for each in roleAssignments: roleAssignmentName(
    keyVaultName,
    each.roleName,
    each.principalType,
    each.?principalName,
    each.?principalId
  )
]

// Get key vault resource
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

@description('Retrieve the object Ids from Entra ID for the provided principals.')
module entraid_object '../EntraIDObjectRetrieve/module.bicep' = [
  for (each, i) in roleAssignments: if(empty(each.?principalId ?? '')) {
    name: 'GetEntraObjectId_${replace(trim(each.principalName), '@', '')}'
    params: {
      principalName: each.?principalName
      principalType: each.principalType
    }
  }
]

// Create RBAC assignment on KV
resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (each, i) in roleAssignments: {
    name: startsWith(toLower(trim(each.roleName)), 'key vault')
      ? roleAssignmentGuid[i]
      : fail('Only Key Vault specific role definitions are allowed.')
    scope: kv
    properties: {
      principalId: each.?principalId ?? entraid_object[i].?outputs.id
      roleDefinitionId: roleDefinitions(each.roleName).id
      principalType: each.principalType
      condition: each.?condition
      conditionVersion: each.?conditionVersion
      description: each.?description
    }
  }
]

output roleAssignmentIds string[] = [for (each, i) in roleAssignments: rbac[i].id]
