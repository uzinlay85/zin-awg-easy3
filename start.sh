#!/bin/bash

# ==============================================================================
# AmneziaWG 3.1 (AWG3) Web UI Automation Script
# ==============================================================================
ENV_FILE="config.env"
CONTAINER_NAME="amnezia-wg-easy3"

echo "--------------------------------------------------"
echo "Starting AmneziaWG 3.1 (AWG3) Web UI Automation"
echo "--------------------------------------------------"

# Check and Auto-Install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
    echo "[!] Docker is not installed on this system."
    echo "Installing Docker and NAT module now..."
    sudo modprobe iptable_nat 2>/dev/null || true
    echo "iptable_nat" | sudo tee /etc/modules-load.d/iptable_nat.conf >/dev/null 2>&1 || true
    sudo apt update && sudo apt install -y docker.io git
    sudo systemctl enable --now docker
    if ! command -v docker >/dev/null 2>&1; then
        echo "[-] ERROR: Failed to install Docker. Please install Docker manually."
        exit 1
    fi
    echo "[+] Docker installed and started successfully."
fi

# Step 0: Optimize Host MTU and TCPMSS Clamping for Cloud Nodes (Fixes TLS Handshake & Packet Drops)
DEFAULT_IF=$(ip route show default 2>/dev/null | awk '{print $5}' | head -n 1)
if [ -n "$DEFAULT_IF" ]; then
    CURRENT_MTU=$(cat /sys/class/net/"$DEFAULT_IF"/mtu 2>/dev/null || echo "1500")
    if [ "$CURRENT_MTU" -gt 1400 ]; then
        echo "Optimizing Host Network MTU: Changing ${DEFAULT_IF} MTU from ${CURRENT_MTU} -> 1400 for cloud stability..."
        sudo ip link set dev "$DEFAULT_IF" mtu 1400 2>/dev/null || true
    fi
fi
# Ensure TCP MSS clamping is present
if ! sudo iptables -t mangle -C POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null; then
    sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
fi

# Detect Server Public IP
echo "Detecting server public IP..."
SERVER_IP=$(curl -s4 --max-time 3 ifconfig.me 2>/dev/null || curl -s4 --max-time 3 icanhazip.com 2>/dev/null || curl -s4 --max-time 3 api.ipify.org 2>/dev/null || echo "127.0.0.1")
echo "Detected Public IP: ${SERVER_IP}"

# Step 1: Check for command line arguments (e.g. ./start.sh passwd / ./start.sh password)
CHANGE_PASSWORD=false
if [ "$1" == "passwd" ] || [ "$1" == "password" ] || [ "$1" == "--password" ] || [ "$1" == "-p" ]; then
    CHANGE_PASSWORD=true
fi

# Step 2: Check if config.env exists. If not, try to extract from running amnezia-wg-easy3 container
if [ ! -f "$ENV_FILE" ]; then
    echo "No $ENV_FILE found. Checking if there is an active $CONTAINER_NAME container to restore config..."
    if sudo docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Found running $CONTAINER_NAME container! Extracting parameters..."
        DOMAIN=$(sudo docker inspect "$CONTAINER_NAME" --format='{{range .Config.Env}}{{println .}}{{end}}' | grep '^WG_HOST=' | cut -d= -f2)
        HASH=$(sudo docker inspect "$CONTAINER_NAME" --format='{{range .Config.Env}}{{println .}}{{end}}' | grep '^PASSWORD_HASH=' | cut -d= -f2)
        PORT=$(sudo docker inspect "$CONTAINER_NAME" --format='{{range .Config.Env}}{{println .}}{{end}}' | grep '^PORT=' | cut -d= -f2)
        WG_PORT=$(sudo docker inspect "$CONTAINER_NAME" --format='{{range .Config.Env}}{{println .}}{{end}}' | grep '^WG_PORT=' | cut -d= -f2)
        
        if [ -n "$DOMAIN" ] && [ -n "$HASH" ]; then
            cat << EOF > "$ENV_FILE"
WG_HOST=${DOMAIN}
PASSWORD_HASH=${HASH}
PORT=${PORT:-51833}
WG_PORT=${WG_PORT:-51820}
WG_DEFAULT_ADDRESS=10.8.1.x
WG_MTU=1280
UI_ENABLE_SORT_CLIENTS=true
UI_TRAFFIC_STATS=true
WG_ENABLE_EXPIRES_TIME=true
WG_ENABLE_ONE_TIME_LINKS=true
EOF
            echo "Successfully restored settings and created $ENV_FILE."
        fi
    fi
