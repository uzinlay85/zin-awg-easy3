#!/bin/bash

# ==============================================================================
# AmneziaWG 3.1 (AWG3) Web UI Automation Script
# ==============================================================================
ENV_FILE="config.env"
CONTAINER_NAME="amnezia-wg-easy3"

echo "--------------------------------------------------"
echo "Starting AmneziaWG 3.1 (AWG3) Web UI Automation"
echo "--------------------------------------------------"

# Detect Server Public IP
echo "Detecting server public IP..."
SERVER_IP=$(curl -s4 --max-time 3 ifconfig.me 2>/dev/null || curl -s4 --max-time 3 icanhazip.com 2>/dev/null || curl -s4 --max-time 3 api.ipify.org 2>/dev/null || echo "127.0.0.1")
echo "Detected Public IP: ${SERVER_IP}"

# Step 1: Check if config.env exists. If not, try to extract from running amnezia-wg-easy3 container
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
fi

# Step 2: If config.env still doesn't exist, ask the user with smart defaults
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
    
    echo "Generating Password Hash..."
    HASH=$(sudo docker run -i --entrypoint="" amnezia-wg-easy:3.1 node /app/wgpw.mjs "$PASSWORD" 2>/dev/null | grep '^PASSWORD_HASH=' | cut -d"'" -f2)
    if [ -z "$HASH" ]; then
        HASH=$(sudo docker run -i amnezia-wg-easy:3.1 wgpw "$PASSWORD" 2>/dev/null | grep '^PASSWORD_HASH=' | cut -d"'" -f2)
    fi
    
    if [ -z "$HASH" ]; then
        echo "ERROR: Failed to generate password hash. Make sure amnezia-wg-easy:3.1 image is built."
        echo "Run: sudo docker build --network host -t amnezia-wg-easy:3.1 ."
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

# Step 3: Automatic wg0.json migration (AmneziaWG 3.1 parameters update)
echo "Checking for wg0.json configuration file to auto-update..."
WG_JSON_PATH=$(find /home /root -name "wg0.json" 2>/dev/null | head -n 1)

if [ -n "$WG_JSON_PATH" ] && [ -f "$WG_JSON_PATH" ]; then
    echo "Found wg0.json at: $WG_JSON_PATH"
    
    # Run inline Node.js migration script
    node -e '
const fs = require("fs");
const crypto = require("crypto");
const filePath = process.argv[1];
try {
  const data = JSON.parse(fs.readFileSync(filePath, "utf8"));
  if (data && data.server) {
    let modified = false;
    const h1 = String(data.server.h1 || "");
    const i1 = String(data.server.i1 || "");
    
    // Check range headers
    if (!h1.includes("-") || i1.includes("0x160301")) {
      data.server.h1 = "1000500000-1000600000";
      data.server.h2 = "1824000500-1824000600";
      data.server.h3 = "2648000500-2648000502";
      data.server.h4 = "3472000500-3473000500";
      data.server.i1 = "<b 0xc700000001><rc 8><t><r 100>";
      data.server.i2 = "<b 0xf6ab3267fa><t><rc 20><r 80>";
      data.server.i3 = "";
      data.server.i4 = "";
      data.server.i5 = "";
      modified = true;
    }
    
    // Migrate to AWG 3.1 parameters
    if (!data.server.headerProtectionKey) {
      console.log("Migrating wg0.json to AmneziaWG 3.1...");
      data.server.headerProtectionKey = crypto.randomBytes(32).toString("base64");
      data.server.contentPaddingAddition = "10-54";
      data.server.rekeyAfterTime = "103-136";
      data.server.rekeyTimeout = "4-6";
      data.server.rejectAfterTime = "170-200";
      data.server.keepaliveTimeout = "9-13";
      data.server.maxHandshakeAttempts = "17-20";
      data.server.randomTrailers = "on";
      data.server.disableCookies = "on";
      modified = true;
    }
    
    // Ensure junk sizes are at least 12 for HeaderProtectionKey
    if (typeof data.server.s1 === "number" && data.server.s1 < 12) { data.server.s1 = 15; modified = true; }
    if (typeof data.server.s2 === "number" && data.server.s2 < 12) { data.server.s2 = 15; modified = true; }
    if (typeof data.server.s3 === "number" && data.server.s3 < 12) { data.server.s3 = 16; modified = true; }
    if (typeof data.server.s4 === "number" && data.server.s4 < 12) { data.server.s4 = 18; modified = true; }
    
    if (modified) {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2), "utf8");
      console.log("[SUCCESS] wg0.json updated to AmneziaWG 3.1.");
    } else {
      console.log("wg0.json already has AmneziaWG 3.1 parameters. No migration needed.");
    }
  }
} catch (err) {
  console.error("[ERROR] Failed to parse or update wg0.json:", err.message);
}
' "$WG_JSON_PATH"
else
    echo "No wg0.json found yet. (This is normal for fresh installations)."
fi

# Determine volume source directory for AWG3 (never overwrites AWG2)
VOL_DIR="/home/zinko/.amnezia-wg-easy3"
if [ ! -d "/home/zinko" ]; then
    VOL_DIR="/root/.amnezia-wg-easy3"
fi
mkdir -p "$VOL_DIR"

# Stop only the AWG3 container (leaves AWG2 untouched)
echo "Stopping old $CONTAINER_NAME container if running..."
sudo docker stop "$CONTAINER_NAME" 2>/dev/null || true
sudo docker rm "$CONTAINER_NAME" 2>/dev/null || true

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
