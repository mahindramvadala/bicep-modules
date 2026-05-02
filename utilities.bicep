metadata name = 'Custom utilities for innersource Bicep modules'
metadata description = '''
  This module provides you with all the custom data types and functions that are being imported within the Bicep modules. You can also import them to your own Bicep files. The main purpose of this module is to avoid code duplication and provide a single source of truth for all the custom data types and functions used within the innersource Bicep modules.
'''

// =========================  //
// Private Endpoint Config    //
// ========================  //

@sealed()
@export()
@description('Data type that will be used by private endpoint paramater across the modules.')
type PrivateEndpoint = {
  /*
  @description('Name of the private dns zone to which the private endpoint will be registered. For example, key vault private endpoint will need to be registered with `prviatelink.vaultcore.azure.net`.')
  privateDnsZoneName: string
  @description('Optional. RG where the private dns zone resides. Defaults to the rg where the private endpoint is being deployed.')
  privateDnsZoneRGName: string?
  @description('Optional. Subscription id where the private dns zone exists. This is only needed if the privateDnsZone resource is in a subscription different than the one where the private endpoint is being deployed.')
  privateDnsZoneSubscriptionId: resourceInput<'Microsoft.Subscription/aliases@2025-11-01-preview'>.properties.subscriptionId?
  */
  @description('Optional. RG where the Private endpoint will be deployed. Defaults to the rg where the parent resource resides.')
  rgName: string?
  @description('Name of the subnet where the private endpoint is deployed.')
  subnetName: string
  @description('Name of the vnet where the private endpoint subnet exists.')
  vnetName: string
  @description('Optional. RG where the VNET resides. This is only needed if the vnet resides in a rg different than the one where the private endpoint will be deployed.')
  vnetRGName: string?
}

/*
@export()
@description('User-defined data type for enabling diagnostic settings on the supported resources')
type DiagnosticSettings = {
  @description('Name of the Diagnostic settings.')
  name: string?
  @description('Resource Id of the log analytics workspace.')
  workspaceResourceId: string?
  logs: {
    @description('Optional. Whether log is enabled or not. Default is true.')
    enabled: false | true?
    @description('Optional. Name of a Diagnostic Log category group for a resource type this setting is applied to. To obtain the list of Diagnostic Log categories for a resource, first perform a GET diagnostic settings operation. Set to`allLogs`  to collect all logs.')
    categoryGroup: string?
    @description('Optional. Name of a Diagnostic Metric category for a resource type this setting is applied to. To obtain the list of Diagnostic metric categories for a resource, first perform a GET diagnostic settings operation.')
    category: string?
    @sealed()
    retentionPolicy: {
      @minValue(0)
      @description('Number of days for the retention in days. A value of 0 will retain the events indefinitely.')
      days: int
      @description('Whether retention policy is enabled or not.')
      enabled: false | true
    }
  }
  metrics: {
    @description('Enable or disable the category explicitly. Default is true.')
    enabled: false | true?
    @description('Name of a Diagnostic Metric category for a resource type this setting is applied to. To obtain the list of Diagnostic metric categories for a resource, first perform a GET diagnostic settings operation. Set to `AllMetrics` to collect all metrics.')
    category: string
    retentionPolicy: {
      @minValue(0)
      @description('Number of days for the retention in days. A value of 0 will retain the events indefinitely.')
      days: int
      @description('Whether retention policy is enabled or not.')
      enabled: false | true
    }?
    @description('Optional. Metric timegrain in ISO format')
    timeGrain: string?
  }[]
}
*/

@export()
@description('''
Resource level firewall virtual network rules. This can be used as a parameter\'s data type within a bicep module to setup virtual network firewall rules on the resource that supports the configuration.
Example: [
  {
    subnetName: 'snet-default'
    vnetName: 'vnet-default'
  }
]
''')
type ResourceFirewallRules = {
  @description('Subnet that needs to access the resource\'s endpoint using Service endpoint. Ensure the subnet has appropriate Service Endpoint configured.')
  subnetName: string
  @description('VNET where the subnet resides.')
  vnetName: string
  @description('Optional. RG where the vnet resides. Defaults to the rg where the resource exists.')
  vnetRGName: string?
}[]

//  ==========================  //
//     Lock Type                //
//  ========================== //

