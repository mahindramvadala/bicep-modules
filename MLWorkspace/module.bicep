metadata name = 'Azure Machine Learning Workspace Bicep module'

metadata description = '''
Deploys an Azure Machine Learning workspace with a private endpoint if parameter "privateEndpoint" is provided. It also offers additional configurations such as selective outbound access, high business impact, container registry linkage, serverless compute settings, managed identity and managed virtual network. Manged Vnet is created for the workspace when parameter `managedVirtualNetwork` is neither null nor empty.

When the isolationMode value is `AllowInternetOutbound`, the workspace can connect to any public endpoint without the need for additional rules. However, you have to create outbound rules (of type Private Endpoint) to allow connectivity to the private resources such as storage account, key vault etc. that have private endpoints setup. If the isolationMode is `AllowOnlyApprovedOutbound`, a Basic sku Azure Firewall will be created to manage the outbound rules. Outbound rules should also use FQDNs and/or Service Tags to allow connectivity to both public and private endpoints.

Managed Virtual Network kind will be `V2` by default. When enabled, the managed private endpoints for the required/dependent resources such as kv, storage account and ACR used by machine learning workspace are created by default and need to be approved.
'''

metadata version = '1.0'

import { amlComputeType } from '../utilities.bicep'

@sys.description('Name of the existing Application insights resource machine learning workspace uses.')
param appInsightsName string

@sys.description('Optional. RG where the app insights resource resides. Defaults to the resource group where the Machine learning workspace resides.')
param appInsightsRGName string?

@sys.description('Optional. Whether to allow public access when behind VNet. Defaults to `false`.')
param allowPublicAccessWhenBehindVnet false | true = false

@sys.description('Optional. Name of the existing Container registry resource machine learning workspace uses.')
param containerRegistryName string?

@sys.description('Optional. RG where the Container Registry resource resides. Defaults to the resource group where the Machine learning workspace resides.')
param containerRegistryRGName string?

@sys.description('Name of the existing key vault resource machine learning workspace uses.')
param keyVaultName string

@sys.description('Optional. RG where the Key Vault resource resides. Defaults to the resource group where the Machine learning workspace resides.')
param keyVaultRGName string?

@sys.description('The name suffix for the Azure Machine Learning workspace.')
param nameSuffix string

@sys.description('Optional. Azure location where the Machine Learning workspace should be created. Defaults to the resource group location.')
param location string?

@sys.description('Optional. Description text for the Machine Learning workspace.')
param description string?

@sys.description('Name of the existing Storage account resource machine learning workspace uses.')
param storageAccountName string

@sys.description('Optional. RG where the storage account resides. Defaults to the resource group where the Machine Learning Workspace resides.')
param storageAccountRGName string?

@sys.description('Optional.The auth mode used for accessing the system datastores of the workspace. Defaults to `Identity`.')
param systemDatastoresAuthMode 'AccessKey' | 'Identity' | 'UserDelegationSAS' = 'Identity'

@sys.description('Outbound access managed network settings for the machine learning workspace. If isolationMode is set to either `AllowInternetOutbound` or `AllowOnlyApprovedOutbound`, a managed vnet will be setup during the creation of workspace itself. Use ctrl+space to access additional (optional) properties such as outbound rules etc. offered by the parameter.')
param managedVirtualNetwork OutboundAccessType?

@allowed([
  false
  true
])
@sys.description('Setting this to `true` will control the amount of data Microsoft collects for diagnostic purposes if your workspace contains sensitive data. It further enables additional encryption in Microsoft Managed environments. Defaults to `false`.')
param highBusinessImpactWorkspace bool = false

@sys.description('Optional. Settings for a Serverless compute within the workspace.')
param serverlessComputeSettings ServerlessComputeSettingsType?

@sys.description('Compute Clusters to be created.')
param compute mlComputeType?

param privateEndpoint {
  subnetName: string
  vnetName: string
}?

var resourceName string = 'mlw-${nameSuffix}'

