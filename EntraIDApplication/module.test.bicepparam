using './module.bicep'

// Test param file to scan the module using PSRules with default options

param apiPermissions = []

// Below snippet shows how to configure API permissions for the Entra ID App being created.

/*
param apiPermissions = [
  // Use ctrl+space to activate intellise and populate the allowed values with required and optional properties offered by the data type the param uses.
  {
    appName: 'Dynamics CRM'
    permissions: [
      {
        name: 'user_impersonation'
        type: 'Delegated'
      }
    ]
  }
  {
    appName: 'Dynamics ERP'
    permissions: [
      {
        name: 'AX.FullAccess'
        type: 'Delegated'
      }
      {
        name: 'CustomService.FullAccess'
        type: 'Delegated'
      }
      {
        name: 'Odata.FullAccess'
        type: 'Delegated'
      }
    ]
  }
]
*/
param name = '#_dummy_#'
param clientSecretName = '' //Does not create a secret

// below snippet is an illustration on how to create secret along with the app.
//param clientSecretName = 'test bicep module secret'