@sealed()
@export()
@description('User-defined data type used by the locks parameter within the bicep modules.')
type Lock = {
  @description('Optional. Name of the lock')
  name: string?
  @description('Optional. Type of the lock being applied.')
  level: ('CanNotDelete' | 'ReadOnly' | 'NotSpecified')?
  @description('Optional. Notes about the lock.')
  notes: string?
}

//  ========================== //
//    Route Table Routes       //
//  ========================== //

@sealed()
@export()
@description('User-defined data type used by routes parameter within Route Table module.')
type RouteTableRoute = {
  @description('Name of the route.')
  name: string

  @description('Next Hop Type of the route.')
  nexHopType: ('Internet' | 'None' | 'VirtualAppliance' | 'VnetLocal' | 'VirtualNetworkGateway')

  @description('Destination address prefix of the route table.')
  addressPrefix: string

  @description('If the nextHopType is"VirtualAppliance", add the firewall IP address as the next hop IP address.')
  nextHopIpAddress: string?
}

//  ======================================== //
//    Firewall Policy Rule Collections       //
//  ======================================== //

@sealed()
@export()
@discriminator('ruleCollectionType')
type FirewallPolicyRuleCollection = FilterRuleCollection | NatRuleCollection

@sealed()
type FilterRuleCollection = {
  @description('Rule collection type.')
  ruleCollectionType: 'FirewallPolicyFilterRuleCollection'

  @description('he action type of a Filter rule collection.')
  action: {
    @description('Tyoe of the action.')
    type: ('Allow' | 'Deny')
  }

  @description('Name of the Rule Collection Group.')
  name: string

  @minValue(100)
  @maxValue(65000)
  priority: int

  @description('List of rules included in a rule collection.')
  rules: FirewallPolicyRule[]
}

@sealed()
type NatRuleCollection = {
  @description('Rule collection type.')
  ruleCollectionType: 'FirewallPolicyNatRuleCollection'

  @description('The action type of a Filter rule collection.')
  action: {
    @description('Type of the action.')
    type: 'DNAT'
  }

  @description('Name of the Rule Collection Group.')
  name: string

  @minValue(100)
  @maxValue(65000)
  priority: int

  @description('List of rules included in a rule collection.')
  rules: NatRuleType[]
}

@discriminator('ruleType')
type FirewallPolicyRule = NetworkRule | ApplicationRule

@sealed()
type NetworkRule = {
  ruleType: 'NetworkRule'
  description: string?
  destinationAddresses: array
  destinationFqdns: array?
  destinationIpGroups: array?
  destinationPorts: array
  ipProtocols: ('Any' | 'ICMP' | 'TCP' | 'UDP')[]
  name: string
  sourceAddresses: array
  sourceIpGroups: array?
}

@sealed()
type ApplicationRule = {
  ruleType: 'ApplicationRule'
  description: string?
  destinationAddresses: array
  fqdnTags: array
  httpHeadersToInsert: {
    headerName: string
    headerValue: string
  }[]
  name: string
  protocols: {
    @minValue(0)
    @maxValue(64000)
    port: int
    protocolType: ('Http' | 'Https')
  }
  targetFqdns: array
  targetUrls: array
  terminateTLS: (false | true)
  webCategories: array
  sourceAddresses: array
  sourceIpGroups: array?
}

@sealed()
type NatRuleType = {
  ruleType: 'NatRule'
  description: string?
  destinationAddresses: array
  destinationPorts: array
  ipProtocols: ('Any' | 'ICMP' | 'TCP' | 'UDP')[]
  name: string
  sourceAddresses: array
  sourceIpGroups: array?
  translatedAddress: string
  translatedFqdn: string?
  translatedPort: string
}

// ===================================    //
//   Virtual Network Subnet               //
// ==================================    //

