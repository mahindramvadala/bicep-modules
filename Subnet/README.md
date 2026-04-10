# Subnet

Bicep module to create subnet within a Virtual Network.

## Description

Use this module within a bicep file to simplify deployment of subnet. It also allows association of NAT Gateway, NSG and route table to the subnet along with Service Endpoint(s) and delegation.

## Scope

This module should be scoped to resource group where the VNET resides.

## Path

Not published to private regsitry

## Parameters

| Name | Type | Required | Description |
| :--- | :--- | :------- | :---------- |
| `subnets` | `VirtualNetworkSubnet[]` | Yes | List of subnets to be created. |
| `vnetName` | `string` | Yes | Name of the VNET where the subnets need to be created. |

## Outputs

| Name | Type | Description |
| :---- | :--- | :---------- |
| `id` | `string[]` | List of Resource Id of the subnets to be created. |
| `name` | `string[]` | List of the names of the subnets to be created. |
| `rg` | `string` | RG where the subnet(s) is created. |

## Examples

```bicep

```