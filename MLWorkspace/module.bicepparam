using './module.bicep'

param appInsightsName = 'appi-sat-ai'

param keyVaultName = 'kv-sat-ai'

param nameSuffix = 'mahindra-bicepmodupdated'

param storageAccountName = 'stsatai'

param managedVirtualNetwork = {
  isolationMode: 'AllowInternetOutbound'
}