@sealed()
@export()
@description('Custom data type used by the subnets parameter within the VNET module')
type VirtualNetworkSubnet = {
  @description('Name of the subnet to be created.')
  name: string
  @description('Address Prefix of the subnet.')
  addressPrefix: string
  @description('Optional. If false, default outbound connectivity for all VMs in the subnet will be disabled.')
  defaultOutboundAccess: (false | true)?
  @description('Optional. The name of the service to whom the subnet should be delegated (e.g. Microsoft.Web/serverFarms).')
  delegation: string?
  @description('Optional. Reference to the NAT gateway resource that will need to be associated with the subnet.')
  natGateway: {
    @description('Resource ID of the NAT Gateway.')
    id: string
  }?
  @description('Optional. NSG resource that will need to be associated with the subnet.')
  networkSecurityGroup: {
    id: string
  }?
  @description('Optional. Apply network policies for the private endpoints in the subnet.')
  privateEndpointNetworkPolicies: ('Enabled' | 'Disabled' | 'NetworkSecurityGroupEnabled' | 'RouteTableEnabled')?
  @description('Optional. Apply network policies on private link services in the subnet.')
  privateLinkServiceNetworkPolicies: ('Enabled' | 'Disabled')?
  @description('Optional. Route table resource that will need to be associated with the subnet.')
  routeTable: {
    id: string
  }?
  @description('Optional. Array of service endpoints.')
  serviceEndpoints: {
    @description('List of locations.')
    locations: ('CanadaCentral' | 'CanadaEast' | '*')[]
    @description('Service Endpoint Type.')
    service: (
      | 'Microsoft.AzureActiveDirectory'
      | 'Microsoft.KeyVault'
      | 'Microsoft.Storage'
      | 'Microsoft.Sql'
      | 'Microsoft.ServiceBus'
      | 'Microsoft.EventHub'
      | 'Microsoft.Web'
      | 'Microsoft.AzureCosmosDB'
      | 'Microsoft.ContainerRegistry'
      | 'Microsoft.ContainerServices'
      | 'Microsoft.Storage.Global')
  }[]?
}

// ===============================    //
//   Key Vault Access Policy          //
// ===============================    //

@sealed()
@export()
@description('User-defined data type used by the param named \'accessPolicies\' within key vault module.')
type KeyVaultAccessPolicy = {
  @description('Optional.The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.')
  objectId: string
  @description('Permissions the identity has for keys, secrets and certificates.')
  permissions: {
    @description('Permissions to certificates.')
    certificates: (
      | 'all'
      | 'backup'
      | 'create'
      | 'delete'
      | 'deleteissuers'
      | 'get'
      | 'getissuers'
      | 'import'
      | 'list'
      | 'listissuers'
      | 'managecontacts'
      | 'manageissuers'
      | 'purge'
      | 'recover'
      | 'restore'
      | 'setissuers'
      | 'update')[]?
    @description('Permissions to Keys.')
    keys: (
      | 'all'
      | 'backup'
      | 'create'
      | 'decrypt'
      | 'delete'
      | 'encrypt'
      | 'get'
      | 'getrotationpolicy'
      | 'import'
      | 'list'
      | 'purge'
      | 'recover'
      | 'release'
      | 'restore'
      | 'rotate'
      | 'setrotationpolicy'
      | 'sign'
      | 'unwrapKey'
      | 'update'
      | 'verify'
      | 'wrapKey')[]?
    @description('Permissions to Secrets.')
    secrets: ('all' | 'backup' | 'delete' | 'get' | 'list' | 'purge' | 'recover' | 'restore' | 'set')[]?
  }
}

// =================================================== //
// Generic Role Assignment                             //
// =================================================== //

@export()
@description('Function that generates RBAC role assignment guid. Use this within your bicep files such as main.bicep to develop a unique naming for Azure role assignments.Bicep modules within RBAC functionality leverages this function to generate guid for role assignments.')
func roleAssignmentName(
  resourceName string,
  roleName string,
  principalType string?,
  principalName string?,
  principalId string?
) string =>
  principalType == 'User' || principalType == 'Group'
    ? guid(resourceName, roleName, principalName!)
    : principalType == 'ServicePrincipal' && (!empty(principalName ?? '') && empty(principalId ?? ''))
        ? guid(resourceName, roleName, principalName!)
        : principalType == 'ServicePrincipal' && (empty(principalId ?? '') && empty(principalName ?? ''))
            ? fail('You have to either provide `principalName` or `principalId` for the type `ServicePrincipal` to successfully assign rbac role provided.')
            : guid(resourceName, roleName, principalId!)

@export()
@metadata({
  name: 'RoleAssignment'
  usage: 'Use this to simplify creation of role assignments within the bicep modules. This is a union type that can take in three different forms of role assignment: Service Principal, Group and User. Depending on the principal type you want to assign the role to, you can use the appropriate object within the RoleAssignment type.'
})
@discriminator('principalType')
@description('Azure Role Assignments.')
type RoleAssignment = GroupRoleAssignment | ServicePrincipalRoleAssignment | UserRoleAssignment

