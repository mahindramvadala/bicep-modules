metadata name = 'Entra ID Group\'s Principal ID retreival deployment script bicep module'

metadata description = '''
- This module retrieves the object ID of an Entra ID group or user or a service principal using Microsoft Graph PowerShell packed as a deployment script bicep resource.

- The module uses a user assigned managed identity named `mi-entraid` deployed. Ensure a user-assigned managed identity resource with that name is created or if you want to use a different managed identity resource, you can specify using optional parameters related to UAMI configuration. You can pick a UAMI from any rg or subscription. The identity needs to have atleast `Group.Read.All`,`User.Read.All`,`Application.Read.All` permissions assigned or Application Administrator EntraID role. Its recommended to create a custom role with the above permissions and assign it to the user-assigned identity the script uses.

Optionally, the script provides the option of running script over a private endpoint securely through the use of `storageAccount` and `containerSettings` parameters. Ensure the subnet chosen has delegation as `Microsoft.ContainerInstance/containerGroups`. If the private endpoint is setup for the storage Account chosen, the DNS resolution should be inplace to connect to the Private endpoint of the Storage account from the subnet securely. Review 'Microsoft.ContainerInstance/containerGroups'
'''

extension msgraph

@description('Type of the Principal.')
param principalType ('Group' | 'ServicePrincipal' | 'User')

@description('Optional. Read only.')
param timeStamp string = utcNow('yyMMddHHmm')

@description('Optional. Name of the user assigned managed identity resource the script uses to authenticate to Entra ID. Defaults to `mi-entraidgroupid`. Ensure a UAMI resource is created using the same name if you want to use default value and has atleast Group.Read.All Entra ID permission. Do not assign high-priviliged roles/permissions.')
param userAssignedManagedIdentityName string = 'mi-entraid'

@description('Optional. RG where the UAMI resource resides. Defaults to the rg where the deployment script resource resides.')
param userAssignedManagedIdentityRGName string?

@description('Optional. Subscription GUID where the uami resides. By default the module looks for UAMI resource in the subscription where the module is being deployed. Use this to overwrite the default value.')
param userAssignedManagedIdentitySubscriptionId resourceInput<'Microsoft.Subscription/aliases@2025-11-01-preview'>.properties.subscriptionId?

@description('Name of the principal for which the principal ID (or Object ID) needs to be retreived. If the `principalType` is "User", the value should be the userPrincipalName such as demo@contoso.com. If not `user`, then the value should be the display Name of the group, application or managed identity resource.')
param principalName string

@description('''
- Optional. Existing storage account details. This is only needed if you want to use an existing storage account to store the powershell script and mount it.
- If using an existing storage account, the UAMI the script uses, needs `Storage File Data Privileged Contributor` permission/role on the storage account.
''')
param storageAccount {
  @description('Name of the Storage Account')
  name: string?
  @description('Optional. RG where the storage account resource.')
  rgName: string?
}?

@description('''
- Optional. Existing Network configuration to run the script securely un a private network.
- If the storage account chosen is an existing and has private endpoint or firewall rules on the resource, ensure the container instance delegated subnet is allowed to access the storage account.
''')
param containerSettings {
  instanceName: 'ci-entraidobjectretrieval'
  subnetName: string?
  vnetName: string?
  ResourceGroupName: string?
  subscriptionId: string?
}?

var containerInstanceSubnetId string = !empty(containerSettings ?? '')
  ? resourceId(
      containerSettings.?subscriptionId ?? subscription().subscriptionId,
      containerSettings.?ResourceGroupName ?? resourceGroup().name,
      'Microsoft.Network/virtualNetworks/subnets',
      containerSettings.?vnetName!,
      containerSettings.?subnetName!
    )
  : 'dummy'