/*
var defaultPrivateEndpointOutboundRules managedVnetOutboundRules = empty(containerRegistryName ?? '')
  ? [
      {
        name: 'storage_account_blob_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: sa.id
          subresourceTarget: 'blob'
        }
        type: 'PrivateEndpoint'
      }
      {
        name: 'storage_account_file_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: sa.id
          subresourceTarget: 'file'
        }
        type: 'PrivateEndpoint'
      }
      {
        name: 'key_vault_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: kv.id
          subresourceTarget: 'vault'
        }
        type: 'PrivateEndpoint'
      }
    ]
  : [
      {
        name: 'storage_account_blob_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: sa.id
          subresourceTarget: 'blob'
        }
        type: 'PrivateEndpoint'
      }
      {
        name: 'storage_account_file_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: sa.id
          subresourceTarget: 'file'
        }
        type: 'PrivateEndpoint'
      }
      {
        name: 'key_vault_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: kv.id
          subresourceTarget: 'vault'
        }
        type: 'PrivateEndpoint'
      }
      {
        name: 'acr_managed_endpoint'
        category: 'Dependency'
        destination: {
          serviceResourceId: acr.?id
          subresourceTarget: 'registry'
        }
        type: 'PrivateEndpoint'
      }
    ]
*/

@sys.description('Get existing Application Insights resource.')
resource appi 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup(appInsightsRGName ?? resourceGroup().name)
}

@sys.description('Get existing Key vault resource.')
resource kv 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultRGName ?? resourceGroup().name)
}

@sys.description('Get Storage account resource.')
resource sa 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
  name: storageAccountName
  scope: resourceGroup(storageAccountRGName ?? resourceGroup().name)
}

@sys.description('Get Container registry resource if provided.')
resource acr 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = if (!empty(containerRegistryName ?? '')) {
  name: containerRegistryName!
  scope: resourceGroup(containerRegistryRGName ?? resourceGroup().name)
}

// Create Machine Learning Workspace
resource mlw 'Microsoft.MachineLearningServices/workspaces@2026-03-15-preview' = {
  name: resourceName
  location: location ?? resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: resourceName
    description: description ?? 'Azure Machine Learning Workspace'
    storageAccount: sa.id
    keyVault: kv.id
    applicationInsights: appi.id
    containerRegistry: acr.?id
    publicNetworkAccess: empty(privateEndpoint ?? {}) ? 'Enabled' : 'Disabled'
    allowPublicAccessWhenBehindVnet: allowPublicAccessWhenBehindVnet
    systemDatastoresAuthMode: systemDatastoresAuthMode
    managedNetwork: !empty(managedVirtualNetwork ?? {})
      ? {
          enableNetworkMonitor: location == 'canadacentral' || resourceGroup().location == 'canadacentral'
            ? false
            : true
          firewallSku: managedVirtualNetwork.?isolationMode == 'AllowOnlyApprovedOutbound' ? 'Basic' : null
          isolationMode: managedVirtualNetwork.?isolationMode
          managedNetworkKind: managedVirtualNetwork.?kind ?? 'V1'
          //outboundRules: !empty(managedVirtualNetwork.?outboundRules ?? {}) ?toObject(managedVirtualNetwork.?outboundRules, each => each.name, each => omitNameProperty(each)) : {}
        }
      : null
    provisionNetworkNow: !empty(managedVirtualNetwork ?? {}) ? true : null
    v1LegacyMode: false
    serverlessComputeSettings: serverlessComputeSettings
    hbiWorkspace: highBusinessImpactWorkspace
  }
}

@sys.description('Assign Azure AI Enterprise Network connection approver role for the workspace \'s identity on the machine learning workspace.')
resource mlworkpace_networkconnectapprover_rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mlw.?id, 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea', resourceGroup().name)
  properties: {
    principalId: mlw.identity.?principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'
    ) //subscription resoure Id of the azure ai enterpise network connection approver role definition
    principalType: 'ServicePrincipal'
  }
}

/*
resource script 'Microsoft.Resources/deploymentScripts@2023-08-01' = if (managedVirtualNetwork.?kind == 'V2') {
  name: 'EnableManagedVnet_${mlw.name}'
  location: location ?? resourceGroup().location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('rg-identity', 'Microsoft.ManagedIdentity/userAssignedIdentities', 'mi-script')}': {}
    }
  }
  properties: {
    azCliVersion: '2.85.0'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    scriptContent: '''
      az login
      echo "Enabling managed vnet for the workspace..."
      az ml workspace provision-network --name $mlWorkspaceName --resource-group $rgName
      echo "Successfully configured managed vnet."
    '''
    environmentVariables: [
      {
        name: 'mlWorkspaceName'
        value: mlw.name
      }
      {
        name: 'rgName'
        value: resourceGroup().name
      }
    ]
  }
}
*/

/*
resource orules 'Microsoft.MachineLearningServices/workspaces/outboundRules@2026-03-15-preview' = [ for each in managedVirtualNetwork.?outboundRules! ?? []: {
  name: each.?name
  parent: mlw
  dependsOn: [
    script
  ]
  properties: each.?properties
}]
*/