@sealed()
type ServicePrincipalRoleAssignment = {
  @description('Name of the role definition to be assigned to the provided principal.')
  roleName: RoleName
  @description('Optional. Display Name of the Managed identity or Entra ID application for which the role will be assigned.')
  principalName: string?
  @description('Optional. Principal ID (or Object Id) of the managed identity to which the role will be assigned. You can pass directly pass principalId of a user-assigned or system-assigned managed identity or an Entra ID Application that is being deployed by the bicep file. To use this, you have to set the value of parameter `principalName` to either `null` or `\'\'`.')
  principalId: string?
  @description('Principal type.')
  principalType: 'ServicePrincipal'
  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?
  conditionVersion: '2.0'?
  @description('Optional. Description of the role assignment.')
  description: string?
}

@sealed()
type GroupRoleAssignment = {
  @description('Name of the role definition to be assigned to the provided principal.')
  roleName: RoleName
  @description('Display name of the Entra ID group for which the role will be assigned.')
  principalName: string?
  @description('Principal type.')
  principalType: 'Group'
  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?
  conditionVersion: '2.0'?
  @description('Optional. Description of the role assignment.')
  description: string?
  @description('Object Id of the Entra ID group.')
  principalId: string?
}

@sealed()
type UserRoleAssignment = {
  @description('Name of the role definition to be assigned to the provided principal.')
  roleName: RoleName
  @description('User principal name of the user to which the role will be assigned. By convention, this value should map to the user\'s email name .For example, foo@bar.com.')
  principalName: string?
  @description('Principal type.')
  principalType: 'User'
  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?
  conditionVersion: '2.0'?
  @description('Description of the role assignment')
  description: string?
  @description('Object Id of the Entra ID user.')
  principalId: string?
}

type RoleName =
  | 'AcrPull'
  | 'AcrPush'
  | 'Azure AI Account Owner'
  | 'Azure AI Administrator'
  | 'Azure AI Developer'
  | 'Azure AI Owner'
  | 'Azure AI User'
  | 'Azure Service Bus Data Owner'
  | 'Azure Service Bus Data Receiver'
  | 'Azure Service Bus Data Sender'
  | 'Cognitive Services Contributor'
  | 'Cognitive Services Data Reader'
  | 'Cognitive Services Face Recognizer'
  | 'Cognitive Services OpenAI User'
  | 'Container Registry Repository Contributor'
  | 'Container Registry Repository Catalog Lister'
  | 'Container Registry Repository Reader'
  | 'Container Registry Repository Writer'
  | 'Contributor'
  | 'Data Factory Contributor'
  | 'EventGrid Data Contributor'
  | 'EventGrid Data Receiver'
  | 'EventGrid Data Sender'
  | 'Key Vault Administrator'
  | 'Key Vault Certificates Officer'
  | 'Key Vault Certificate User'
  | 'Key Vault Crypto Officer'
  | 'Key Vault Crypto Service Encryption User'
  | 'Key Vault Crypto User'
  | 'Key Vault Data Access Administrator'
  | 'Key Vault Secrets Officer'
  | 'Key Vault Secrets User'
  | 'Reader'
  | 'Storage Blob Data Contributor'
  | 'Storage Blob Data Owner'
  | 'Storage Blob Data Reader'
  | 'Storage Queue Data Contributor'
  | 'Storage Queue Data Reader'
  | 'Storage Queue Data Message Processor'
  | 'Storage Queue Data Message Sender'
  | 'Storage Table Data Contributor'
  | 'Storage Table Data Reader'
  | 'Storage Table Delegator'
  | 'User Access Administrator'

// ========================================    //
//   Private DNS Zone Virtual Network Link     //
// ========================================    //

@sealed()
@export()
@description('User-defined data type used by the parameter named Private DNS zone bicep module.')
type VirtualNetwork = {
  @description('Name of the Virtual network that needs to be linked with the DNS zone.')
  name: string
  @description('RG where the VNET resides.')
  resourceGroup: string?
  @description('Optional. ID of the subscription where the VNET resides. This is only needed if the VNET is in a subscription different than the one where the DNS zone is being deployed. The value does not expect the resource ID format.')
  subscriptionId: resourceInput<'Microsoft.Subscription/subscriptionDefinitions@2017-11-01-preview'>.properties.subscriptionId?
}

