#!/usr/bin/env bash

eval "$(cat /usr/sbin/scripting/logging.sh)"
eval "$(cat /usr/sbin/scripting/formatting.env)"


build_bare_metal_bridge() {
  local local_lan_ip=192.168.0.101
  local baremetal_ip=192.168.203.101

  if [ "$HOSTNAME" = NUC02 ]; then
      local_lan_ip=192.168.0.102
      baremetal_ip=192.168.203.102
  fi

  # Configure local subnet info
  #  sudo nmcli connection modify enp87s0 ipv4.addresses "${local_lan_ip}"/24 ipv4.gateway 192.168.0.1 ipv4.method manual
  #  sudo nmcli connection up enp87s0

  print_msg "bare-metal-bridge: Creating 'baremetal' (VLAN interface) and 'bm' (bridge interface):" \
    "Host: $HOSTNAME" \
    "Baremetal IP: $baremetal_ip"
  # Create VLAN 2003 interface
  sudo nmcli connection add type vlan con-name baremetal ifname baremetal dev enp87s0 id 2003 >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create VLAN 2003 interface 'baremetal' on 'enp87s0'!"
    return 1
  }
  sudo nmcli connection modify baremetal ipv4.addresses "${baremetal_ip}"/24 ipv4.method manual >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create set ipv4 address on 'baremetal' for 'enp87s0'!"
    return 1
  }

  # Create Bridge interface for VLAN 2003
  sudo nmcli connection add type bridge con-name bm ifname bm >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create create bridge 'bm' interface!"
    return 1
  }
  sudo nmcli connection add type bridge-slave ifname baremetal master bm >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to set 'baremetal' interface as 'bm' interface's slave!"
    return 1
  }
  sudo nmcli connection modify bm ipv4.addresses "${baremetal_ip}"/24 ipv4.gateway 192.168.203.1 ipv4.method manual >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to create set ipv4 address on 'bm' for 'enp87s0'!"
    return 1
  }

  # Activate VLAN and Bridge interfaces
  sudo nmcli connection up baremetal >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to bring interface 'baremetal' online!"
    return 1
  }
  sudo nmcli connection up bm >/dev/null 2>&1 || {
    err "bare-metal-bridge: Failed to bring interface 'bm' online!"
    return 1
  }
}

build_bare_metal_bridge || {
  err "bare-metal-bridge: Failed to create 'bm' bridge for VLAN 2003!"
  exit
}
log "bare-metal-bridge: done!"