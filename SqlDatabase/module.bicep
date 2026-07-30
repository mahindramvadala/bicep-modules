metadata name = 'Sql Database bicep module'

import {Identity, nameBuilder} from '../utilities.bicep'

@description('Optional. The storage account type to be used to store backups for this database. Defaults to "Local".')
param backupStorageRedundancy resourceInput<'Microsoft.Sql/servers/databases@2025-02-01-preview'>.properties.requestedBackupStorageRedundancy?

@maxValue(4)
@minValue(1)
@description('Optional. Max capacity of the database in vCores. Defaults to 1 vCore.')
param maxVCores int = 1

@description('Optional. Database creation mode. Defaults to "Default".')
param createMode 'Copy' | 'Default' | 'OnlineSecondary' | 'PointInTimeRestore' | 'Recovery' | 'Restore' | 'RestoreExternalBackup' | 'RestoreExternalBackupSecondary' | 'RestoreLongTermRetentionBackup' | 'Secondary'

param identity Identity?

param location string?

param nameSuffix string

param sqlServerName string

@description('Optional. Time in minutes after which database is automatically paused. For example, 60 means that the database will be paused after 60 minutes of inactivity.')
param autoPauseDelay int?

@description('Optional. If true, replicas of the database will be spread across multiple availability zones. Defaults to false.')
param zoneRedundant false | true?

@description('Optional. Maximum size of the database in GB. Defaults to 10 GB.')
param sizeInGB int?

var resourceName = nameBuilder('sqlDatabase', nameSuffix)

var maxSizeInBytes int = sizeInGB ?? 10 * 1024 * 1024 * 1024

resource sql_server 'Microsoft.Sql/servers@2025-02-01-preview' existing = {
  name: sqlServerName
}

resource sql_database 'Microsoft.Sql/servers/databases@2025-02-01-preview' = {
  name: resourceName
  parent: sql_server
  location: location ?? resourceGroup().location
  properties: {
    createMode: createMode ?? 'Default'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeInBytes
    readScale: 'Disabled'
    zoneRedundant: zoneRedundant ?? false
    autoPauseDelay: autoPauseDelay ?? -1
    availabilityZone: 'NoPreference'
    requestedBackupStorageRedundancy: backupStorageRedundancy ?? 'Local'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maintenanceConfigurationId: subscriptionResourceId('Microsoft.Maintenance/publicMaintenanceConfigurations', 'SQL_Default')
    minCapacity: json('0.5')
    isLedgerOn: false
  }
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: maxVCores
  }
  identity: identity
}