// ========================================    //
//   Network Security Group Security Rule     //
// ========================================    //

@sealed()
@export()
type NetworkSecurityGroupRule = {
  @description('Name of the security rule to be created.')
  name: string
  @description('Whether the traffic is allowed or denied.')
  access: ('Allow' | 'Deny')
  @description('he direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic.')
  direction: ('Inbound' | 'Outbound')
  @description('The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.')
  priority: int
  @description('Network protocol this rule applies to.')
  protocol: ('TCP' | 'UDP' | 'ICMP' | '*')
  @description('The CIDR or source IP ranges. Asterisk (*) can also be used to match all IP addresses. Multiple IP ranges can be specified by separating them with a comma. Accepts Service tag as the source address prefix.')
  sourceAddressPrefix: string
  @description('The CIDR or destination IP ranges. Asterisk (*) can also be used to match all IP addresses. Multiple IP ranges can be specified by separating them with a comma. Accepts Service tag as the destination address prefix.')
  destinationAddressPrefix: string
  @description('Destination port or range. Asterisk (*) can also be used to match all ports. Multiple ports or ranges can be specified by separating them with a comma.')
  destinationPortRange: string
  @description('Optional. Description of the rule.')
  description: string?
}

// ========================================  //
//        Virtual Network Peering            //
// ========================================  //

@sealed()
@export()
type VirtualNetworkPeering = {
  @description('Name of peering link. ')
  name: string
  @description('Optional. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. Defaults to disallowed.')
  allowForwardedTraffic: false | true?
  @description('Optional. ')
  allowGatewayTransit: false | true?
  allowVirtualNetworkAccess: false | true?
  doNotVerifyRemoteGateways: false | true?
  peerCompleteVnets: false | true
  localSubnetNames: string[]?
  remoteSubnetNames: string[]?
  remoteVnetName: string
  remoteVnetRGName: string?
  remoteVnetSubscriptionId: resourceInput<'Microsoft.Subscription/aliases@2025-11-01-preview'>.properties.subscriptionId?
  useRemoteGateways: false | true
}

// ========================================     //
//   Resource Name Builder Function             //
// ========================================    //

