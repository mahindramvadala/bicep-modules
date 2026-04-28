using './module.bicep'

// Test bicepparam file with default values for the optional parameters.

param principalType = 'User'

param principalName = 'foo@bar.com'

/*
// To retrieve Object ID of the Entra ID group

param principalType = 'Group'

param principalName = 'CLGROUP-FOOBAR'
*/


/*
// To retrieve object ID of the Entra ID Service Principal (Application or Managed identity)

param principalType = 'ServicePrincipal'

param principalName = 'FOOBAR-App'
*/
