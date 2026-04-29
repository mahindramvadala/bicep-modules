using './module.bicep'

// Test param file to scan the module using PSRules with default options

param nameSuffix = 'mahi-demo'
param securityRules = [] //This ensures only built-in rules are created.

// Below example shows how to add custom rules to the NSG rules apart from the built-in rules

/*
param securityRules = [
  // Use ctrl+space to activate intellisense on required properties (and optional)
  {
    name: 'DenyEverythingOutbound'
    access: 'Deny'
    destinationAddressPrefix: '*'
    destinationPortRange: '*'
    direction: 'Outbound'
    priority: 4096
    protocol: '*'
    sourceAddressPrefix: '*'
    // Ctrl+space to use the optional property.
    description: 'Deny All Outbound from the Subnet(s) for which the NSG is associated.'
  }
  // Use ctrl+space to add more elements (rules in this case).
]
*/

//Below are optional parameters are only needed if the default value of these parameters are not the ones you need for your requirement.
// param location = resourceGroup().location //Optional. For example: param location = 'canadacentral'
//param tags = {} //Optional. For example:

/*
param tags = {
  env: Sandbox
  costCenter: 0000
}
*/