@description('Ge the existing Storage account resource.')
resource storage_account 'Microsoft.Storage/storageAccounts@2025-08-01' existing = if (!empty(storageAccount ?? '')) {
  name: storageAccount.?name ?? 'dummy'
  scope: resourceGroup(storageAccount.?rgName ?? resourceGroup().name)
}

resource script_uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' existing = {
  name: userAssignedManagedIdentityName!
  scope: resourceGroup(
    userAssignedManagedIdentitySubscriptionId ?? subscription().subscriptionId,
    userAssignedManagedIdentityRGName ?? resourceGroup().name
  )
}

resource entraid_user 'Microsoft.Graph/users@v1.0' existing = if (principalType == 'User') {
  userPrincipalName: principalName ?? 'dummy'
}

resource dscript 'Microsoft.Resources/deploymentScripts@2023-08-01' = if (principalType != 'User') {
  name: 'GetObjectId_${trim(replace(principalName, '@', ''))}'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${script_uami.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '15.3'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    scriptContent: '''
      param(
        [string]$PrincipalName,
        [validateSet("Group", "ServicePrincipal")]
        [string]$PrincipalType
      )
      try {
        Write-Host "Retrieving Oauth token to authenticate to Entra ID..."
        $SecureToken = (Invoke-RestMethod -Method GET -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2025-04-07&resource=https://graph.microsoft.com/" -Headers @{ Metadata="true" } -ErrorAction Stop).access_token | ConvertTo-SecureString -AsPlainText -Force
        Write-Host "Successfully Retrieved the access token by querying the Instance Metadata service and converted it to Secure string."
        if ($PrincipalType -eq "Group") {
          Write-Host "Retrieving the group object using Microsoft graph API..."
          $Response = Invoke-RestMethod -Method GET -uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$PrincipalName'" -Authentication Bearer -Token $SecureToken -ContentType "application/json" -ErrorAction Stop
          Write-Host "Successfully retrieved the Entra ID group object by calling the Microsoft graph api."
          $Id = $Response.value[0].id
          $DeploymentScriptOutputs = @{}
          $DeploymentScriptOutputs['objectId']=$Id
        }
        else {
          Write-Host "Retrieving the service principal object using Microsoft Graph API..."
          $Response = Invoke-RestMethod -Method GET -uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$PrincipalName'" -Authentication Bearer -Token $SecureToken -ContentType "application/json" -ErrorAction Stop
          Write-Host "Successfully retrieved Application's Service Principal object by calling the Microsoft graph api."
          $Id = $Response.value[0].id
          $DeploymentScriptOutputs = @{}
          $DeploymentScriptOutputs['objectId']=$Id
        }
      }
      catch {
        Write-Host "Failed to retrieve the object ID of the Entra ID Group or Service principal"
        $Details = @{
          timeStamp = Get-Date -AsUTC -Format 'o'
          message = $_.Exception.Message
          type = $_.Exception.GetType().FullName
          line = $_.InvocationInfo.ScriptLineNumber
          stackTrace = $_.ScriptStackTrace
        }
        Write-Host ($Details | ConvertTo-Json)
        throw $_
      }
    '''
    arguments: '-PrincipalName ${principalName} -PrincipalType ${principalType}'
    forceUpdateTag: timeStamp
    cleanupPreference: 'Always'
    storageAccountSettings: !empty(storageAccount ?? '')
      ? {
          #disable-next-line BCP422
          storageAccountKey: !empty(storageAccount ?? '') ? storage_account.listKeys().keys[0].value : 'dummy'
          storageAccountName: storage_account.?name
        }
      : null
    containerSettings: !empty(containerSettings)
      ? {
          containerGroupName: containerSettings.?instanceName
          subnetIds: !empty(containerSettings ?? '')
            ? [
                {
                  id: containerInstanceSubnetId
                }
              ]
            : []
        }
      : null
  }
}

//outputs
@description('Object Id or principal Id of the Entra ID user or group or service principal.')
output id string = principalType == 'User' ? entraid_user.?id : dscript.?properties.outputs.objectId
