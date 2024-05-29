#!/usr/bin/env bash

export BRIDGE_INTERFACE=bm
export VLAN_INTERFACE=baremetal
export ETHERNET_INTERFACE=enp87s0

eval "$(cat /usr/sbin/scripting/logging.sh)"
eval "$(cat /usr/sbin/scripting/formatting.env)"

bridge_already_present() {
  if ip link show type bridge "$BRIDGE_INTERFACE" >/dev/null 2>&1; then
      return 0
  else
      return 1
  fi
}

configure_local_network_interface() {
  local local_lan_ip=192.168.0.101
  
  if [ "$HOSTNAME" = NUC02 ]; then
    local_lan_ip=192.168.0.102
  fi
  
  print_msg "bare-metal-bridge: Establishing static local networking on '$ETHERNET_INTERFACE':" \
      "Host: $HOSTNAME" \
      "Local LAN IP: $local_lan_ip"

  # Configure local subnet info
  sudo nmcli connection modify "$ETHERNET_INTERFACE" ipv4.addresses "${local_lan_ip}"/24 ipv4.gateway 192.168.0.1 ipv4.method auto >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to configure ipv4 address to '$local_lan_ip' for '$ETHERNET_INTERFACE'"
    return 1
  }
  sudo nmcli connection up "$ETHERNET_INTERFACE" >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed running 'nmcli connection up $ETHERNET_INTERFACE'"
    return 1
  }
}

build_bare_metal_bridge() {
  local baremetal_ip=192.168.203.101

  if [ "$HOSTNAME" = NUC02 ]; then
      baremetal_ip=192.168.203.102
  fi

  print_msg "bare-metal-bridge: Creating '$VLAN_INTERFACE' (VLAN interface) and '$BRIDGE_INTERFACE' (bridge interface):" \
      "Host: $HOSTNAME" \
      "VLAN 2003 Interface: $VLAN_INTERFACE" \
      "Bridge Interface: $BRIDGE_INTERFACE" \
      "Baremetal IP: $baremetal_ip"
  # Create VLAN 2003 interface
  sudo nmcli connection add type vlan con-name "$VLAN_INTERFACE" ifname baremetal dev "$ETHERNET_INTERFACE" id 2003 >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create VLAN 2003 interface 'baremetal' on '$ETHERNET_INTERFACE'!"
    return 1
  }
  sudo nmcli connection modify "$VLAN_INTERFACE" ipv4.addresses "${baremetal_ip}"/24 ipv4.method manual >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create set ipv4 address on 'baremetal' for '$ETHERNET_INTERFACE'!"
    return 1
  }

  # Create Bridge interface for VLAN 2003
  sudo nmcli connection add type bridge con-name "$BRIDGE_INTERFACE" ifname "$BRIDGE_INTERFACE" >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create create bridge 'bm' interface!"
    return 1
  }
  sudo nmcli connection add type bridge-slave ifname "$VLAN_INTERFACE" master "$BRIDGE_INTERFACE" >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to set 'baremetal' interface as 'bm' interface's slave!"
    return 1
  }
  sudo nmcli connection modify "$BRIDGE_INTERFACE" ipv4.addresses "${baremetal_ip}"/24 ipv4.gateway 192.168.203.1 ipv4.method manual >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create set ipv4 address on 'bm' for '$ETHERNET_INTERFACE'!"
    return 1
  }

  # Activate VLAN and Bridge interfaces
  sudo nmcli connection up "$VLAN_INTERFACE" >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to bring interface 'baremetal' online!"
    return 1
  }
  sudo nmcli connection up "$BRIDGE_INTERFACE" >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to bring interface 'bm' online!"
    return 1
  }
}

configure_local_network_interface || {
  err "bare-metal-bridge: Failed configuring LAN static network settings!"
  exit
}

if bridge_already_present; then
  log "bare-metal-bridge: Bridge '$BRIDGE_INTERFACE' is already present! Exiting..."
  exit
else
  log "bare-metal-bridge: Bridge '$BRIDGE_INTERFACE' is not present. Creating it..."
  build_bare_metal_bridge || {
      err "bare-metal-bridge: Failed to create '$BRIDGE_INTERFACE' bridge for VLAN 2003!"
      exit
  }
fi
log "bare-metal-bridge: done!"