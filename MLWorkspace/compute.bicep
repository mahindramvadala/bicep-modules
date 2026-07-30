import { amlComputeType } from '../utilities.bicep'

param workspaceName string

param location string?

param name string

param properties amlComputeType

resource mlw 'Microsoft.MachineLearningServices/workspaces@2026-03-15-preview' existing = {
  name: workspaceName
  scope: resourceGroup()
}

resource mlw_compute 'Microsoft.MachineLearningServices/workspaces/computes@2026-03-01' = {
  name: name
  parent: mlw
  identity: properties.computeType != 'ComputeInstance' ? {
    type: 'SystemAssigned'
  } : null
  location: location ?? resourceGroup().location
  properties: {
    computeType: properties.computeType
    computeLocation: properties.?computeLocation ?? resourceGroup().location
    disableLocalAuth: properties.?disableLocalAuth ?? true
    properties: {
      applicationSharingPolicy: properties.?properties.?applicationSharingPolicy ?? 'Shared'
      computeInstanceAuthorizationType: properties.?properties.?computeInstanceAuthorizationType ?? 'personal'
      enableNodePublicIp: properties.?properties.?enableNodePublicIp ?? false
      vmSize: properties.?properties.?vmSize
      enableSSO: properties.?properties.?enableSSO ?? true
      idleTimeBeforeShutdown: properties.?properties.?idleTimeBeforeShutdown ?? 'PT1H'
      personalComputeInstanceSettings: {
        assignedUser: {
          objectId: properties.?properties.assignedUserObjectId
          tenantId: tenant().tenantId
        }
      }
      subnet: !empty(properties.properties.?subnetId ?? '') ? {
        id: properties.properties.?subnetId
      } : null
    }
  }
  /*properties: properties.computeType == 'AmlCompute' ? {
    computeType: properties.computeType
    computeLocation: properties.?computeLocation ?? resourceGroup().location
    disableLocalAuth: properties.disableLocalAuth ?? true
    properties: {
      enableNodePublicIp: properties.?properties.?enableNodePublicIp ?? false
      isolatedNetwork: properties.?properties.?isolatedNetwork
      osType: properties.?properties.?osType ?? 'Linux'
      remoteLoginPortPublicAccess: properties.?remoteLoginPortPublicAccess ?? 'Disabled'
      vmPriority: properties.?vmPriority ?? 'LowPriority'
      scaleSettings: properties.properties.?scaleSettings ?? {
        maxNodeCount: 2
        minNodeCount: 1
        nodeIdleTimeBeforeScaleDown: 'PT2M'
      }
      vmSize: properties.vmSize
      subnet: !empty(properties.properties.?subnetId ?? '') ? {
        id: properties.properties.?subnetId
      } : null
      userAccountCredentials: properties.properties.?userAccountCredentials
    }
  }*/
}

output principalId string? = properties.computeType != 'ComputeInstance' ? mlw_compute.identity.principalId : null