elif [ "$CHANGE_PASSWORD" = false ]; then
    echo ""
    echo "Current setup detected with existing $ENV_FILE."
    echo "1) Keep current settings and start"
    echo "2) Change Web UI Admin Password"
    echo "3) Reconfigure everything (Domain, Ports, Password)"
    read -p "Select option [Default: 1]: " MENU_CHOICE
    if [ "$MENU_CHOICE" == "2" ]; then
        CHANGE_PASSWORD=true
    elif [ "$MENU_CHOICE" == "3" ]; then
        rm -f "$ENV_FILE"
    fi
fi

# Step 3: Handle Password Change if requested
if [ "$CHANGE_PASSWORD" = true ] && [ -f "$ENV_FILE" ]; then
    echo ""
    echo "=== Change Web UI Admin Password ==="
    read -s -p "Enter NEW Admin Password: " NEW_PASSWORD
    echo ""
    if [ -n "$NEW_PASSWORD" ]; then
        echo "Generating new password hash..."
        NEW_HASH=$(sudo docker run -i --entrypoint="" amnezia-wg-easy:3.1 node /app/wgpw.mjs "$NEW_PASSWORD" 2>/dev/null | grep '^PASSWORD_HASH=' | cut -d"'" -f2)
        if [ -z "$NEW_HASH" ]; then
            NEW_HASH=$(sudo docker run -i amnezia-wg-easy:3.1 wgpw "$NEW_PASSWORD" 2>/dev/null | grep '^PASSWORD_HASH=' | cut -d"'" -f2)
        fi
        
        if [ -n "$NEW_HASH" ]; then
            # Update PASSWORD_HASH and ADMIN_PASSWORD in config.env
            if grep -q '^PASSWORD_HASH=' "$ENV_FILE"; then
                sed -i "s|^PASSWORD_HASH=.*|PASSWORD_HASH=${NEW_HASH}|" "$ENV_FILE"
            else
                echo "PASSWORD_HASH=${NEW_HASH}" >> "$ENV_FILE"
            fi
            
            if grep -q '^ADMIN_PASSWORD=' "$ENV_FILE"; then
                sed -i "s|^ADMIN_PASSWORD=.*|ADMIN_PASSWORD=${NEW_PASSWORD}|" "$ENV_FILE"
            else
                echo "ADMIN_PASSWORD=${NEW_PASSWORD}" >> "$ENV_FILE"
            fi
            echo "✅ Password successfully updated in $ENV_FILE."
        else
            echo "❌ Failed to generate password hash. Keeping old password."
        fi
    else
        echo "No password entered. Keeping current password."
    fi
fi

# Step 4: If config.env still doesn't exist, ask the user with smart defaults
if [ ! -f "$ENV_FILE" ]; then
    echo ""
    echo "=== Configure Settings (Press Enter to use Default) ==="
    read -p "Enter your VPN Domain or Server IP [Default: ${SERVER_IP}]: " INPUT_DOMAIN
    DOMAIN="${INPUT_DOMAIN:-${SERVER_IP}}"

    read -p "Enter Web UI Port [Default: 51833]: " INPUT_PORT
    PORT="${INPUT_PORT:-51833}"

    read -p "Enter VPN UDP Port [Default: 51820]: " INPUT_WG_PORT
    WG_PORT="${INPUT_WG_PORT:-51820}"

    read -s -p "Enter your VPN Admin Password [Default: admin123]: " INPUT_PASSWORD
    echo ""
    PASSWORD="${INPUT_PASSWORD:-admin123}"
    
    # Check if Docker image is built; if not, build it automatically
    if ! sudo docker image inspect amnezia-wg-easy:3.1 >/dev/null 2>&1; then
        echo "AmneziaWG 3.1 Docker image not found. Building image now (this may take 2-3 minutes)..."
        sudo docker build --network host -t amnezia-wg-easy:3.1 .
        if [ $? -ne 0 ]; then
            echo "ERROR: Docker build failed. Please check build logs."
            exit 1
        fi
    fi

    echo "Generating Password Hash..."
    HASH=$(sudo docker run -i --entrypoint="" amnezia-wg-easy:3.1 node /app/wgpw.mjs "$PASSWORD" 2>/dev/null | grep '^PASSWORD_HASH=' | cut -d"'" -f2)
    if [ -z "$HASH" ]; then
        HASH=$(sudo docker run -i amnezia-wg-easy:3.1 wgpw "$PASSWORD" 2>/dev/null | grep '^PASSWORD_HASH=' | cut -d"'" -f2)
    fi
    
    if [ -z "$HASH" ]; then
        echo "ERROR: Failed to generate password hash."
        exit 1
    fi
    
    cat << EOF > "$ENV_FILE"
