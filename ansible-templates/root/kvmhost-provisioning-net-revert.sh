#!/usr/bin/env bash

# first check if bridge is present
if ip link show type bridge {{ bridge_prov }} >/dev/null 2>&1; then
    echo "Bridge {{ bridge_prov }} found! Reverting networking changes..."
else
    echo "Bridge {{ bridge_prov }} is not present. Skipping config revert..."
    exit 0
fi

# Variables
BRIDGE_PROV={{ bridge_prov }}
INTERFACE={{ ansible_default_ipv4.interface }}
IP_ADDRESS={{ ansible_default_ipv4.address }}
PREFIX={{ ansible_default_ipv4.prefix }}
GATEWAY={{ ansible_default_ipv4.gateway }}
DNS_SERVER={{ ansible_dns.nameservers[0] }}
DNS_SEARCH={{ ansible_dns.search[0] }}

# Delete the bridge connection
nmcli connection delete "$BRIDGE_PROV"

# Delete the bridge slave connection
nmcli connection delete bridge-slave-"$INTERFACE"

# Restore the original connection for the interface
nmcli connection add type ethernet ifname "$INTERFACE" con-name "$INTERFACE"
nmcli connection modify "$INTERFACE" ipv4.method manual
nmcli connection modify "$INTERFACE" ipv4.addresses "$IP_ADDRESS"/"$PREFIX"
nmcli connection modify "$INTERFACE" ipv4.gateway "$GATEWAY"
nmcli connection modify "$INTERFACE" ipv4.dns "$DNS_SERVER"

if [ -n "$DNS_SEARCH" ]; then
  nmcli connection modify "$INTERFACE" ipv4.dns-search "$DNS_SEARCH"
fi

nmcli connection modify "$INTERFACE" ipv6.method ignore

# Restart the network manager to apply changes
nmcli networking off && nmcli networking on

echo "Reverted network configuration changes."
