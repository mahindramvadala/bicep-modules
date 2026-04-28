extension msgraph

param apiPermissions ApiPermission[]

param name string

@secure()
param clientSecretName string

var appId = {
  'Dynamics CRM': '0000000700000000c000000000000000'
  'Dynamics ERP': '0000001500000000c000000000000000'
}

var crmDelegatedPermissionId = {
  user_impersonation: '78ce3f0fa1ce49c28cde64b5c0896db4'
}

var erpDelegatedPermissionId = {
  'AX.FullAccess': '6397893c2260496ba41d2f1f15b16ff3'
  'CustomService.FullAccess': 'ad8b4a5ceecd431aa46f33c060012ae1'
  'Odata.FullAccess': 'a849e696ce45464a81dee5c5b45519c1'
}

var resourceAccess = [
  for each in apiPermissions: map(each.?permissions, permission => {
    id: each.appName == 'Dynamics CRM'
      ? crmDelegatedPermissionId[permission.?name]
      : erpDelegatedPermissionId[permission.?name]
    type: permission.type == 'Delegated' ? 'Scope' : 'Role'
  })
]

resource appreg 'Microsoft.Graph/applications@v1.0' = {
  displayName: name
  uniqueName: name
  passwordCredentials: !empty(clientSecretName)
    ? [
        {
          displayName: clientSecretName
        }
      ]
    : []
  requiredResourceAccess: [
    for (each, i) in apiPermissions: !empty(apiPermissions)
      ? {
          resourceAppId: appId[each.?appName]
          resourceAccess: resourceAccess[i]
        }
      : any(null)
  ]
}

output clientId string = appreg.appId

output objectId string = appreg.id

output clientsecret string = !empty(clientSecretName) ? appreg.passwordCredentials[0].secretText : ''

output varResourceAccess array = resourceAccess

output flattenVarResourceAccess array = flatten(resourceAccess)

@discriminator('appName')
type ApiPermission = crmApiPermissions | erpApiDelegatedPermissions

type crmApiPermissions = {
  appName: 'Dynamics CRM'
  permissions: [
    {
      type: 'Delegated'?
      name: 'user_impersonation'?
    }
  ]?
}

type erpApiDelegatedPermissions = {
  appName: 'Dynamics ERP'
  permissions: {
    type: 'Delegated'?
    name: 'AX.FullAccess' | 'CustomService.FullAccess' | 'Odata.FullAccess'?
  }[]?
}