WG_HOST=${DOMAIN}
PASSWORD_HASH=${HASH}
ADMIN_PASSWORD=${PASSWORD}
PORT=${PORT}
WG_PORT=${WG_PORT}
WG_DEFAULT_ADDRESS=10.8.1.x
WG_MTU=1280
UI_ENABLE_SORT_CLIENTS=true
UI_TRAFFIC_STATS=true
WG_ENABLE_EXPIRES_TIME=true
WG_ENABLE_ONE_TIME_LINKS=true
EOF
    echo "Created new $ENV_FILE file."
fi

# Load the variables
source "$ENV_FILE"

# Ensure DOMAIN and DISPLAY_DOMAIN are set (use WG_HOST from config, fallback to SERVER_IP)
DOMAIN="${WG_HOST:-${SERVER_IP}}"

# Step 3: Check volume directory for AWG3 (never overwrites AWG2)
VOL_DIR="/home/zinko/.amnezia-wg-easy3"
if [ ! -d "/home/zinko" ]; then
    VOL_DIR="/root/.amnezia-wg-easy3"
fi
mkdir -p "$VOL_DIR"

# Stop only the AWG3 container (leaves AWG2 untouched)
echo "Stopping old $CONTAINER_NAME container if running..."
sudo docker stop "$CONTAINER_NAME" 2>/dev/null || true
sudo docker rm "$CONTAINER_NAME" 2>/dev/null || true

# Enable Host IP Forwarding and NAT Masquerading for VPN Subnet
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
sudo iptables -P FORWARD ACCEPT >/dev/null 2>&1
DEFAULT_SUBNET="${WG_DEFAULT_ADDRESS:-10.8.1.x}"
SUBNET_CIDR="${DEFAULT_SUBNET/x/0}/24"
if ! sudo iptables -t nat -C POSTROUTING -s "$SUBNET_CIDR" -j MASQUERADE 2>/dev/null; then
    sudo iptables -t nat -A POSTROUTING -s "$SUBNET_CIDR" -j MASQUERADE 2>/dev/null || true
fi

# Configure UFW Firewall if installed
if command -v ufw >/dev/null 2>&1; then
    echo "Configuring Firewall (UFW)..."
    sudo ufw allow "${WG_PORT}/udp"
    sudo ufw allow "${PORT}/tcp"
    sudo ufw reload
    echo "[+] Firewall configured: Opened ${WG_PORT}/udp (VPN) and ${PORT}/tcp (Web UI)."
else
    echo "[!] UFW is not installed. Skipping firewall configuration."
fi

echo "Starting container with volume mapping: $VOL_DIR -> /etc/wireguard"
sudo docker run -d \
  --name="$CONTAINER_NAME" \
  --env-file "$ENV_FILE" \
  -v "$VOL_DIR:/etc/wireguard" \
  -p "${WG_PORT}:${WG_PORT}/udp" \
  -p "${PORT}:${PORT}/tcp" \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --device=/dev/net/tun:/dev/net/tun \
  --restart=unless-stopped \
  amnezia-wg-easy:3.1

echo ""
echo "=================================================="
echo "🎉 AmneziaWG 3.1 (AWG3) is now running successfully!"
echo "=================================================="
echo "🌐 Web UI Panel : http://${DOMAIN}:${PORT}"
if [ -n "$ADMIN_PASSWORD" ]; then
    echo "🔑 Admin Pass   : ${ADMIN_PASSWORD}"
else
    echo "🔑 Admin Pass   : (Configured in PASSWORD_HASH)"
fi
echo "🛡️  VPN Endpoint : ${DOMAIN}:${WG_PORT} (UDP)"
echo "📁 Volume Path  : ${VOL_DIR}"
echo "=================================================="
sudo docker ps | grep "$CONTAINER_NAME"