@description('Custom data type used by parameter `resourceType` in the the name Builder function to develop naming prefix accordingly. The function can only be used with Allowed resource types to generate name based on Azure WAF/CAF principles.')
type ResourceType =
  | 'containerApp'
  | 'containerAppEnvironment'
  | 'containerRegistry'
  | 'containerInstance'
  | 'aiSearch'
  | 'foundryAccount'
  | 'foundryAccountProject'
  | 'foundryHub'
  | 'azureOpenAiService'
  | 'databricksWorkspace'
  | 'dataFactory'
  | 'eventHub'
  | 'eventHubnamespace'
  | 'eventGridNamespace'
  | 'eventGridSubscriptions'
  | 'eventGridTopic'
  | 'eventGridSystemTopic'
  | 'fabricCapacity'
  | 'appServiceEnvironment'
  | 'appServicePlan'
  | 'availabilitySet'
  | 'privateLinkScope'
  | 'communicationService'
  | 'diskEncryptionSet'
  | 'functionApp'
  | 'hostingEnvironment'
  | 'osDisk'
  | 'dataDisk'
  | 'virtualMachineScaleSet'
  | 'virtualMachine'
  | 'vmStorageAccount'
  | 'webApp'
  | 'aks'
  | 'akscluster'
  | 'aksSystemNodePool'
  | 'askUserNodePool'
  | 'cosmosDBAccount'
  | 'cosmosCassandraAccount'
  | 'cosmosMongoDBAcount'
  | 'cosmosNoSQLAccount'
  | 'cosmosPostgres'
  | 'sqlDatabaseServer'
  | 'sqlDatabase'
  | 'sqlElasticPool'
  | 'mysqlDatabase'
  | 'postgreSQLDatabase'
  | 'sqlManagedInstance'
  | 'appConfigurationStore'
  | 'managedDevOpsPool'
  | 'apiManagementService'
  | 'logicApp'
  | 'seviceBusNamespace'
  | 'serviceBusQueue'
  | 'serviceBusTopic'
  | 'serviceBusTopicSubscription'
  | 'automationAccount'
  | 'applicationInsights'
  | 'deploymentScript'
  | 'logAnalyticsWorkspace'
  | 'purview'
  | 'resourceGroup'
  | 'templateSpec'
  | 'recoverServicesVault'
  | 'applicationGateway'
  | 'applicationSecurityGroup'
  | 'cdnProfile'
  | 'cdnEndpoint'
  | 'dnsPrivateResolver'
  | 'dnsForwardingRuleSet'
  | 'dnsPrivateResolverInboundEndpoint'
  | 'dnsPrivateResolverOutboundEndpoint'
  | 'firewall'
  | 'azureFirewall'
  | 'firewallPolicy'
  | 'frontDoorFirewallPolicy'
  | 'frontDoorProfile'
  | 'internalLoadBalancer'
  | 'externalLoadBalancer'
  | 'loadBalancerRule'
  | 'natGateway'
  | 'networkInterface'
  | 'networkSecurityGroup'
  | 'nsg'
  | 'privateLink'
  | 'privateEndpoint'
  | 'publicIpAddress'
  | 'pulicIpAddressPrefix'
  | 'routeServer'
  | 'trafficManagerProdile'
  | 'userDefinedRoute'
  | 'udr'
  | 'virtualNetwork'
  | 'vnet'
  | 'peering'
  | 'virtualNetworkGateway'
  | 'subnet'
  | 'bastion'
  | 'kv'
  | 'keyVault'
  | 'hsmKeyVault'
  | 'managedIdentity'
  | 'userAssignedManagedIdentity'
  | 'vpnGateway'
  | 'wafPolicy'
  | 'storageAccont'
  | 'virtualDesktopHostPool'
  | 'virtualDesktopApplicationGroup'
  | 'virtualDesktopWorksapce'
  | 'virtualDesktopScalingPlan'

var resourceNamePrefixMap object = {
  containerApp: 'ca'
  containerAppEnvironment: 'cae'
  containerRegistry: 'cr'
  containerInstance: 'ci'
  aiSearch: 'srch'
  foundryAccount: 'aif'
  foundryAccountProject: 'proj'
  foundryHub: 'hub'
  azureOpenAiService: 'oai'
  databricksWorkspace: 'dbw'
  dataFactory: 'adf'
  eventHub: 'evh'
  eventHubnamespace: 'evhns'
  eventGridNamespace: 'evgns'
  eventGridSubscriptions: 'evgs'
  eventGridTopic: 'evgt'
  eventGridSystemTopic: 'egst'
  fabricCapacity: 'fc'
  appServiceEnvironment: 'ase'
  appServicePlan: 'asp'
  availabilitySet: 'avail'
  privateLinkScope: 'pls'
  communicationService: 'acs'
  diskEncryptionSet: 'des'
  functionApp: 'func'
  hostingEnvironment: 'host'
  osDisk: 'osdisk'
  dataDisk: 'disk'
  virtualMachineScaleSet: 'vmss'
  virtualMachine: 'vm'
  vmStorageAccount: 'stvm'
  webApp: 'app'
  aks: 'aks'
  akscluster: 'aks'
  aksSystemNodePool: 'npsystem'
  askUserNodePool: 'np'
  cosmosDBAccount: 'cosmos'
  cosmosCassandraAccount: 'coscas'
  cosmosMongoDBAcount: 'cosmon'
  cosmosNoSQLAccount: 'cosno'
  cosmosPostgres: 'cospos'
  sqlDatabaseServer: 'sql'
  sqlDatabase: 'sqldb'
  sqlElasticPool: 'sqlep'
  mysqlDatabase: 'mysql'
  postgreSQLDatabase: 'pssql'
  sqlManagedInstance: 'sqlmi'
  appConfigurationStore: 'appcs'
  managedDevOpsPool: 'mdp'
  apiManagementService: 'apim'
  logicApp: 'logic'
  seviceBusNamespace: 'sbns'
  serviceBusQueue: 'sbq'
  serviceBusTopic: 'sbt'
  serviceBusTopicSubscription: 'sbts'
  automationAccount: 'aa'
  applicationInsights: 'appi'
  deploymentScript: 'script'
  logAnalyticsWorkspace: 'log'
  purview: 'pview'
  resourceGroup: 'rg'
  templateSpec: 'ts'
  recoverServicesVault: 'rsv'
  applicationGateway: 'agw'
  applicationSecurityGroup: 'asg'
  cdnProfile: 'cdnp'
  cdnEndpoint: 'cdne'
  dnsPrivateResolver: 'dnspr'
  dnsForwardingRuleSet: 'dnsfrs'
  dnsPrivateResolverInboundEndpoint: 'in'
  dnsPrivateResolverOutboundEndpoint: 'out'
  firewall: 'afw'
  azureFirewall: 'afw'
  firewallPolicy: 'afwp'
  frontDoorFirewallPolicy: 'fdfp'
  frontDoorProfile: 'adf'
  internalLoadBalancer: 'lbi'
  externalLoadBalancer: 'lbe'
  loadBalancerRule: 'rule'
  natGateway: 'ng'
  networkInterface: 'nic'
  networkSecurityGroup: 'nsg'
  nsg: 'nsg'
  privateLink: 'pl'
  privateEndpoint: 'pep'
  publicIpAddress: 'pip'
  pulicIpAddressPrefix: 'ippre'
  routeServer: 'rtserv'
  trafficManagerProdile: 'traf'
  userDefinedRoute: 'udr'
  udr: 'udr'
  virtualNetwork: 'vnet'
  vnet: 'vnet'
  peering: 'peer'
  virtualNetworkGateway: 'vgw'
  subnet: 'snet'
  bastion: 'bas'
  kv: 'kv'
  keyVault: 'kv'
  hsmKeyVault: 'kvmhsm'
  managedIdentity: 'id'
  userAssignedManagedIdentity: 'id'
  vpnGateway: 'vpng'
  wafPolicy: 'waf'
  storageAccount: 'st'
  virtualDesktopHostPool: 'vdpool'
  virtualDesktopApplicationGroup: 'vdag'
  virtualDesktopWorksapce: 'vdws'
  virtualDesktopScalingPlan: 'vdscaling'
}

