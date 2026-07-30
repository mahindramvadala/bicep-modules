metadata name = 'VPN Gateway Bicep module'

metadata description = 'This module provisons a VPN gateway resource in a virtual network. It also provisions a gateway subnet if it does not already exist when the parameter gatewaySubnetAddressPrefix is provided. The VPN gateway is configured with a VPN client address pool and supports Entra ID and certificate authentication for VPN clients although Entra ID authentication is the default authentication type. The VPN gateway is configured with a private IP address and supports OpenVPN and IKEv2 protocols for VPN clients.'

@description('Optional. The address prefix for the gateway subnet. This is only applicable or needed if the gateway subnet does not already exist. If the gateway subnet already exists, this parameter will be ignored. ')
param gatewaySubnetAddressPrefix string?

param name string

@description('Optional. Azure region where the resource needs to be deployed. Defaults to the location of the resource group.')
param location string?

param vnetId resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.id

@description('The IP address range from which VPN clients will receive an IP address when connected. Range specified must not overlap with on-premise network. For example, 172.16.100.0/24.')
param vpnClientAddressPoolPrefix string

resource new_gateway_subnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = if (!empty(gatewaySubnetAddressPrefix) ?? '') {
  name: '${last(split(vnetId, '/'))}/GatewaySubnet'
  properties: {
    addressPrefix: gatewaySubnetAddressPrefix
  }
}

module vpn_gw 'br/public:avm/res/network/virtual-network-gateway:0.11.1' = {
  name: 'DeployVnetGateway_${name}'
  dependsOn: [
    new_gateway_subnet
  ]
  params: {
    name: name
    location: location ?? resourceGroup().location
    clusterSettings: {
      clusterMode: 'activePassiveNoBgp'
    }
    gatewayType: 'Vpn'
    virtualNetworkResourceId: vnetId
    vpnType: 'PolicyBased'
    skuName: 'VpnGw1AZ'
    enablePrivateIpAddress: true
    allowVirtualWanTraffic: true
    allowRemoteVnetTraffic: true
    vpnClientAadConfiguration: {
      aadAudience: 'c632b3df-fb67-4d84-bdcf-b95ad541b5c8' //Default audience for Azure VPN Client when using Microsoft registered application for VPN P2S configuration.
      aadIssuer: 'https://sts.windows.net/${tenant().tenantId}/'
      aadTenant: 'https://${environment().authentication.loginEndpoint}/${tenant().tenantId}/'
      vpnAuthenticationTypes: [
        'AAD'
        'Certificate'
      ]
      vpnClientProtocols: [
        'OpenVPN'
        'IkeV2'
      ]
    }
    vpnGatewayGeneration: 'Generation2'
    vpnClientAddressPoolPrefix: vpnClientAddressPoolPrefix
  }
}
