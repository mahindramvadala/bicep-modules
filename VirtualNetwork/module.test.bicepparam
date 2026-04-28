using './module.bicep'

// Parameter file with test (dummy) values to scan the bicep module before getting published to the registry. Below are the required parameters to deploy the vnet module using default config.

param cidr = '10.0.0.0/24'
param nameSuffix = 'mahi-spoke-dummy'

// Below optional params provide further customizations for the vnet module
/*
param dnsServers = [ //Optional
  '8.8.8.8.'
]

param peerings = [ //Optional.
  {
    name: 'dummy'
    remoteVnetName: 'vnet-mahi-hub-dummy'
    useRemoteGateways: false
    peerCompleteVnets: true
  }
]

param subnets = [ // Optional
  {
    name: 'snet-mahi-dummy-pep'
    addressPrefix: '10.0.0.0/26'
  }
]

param ddosProtectionPlan = {
  name: 'ddos-mahi-dummy'
  //resourceGroup:  'rg-dummy' //optional
  //subscriptionId: '00000000-0000-0000-0000-000000000000' // Optional

}

param enableDdosProtectionPlan = true

param enableEncryption = true

param lock = { //optional and only needed if lock needs to be set on the vnet resource
  level: 'CanNotDelete'
  name: 'lock-vnet-mahi-dummy'
  notes: 'No one can delete'
}

param tags = {} //optional

*/
