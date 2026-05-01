#!/bin/bash

# --- Config vars ---
NET_NAME="hub-net"
BRIDGE_NAME="virbr-hub"
DOMAIN_NAME="lab.localdomain"
CLUSTER_NAME="hub"

# Configuração de IP
IP_PREFIX="192.168.101"
IP_GW="${IP_PREFIX}.1"
IP_SNO="4"

XML_FILE="/tmp/${NET_NAME}.xml"

echo "Generating network XML for: $NET_NAME..."

# Create the XML file with dnsmasq options
cat <<EOF > $XML_FILE
<network xmlns:dnsmasq="http://libvirt.org/schemas/network/dnsmasq/1.0">
  <name>${NET_NAME}</name>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535"/>
    </nat>
  </forward>
  <bridge name="${BRIDGE_NAME}" stp="on" delay="0"/>
  <domain name="${DOMAIN_NAME}"/>
  <ip address="${IP_GW}" netmask="255.255.255.0">
  </ip>
  <dnsmasq:options>
    <dnsmasq:option value="no-resolv"/>
    <dnsmasq:option value="address=/apps.${CLUSTER_NAME}.${DOMAIN_NAME}/${IP_PREFIX}.${IP_SNO}"/>
    <dnsmasq:option value="address=/api.${CLUSTER_NAME}.${DOMAIN_NAME}/${IP_PREFIX}.${IP_SNO}"/>
    <dnsmasq:option value="address=/m1.${CLUSTER_NAME}.${DOMAIN_NAME}/${IP_PREFIX}.${IP_SNO}"/>
    <dnsmasq:option value="address=/registry.${CLUSTER_NAME}.${DOMAIN_NAME}/${IP_GW}"/>
    <dnsmasq:option value="address=/webserver.${CLUSTER_NAME}.${DOMAIN_NAME}/${IP_GW}"/>
    <dnsmasq:option value="server=/pool.ntp.org/${IP_GW}"/>
    <dnsmasq:option value="server=/github.com/${IP_GW}"/>
  </dnsmasq:options>
</network>
EOF

# Define the network in Libvirt
echo "Defining the network in Libvirt..."
virsh net-define $XML_FILE

# Set the network to start automatically on boot
echo "Setting autostart for network: $NET_NAME..."
virsh net-autostart $NET_NAME

# Start the network
echo "Starting the network..."
virsh net-start $NET_NAME

# Clean up the temporary file
rm $XML_FILE

echo "------------------------------------------------"
echo "Network $NET_NAME is now active and set to autostart."
echo "Bridge: $BRIDGE_NAME | Gateway: $IP_GW"
echo "DNS Target: ${IP_PREFIX}.${IP_RANGE_END}"
echo "Cluster: $CLUSTER_NAME | Domain: $DOMAIN_NAME"
echo "------------------------------------------------"
