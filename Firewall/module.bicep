//bicep module to deploy firewall rule collection group
//import * as GT from 'types.bicep'

targetScope = 'resourceGroup'

@description('Firewall policy where the rule collection group needs to be created.')
param firewallPolicyName string

@description('Firewall Rule Collection Group configuration.')
param ruleCollectionGroup FirewallPolicyRuleCollectionGroup

// create rule Collection Group within the Firewall policy
resource ruleCollectGrp 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2025-09-01' = {
  name: '${firewallPolicyName}/${ruleCollectionGroup.name}'
  properties: {
    priority: ruleCollectionGroup.priority
    ruleCollections: ruleCollectionGroup.?ruleCollections
  }
}

///////////////////////////////////////
///#### User-Defined data types ####///

@description('FirewallRuleCollectiongGroupObject')
type FirewallPolicyRuleCollectionGroup = {
  @description('Name of the Firewall Policy Rule Collection Group resource.')
  name: string

  @minValue(100)
  @maxValue(65000)
  @description('Priority of the Firewall Policy Rule Collection Group resource.')
  priority: int

  @description('Group of Firewall Policy rule collections.')
  ruleCollections: FirewallPolicyRuleCollection[]?
}

@description('FirewallPolicyRuleCollectionObject')
@discriminator('ruleCollectionType')
type FirewallPolicyRuleCollection = FirewallPolicyFilterRuleCollection | FirewallPolicyNatRuleCollection

@description('FirewallPolicyFirewallRuleCollectionObject')
type FirewallPolicyFilterRuleCollection = {

  @description('The action type of the Filter rule collection.')
  action: {
    type: ('Allow' | 'Deny')
  }

  @description('The name of the rule collection.')
  name: string

  @minValue(100)
  @maxValue(65000)
  @description('Priority of the Firewall Policy Rule Collection resource.')
  priority: int

  @description('List of rules included in a rule collection.')
  rules: FirewallPolicyRule[]

  @description('The type of the rule collection.')
  ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
}

@description('FirewallPolicyNatRuleCollectionObject')
type FirewallPolicyNatRuleCollection = {

  @description('The action type of the NAT rule collection.')
  action: {
    type: 'DNAT'
  }

  @description('The name of the rule collection.')
  name: string

  @minValue(100)
  @maxValue(65000)
  @description('Priority of the Firewall Policy Rule Collection resource.')
  priority: int

  @description('List of rules included in a rule collection.')
  rules: FirewallPolicyNatRule[]

  @description('The type of the rule collection.')
  ruleCollectionType: 'FirewallPolicyNatRuleCollection'
}

// Tagged union data type
@discriminator('ruleType')
type FirewallPolicyRule = FirewallPolicyApplicationRule | FirewallPolicyNetworkRule

@description('FirewallPolicyRuleCollectionNetworkRule')
type FirewallPolicyNetworkRule = {
  @description('Optional. Description of the rule.')
  description: string?

  @description('List of destination IP addresses or service tags.')
  destinationAddresses: string[]

  @description('Optional. List of destination FQDNs.')
  destinationFqdns: string[]?

  @description('Optional. List of destination IpGroups for this rule.')
  destinationIpGroups: string[]?

  @description('List of destination ports.')
  destinationPorts: string[]

  @description('List of Porocols to be allowed.')
  ipProtocols: ('Any' | 'TCP' | 'UDP')[]

  @description('Name of the rule.')
  name: string

  @description('Type of the firewall rule to be created.')
  ruleType: 'NetworkRule'

  @description('List of source IP addresses for this rule.')
  sourceAddresses: string[]

  @description('Optional. List of source IpGroups for this rule.')
  sourceIpGroups: string[]?
}

@description('FirewallPolicyRuleCollectionApplicationRule')
type FirewallPolicyApplicationRule = {
  @description('Optional. Description of the rule.')
  description: string?

  @description('Optional. List of destination IP addresses or service tags.')
  destinationAddresses: string[]?

  @description('Optional. List of FQDN tags for this rule.')
  fqdnTags: string[]

  @description('Optional. List of HTTP/S headers to insert.')
  httpHeadersToInsert: [
    {
      @description('Contains the name of the header.')
      headerName: string
      @description('Contains the value of the header.')
      headerValue: string
    }
  ]?

  @description('name of the rule.')
  name: string

  @description('List of the application protocols.')
  protocols: [
    {
      @minValue(0)
      @maxValue(64000)
      @description('Port number for the protocol.')
      port: int

      @description('Protocol type.')
      protocolType: ('Http' | 'Https')
    }
  ]

  @description('Type of the firewall rule to be created.')
  ruleType: 'ApplicationRule'

  @description('List of the source IP addresses for this rule.')
  sourceAddresses: string[]

  @description('Optional. List of source IpGroups for this rule.')
  sourceIpGroups: string[]?

  @description('Optional. List of FQDNs for this rule.')
  targetFqdns: string[]?

  @description('Optional. List of the URLs for this rule condition.')
  targetUrls: string[]?

  @description('Optional. Terninate TLS connections for this rule.')
  terminateTLS: bool?

  @description('Optional. List of destination azure web categories.')
  webCategories: string[]?
}

@description('FirewallPolicyRuleCollectionNatRule')
type FirewallPolicyNatRule = {

  @description('Optional. Description of the rule.')
  description: string?

  @description('Optional. List of destination IP addresses or service tags.')
  destinationAddresses: string[]?

  @description('List of the destination ports.')
  destinationPorts: string[]

  @description('Array of protocols to be allowed/denied.')
  ipProtocols: ('Any' | 'TCP' | 'UDP')[]

  @description('Name of the rule.')
  name: string

  @description('Type of the rule.')
  ruleType: 'NatRule'

  @description('List of source IP addresses for this rule.')
  sourceAddresses: string[]

  @description('Optional. List of source IpGroups for this rule.')
  sourceIpGroups: string[]?

  @description('Optional. Translated address for this NAT rule.')
  translatedAddress: string?

  @description('Optional. Translated FQDN for this NAT rule.')
  translatedFqdn: string?

  @description('Optional. Translated port for this NAT rule.')
  translatedPort: string?
}
