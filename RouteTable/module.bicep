// route table bicep module
import { RouteTableRoute } from '../utilities.bicep'

@allowed([
  false
  true
])
@description('Optional. Whether to disable the routes learned by BGP on that route table. True means disable. Value defaults to false.')
param disableBgpRoutePropagation bool = false

@description('Azure region where the route table needs to be created.')
param location resourceInput<'Microsoft.Network/routeTables@2024-05-01'>.location = resourceGroup().location // string = resourceGroup().location

@description('Name of the route table resource to be created.')
param nameSuffix string

@description('Routes to be added.')
param routes RouteTableRoute[]?

@description('Optional. Tags to be applied.')
param tags object?

var name = toLower('rt-${nameSuffix}')

// create route table
resource rt 'Microsoft.Network/routeTables@2023-05-01' = {
  name: !startsWith(toLower(nameSuffix), 'rt-')
    ? name
    : fail('Route table name should not start with rt-. THe module will add \'rt-\' as the prefix.')
  location: location
  tags: tags ?? null
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [
      for each in (routes ?? []): {
        name: each.?name
        properties: {
          nextHopType: each.?nextHopType
          addressPrefix: each.?addressPrefix
          nextHopIpAddress: each.?nextHopIpAddress
        }
      }
    ]
  }
}

//outputs
@description('Resource Id of the route table created by the module.')
output id string = rt.id

@description('Name of the route table deployed.')
output name string = rt.name
