metadata name = 'Custom utilities for innersource Bicep modules'
metadata description = '''
  This module provides you with all the custom data types and functions that are being imported within the Bicep modules. You can also import them to your own Bicep files if you want to use the same data types and functions within your Bicep code. The main purpose of this module is to avoid code duplication and provide a single source of truth for all the custom data types and functions used within the innersource Bicep modules.
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

// =================================== //
// Key Vault RBAC Role Assignment      //
// =================================== //

@sealed()
type KeyVaultRoleAssignment = {
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

// =================================================== //
// Generic Role Assignment                             //
// =================================================== //

@sealed()
@export()
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
  roleDefinitionName: string
  @description('Optional. Principal/Object ID of the System (User-Assignmed) managed identity.')
  principalId: string?
  @description('Name of the EntraID group or user for which the role is being assigned.')
  principalName: string?
  @description('Type of the Principal for which the role is being assigned. If the prinicipal is a managed identity resource, it should be `ServicePrincipal`.')
  principalType: ('Group' | 'ServicePrincipal' | 'User')
}

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

var locationAliasVar object = {
  canadacentral: 'cc'
  canadaeast: 'ce'
  useast: 'use'
  useast2: 'use2'
  uswest: 'usw'
}

@export()
@description('''
  - Checks if the resource name adheres to the standards agreed upon.
  - Location value is only needed if you want to add location alias within the resource naming.
  - If you do not needed location alias to be added to the name, the value should be: nameBuilder('virtualNetwork', 'mahi-spoke-dev', null)
  - If you want to add location alias, then it should be nameBuilder('virtualNetwork', 'mahi-spoke-prod, 'canadacentral')
''')
func nameBuilder(resourceType ResourceType, suffix string, location string?) string =>
  resourceType == 'storageAccount'
    ? contains(suffix, 'st') || contains(suffix, 'sa')
        ? fail('Storage account name does not adhere to the accepted standards. Name Suffix must not contain `sa` or `st`.')
        : location == null
            ? length(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', '')) > 24
                ? fail('Storage account name exceeds 24 characters after removing hyphens if any. Choose a shorter suffix.')
                : toLower(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', ''))
            : length(replace(
                  '${resourceNamePrefixMap[resourceType]}${locationAliasVar[toLower(location!)]}${suffix}',
                  '-',
                  ''
                )) > 24
                ? fail('Storage account name exceeds 24 characters after removing hyphens if any. Choose a shorter suffix.')
                : toLower(replace(
                    '${resourceNamePrefixMap[resourceType]}${locationAliasVar[toLower(location!)]}${suffix}',
                    '-',
                    ''
                  ))
    : resourceType == 'keyVault'
        ? (contains(toLower(suffix), 'kv') || contains(toLower(suffix), 'akv'))
            ? fail('Key Vault name does not adhere to the accepted standards. Name suffix must not contain `kv` or `akv`.')
            : location == null
                ? length('${resourceNamePrefixMap[resourceType]}-${suffix}') > 24
                    ? fail('Key Vault name exceeds 24 characters. Choose a shorter suffix.')
                    : toLower('${resourceNamePrefixMap[resourceType]}-${suffix}')
                : length('${resourceNamePrefixMap[resourceType]}-${locationAliasVar[toLower(location!)]}-${suffix}') > 24
                    ? fail('Key Vault name exceeds 24 characters. Choose a shorter suffix.')
                    : toLower('${resourceNamePrefixMap[resourceType]}-${locationAliasVar[location!]}-${suffix}')
        : resourceType == 'containerRegistry'
            ? contains(toLower(suffix), 'cr') || contains(toLower(suffix), 'acr')
                ? fail('Container registry name does not adhere to the accepted standards. Name suffix must contain "acr" or "cr".')
                : location == null
                    ? length(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', '')) > 50
                        ? fail('Container registry name exceeds 50 characters after removing hyphens if any. Choose the name suffix accordingly.')
                        : toLower(replace('${resourceNamePrefixMap[resourceType]}${suffix}', '-', ''))
                    : length(replace(
                          '${resourceNamePrefixMap[resourceType]}${locationAliasVar[toLower(location!)]}${suffix}',
                          '-',
                          ''
                        )) > 50
                        ? fail('Container registry name exceeds 50 characters after removing hyphens if any. Choose the name suffix accordingly.')
                        : toLower(replace(
                            '${resourceNamePrefixMap[resourceType]}${locationAliasVar[toLower(location!)]}${suffix}',
                            '-',
                            ''
                          ))
            : location == null
                ? toLower('${resourceNamePrefixMap[resourceType]}-${suffix}')
                : toLower('${resourceNamePrefixMap[resourceType]}-${locationAliasVar[location!]}-${suffix}')