module mlworkspace_compute 'compute.bicep' = [ for each in compute! ?? []: {
  dependsOn: [
    mlw_private_endpoint
  ]
  params: {
    location: location ?? resourceGroup().location
    name: each.?name
    workspaceName: mlw.name
    properties: each.?properties
  }
}]

module mlw_private_endpoint '../PrivateEndpoint/module.bicep' = if(!empty(privateEndpoint ?? {})) {
  params: {
    groupId: 'amlworkspace'
    nameSuffix: mlw.name
    privateDnsZoneIds: [
      resourceId('Microsoft.Network/privateDnsZones', 'privatelink.api.azureml.ms')
      resourceId('Microsoft.Network/privateDnsZones', 'privatelink.notebooks.azure.net')
    ]
    privateLinkServiceId: mlw.id
    subnetName: privateEndpoint.?subnetName!
    vnetName: privateEndpoint.?vnetName!
  }
}

// outputs
@sys.description('Name of the Machine Learning workspace.')
output name string = mlw.name

@sys.description('Resource ID of the Machine Learning workspace.')
output id string = mlw.id

@sys.description('Resource group where the Machine Learning workspace is deployed.')
output rg string = resourceGroup().name

@sys.description('Principal Id (or object ID) of the managed identity of the created Machine learning workspace resource. Use ctrl+space to get the value of system-assigned or/and user-assigned identities.')
output principalId string = mlw.identity.principalId

@sys.description('Immutable ID associated with the workspace.')
output workspaceId string = mlw.properties.workspaceId

// =========================================================== //
//         User-defined data types and functions               //
// =========================================================  //

type ServerlessComputeSettingsType = {
  @sys.description('The resource ID of an existing virtual network subnet in which serverless compute nodes should be deployed.')
  serverlessComputeCustomSubnet: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2025-05-01'>.id
  @sys.description('Optional. The flag to signal if serverless compute nodes deployed in custom vNet would have no public IP addresses for a workspace with private endpoint.')
  serverlessComputeNoPublicIP: false | true?
}

@discriminator('isolationMode')
@sys.description('Outbound Access Type.')
type OutboundAccessType = NetworkIsolationInternetOutbound | NetworkIsolationAllowOnlyApprovedOutbound

type NetworkIsolationInternetOutbound = {
  @sys.description('Isolation mode for the managed network of a machine learning workspace.')
  isolationMode: 'AllowInternetOutbound'
  @sys.description('The Kind of the managed network. Users can switch from V1 to V2 for granular access controls, but cannot switch back to V1 once V2 is enabled. Defaults to V2.')
  kind: 'V1' | 'V2'?
  @sys.description('If true, enables private endpoint to be used by jobs running on Spark.')
  sparkReady: false | true?
  @sys.description('Optional. List of outbound')
  outboundRules: managedVnetInternetOutboundRule[]?
}

type NetworkIsolationAllowOnlyApprovedOutbound = {
  @sys.description('Isolation mode for the managed network of a machine learning workspace.')
  isolationMode: 'AllowOnlyApprovedOutbound'
  @sys.description('The Kind of the managed network. Users can switch from V1 to V2 for granular access controls, but cannot switch back to V1 once V2 is enabled. Defaults to V2.')
  kind: 'V1' | 'V2'?
  @sys.description('If true, enables private endpoint to be used by jobs running on Spark.')
  sparkReady: false | true?
  outboundRules: managedVnetApprovedOutboundRule[]?
}

type managedVnetInternetOutboundRule = {
  name: string
  properties: PrivateEndointOutboundRule
}


type managedVnetApprovedOutboundRule = {
  name: string
  @discriminator('type')
  properties: PrivateEndointOutboundRule | fqdnOutboundRule | serviceTagOutboundRule
}

type PrivateEndointOutboundRule = {
  type: 'PrivateEndpoint'
  category: ruleCategory?
  destination: {
    serviceResourceId: string
    subresourceTarget: string
    sparkEnabled: bool?
  }
  fqdns: string[]?
}

type fqdnOutboundRule = {
  type: 'FQDN'
  category: ruleCategory
  destination: string
}

type serviceTagOutboundRule = {
  type: 'ServiceTag'
  category: ruleCategory
  destination: {
    action: 'Allow' | 'Deny'
    addressPrefixes: string[]
    portRanges: string
    protocol: string
    serviceTag: string
  }
}

type ruleCategory = 'Dependency' | 'Recommended' | 'Required' | 'UserDefined'

type mlComputeType = {
  name: string
  properties: amlComputeType
}[]