@export()
@description('''
  - Checks if the resource name adheres to the standards agreed upon.
  - Location value is only needed if you want to add location alias within the resource naming.
  - If you do not needed location alias to be added to the name, the value should be: nameBuilder('virtualNetwork', 'mahi-spoke-dev', null)
  - If you want to add location alias, then it should be nameBuilder('virtualNetwork', 'mahi-spoke-prod, 'canadacentral')
''')
func nameBuilder(resourceType ResourceType, suffix string) string =>
  startsWith(toLower(suffix), resourceNamePrefixMap[resourceType]) || endsWith(
      toLower(suffix),
      resourceNamePrefixMap[resourceType]
    )
    ? fail('Resource name suffix should not start or end with the resource name prefix to avoid confusion. Please choose a different suffix.')
    : resourceType == 'storageAccount'
        ? contains(suffix, 'st') || contains(suffix, 'sa')
            ? fail('Storage account name does not adhere to the accepted standards. Name Suffix must not contain `sa` or `st`.')
            : length(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', '')) > 24
                ? fail('Storage account name exceeds 24 characters after removing hyphens if any. Choose a shorter suffix.')
                : toLower(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', ''))
        : resourceType == 'keyVault'
            ? (contains(toLower(suffix), 'kv') || contains(toLower(suffix), 'akv'))
                ? fail('Key Vault name does not adhere to the accepted standards. Name suffix must not contain `kv` or `akv`.')
                : length('${resourceNamePrefixMap[resourceType]}-${suffix}') > 24
                    ? fail('Key Vault name exceeds 24 characters. Choose a shorter suffix.')
                    : toLower('${resourceNamePrefixMap[resourceType]}-${suffix}')
            : resourceType == 'containerRegistry'
                ? contains(toLower(suffix), 'cr') || contains(toLower(suffix), 'acr')
                    ? fail('Container registry name does not adhere to the accepted standards. Name suffix must contain "acr" or "cr".')
                    : length(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', '')) > 50
                        ? fail('Container registry name exceeds 50 characters after removing hyphens if any. Choose the name suffix accordingly.')
                        : toLower(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', ''))
                : toLower('${resourceNamePrefixMap[resourceType]}-${suffix}')
