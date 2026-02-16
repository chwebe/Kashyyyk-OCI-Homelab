#!/bin/sh
# Alpine Linux cloud-init script for WireGuard VPN

# Update package index
apk update

# Install essential packages
apk add --no-cache \
    wireguard-tools \
    wireguard-lts \
    iptables \
    curl \
    openssh \
    sudo

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

# Create WireGuard configuration directory
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

# Generate WireGuard keys (server side)
cd /etc/wireguard
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Create basic WireGuard server configuration
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = $(cat server_private.key)
Address = 10.8.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client configuration will be added here
EOF

# Set proper permissions
chmod 600 /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/server_private.key

# Enable WireGuard service
rc-update add wireguard

# Start WireGuard
wg-quick up wg0

# Create a simple script to add clients
cat > /usr/local/bin/add-client.sh << 'EOF'
#!/bin/sh
CLIENT_NAME=$1
if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

cd /etc/wireguard
wg genkey | tee ${CLIENT_NAME}_private.key | wg pubkey > ${CLIENT_NAME}_public.key

CLIENT_PRIVATE=$(cat ${CLIENT_NAME}_private.key)
CLIENT_PUBLIC=$(cat ${CLIENT_NAME}_public.key)
SERVER_PUBLIC=$(cat server_public.key)

# Add peer to server config
cat >> wg0.conf << EOL

[Peer]
# ${CLIENT_NAME}
PublicKey = ${CLIENT_PUBLIC}
AllowedIPs = 10.8.0.2/32
EOL

# Generate client config
cat > ${CLIENT_NAME}.conf << EOL
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = 10.8.0.2/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = ${SERVER_PUBLIC}
Endpoint = $(curl -s ifconfig.me):51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

echo "Client ${CLIENT_NAME} created. Configuration saved to ${CLIENT_NAME}.conf"
echo "Restart WireGuard with: wg-quick down wg0 && wg-quick up wg0"
EOF

chmod +x /usr/local/bin/add-client.sh

# Display server information
echo "=== WireGuard Server Setup Complete ==="
echo "Server Public Key: $(cat /etc/wireguard/server_public.key)"
echo "External IP: $(curl -s ifconfig.me)"
echo ""
echo "To add a client, run: add-client.sh <client_name>"
echo "To restart WireGuard: wg-quick down wg0 && wg-quick up wg0"
