# QQG.NET Cloud Node & Multi-VPN (AWG3, Outline, 3X-UI) Setup & Optimization Guide

ဒီ Guide သည် **QQG.NET Cloud VPS** (သို့မဟုတ် virtualized cloud nodes များ) ပေါ်တွင် **AmneziaWG 3.1 (AWG3)**၊ **Outline VPN (Shadowbox)** နှင့် **3X-UI** များကို အတူတွဲဖက် run သည့်အခါ ကြုံတွေ့ရတတ်သော ပြဿနာများ၊ အကြောင်းရင်းများ၊ ကြိုတင်စစ်ဆေးရမည့် အချက်များနှင့် Error ကင်းကင်းဖြင့် Setup လုပ်နည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## 📌 အပိုင်း (၁) - ကျွန်ုပ်တို့ လက်တွေ့ကြုံတွေ့ခဲ့ရသော ပြဿနာများနှင့် ၎င်းတို့၏ အဓိက အကြောင်းရင်းများ (Root Causes)

### ၁။ Docker Hub သို့ ချိတ်ဆက်ရာတွင် `TLS handshake timeout` ဖြစ်ခြင်း
- **ဖြစ်စဉ်:** `docker build` သို့မဟုတ် `docker pull` ပြုလုပ်သည့်အခါ `Head "https://registry-1.docker.io/v2/...": net/http: TLS handshake timeout` ဟုပြပြီး ရပ်တန့်သွားခြင်း။
- **အကြောင်းရင်း:** QQG.NET VPS ၏ အပေါ်ဘက် Network Routing တွင် Default Standard MTU (1500) ကို အပြည့်အဝ မပို့နိုင်ဘဲ SSL/TLS Handshake အကြီးစား Packet များကို Drop ပစ်ချနေခြင်းကြောင့် ဖြစ်သည်။
- **ဖြေရှင်းချက်:** Host Network Interface ၏ MTU ကို **`1400`** သို့ ပြောင်းလဲသတ်မှတ်ပေးရမည်။

### ၂။ Docker Service Restart လုပ်ပြီးနောက် VPN အင်တာနက်မထွက်တော့ခြင်း / မချိတ်တော့ခြင်း
- **ဖြစ်စဉ်:** Outline VPN သွင်းစဉ် (သို့မဟုတ်) `sudo systemctl restart docker` လုပ်လိုက်ပြီးနောက် အရင်က ကောင်းနေသော AmneziaWG သည် ဖုန်းတွင် ချိတ်သော်လည်း အင်တာနက် လုံးဝမထွက်တော့ခြင်း။
- **အကြောင်းရင်း:** Docker service restart ကျသွားတိုင်း Linux ၏ `iptables` rules များကို Docker က default reset ချပစ်လိုက်သဖြင့် Host ပေါ်တွင် ကျွန်ုပ်တို့ ဖွင့်ထားခဲ့သော **IP Forwarding** နှင့် **NAT MASQUERADE** rules များ ပျက်ပြယ်သွားခြင်းကြောင့် ဖြစ်သည်။

### ၃။ AmneziaWG 3.1 တွင် `I1` နှင့် `I2` ထည့်ထားပါက Client Handshake လုံးဝ မတက်ခြင်း
- **ဖြစ်စဉ်:** Server ဘက်တွင် interface ပုံမှန်တက်နေသော်လည်း ဖုန်းဘက်မှ Connect နှိပ်သည့်အခါ Packet တစ်ခုမှ မရောက်လာခြင်း။
- **အကြောင်းရင်း:** မိုဘိုင်း AmneziaWG App များသည် `<b 0xc700000001><rc 8><t><r 100>` ကဲ့သို့သော hex/regex packet junk patterns များကို syntax parse မလုပ်နိုင်ဘဲ App ဘက်မှ Handshake packet ကို စတင်မလွှတ်နိုင်ခြင်းကြောင့် ဖြစ်သည်။
- **ဖြေရှင်းချက်:** `I1`, `I2` များကို ဖယ်ရှားပြီး AWG3 ၏ HeaderProtectionKey, ContentPaddingAddition နှင့် Randomized Timings များကိုသာ အသုံးပြုရမည်။

### ၄။ Wi-Fi နှင့် Mobile Data ကြား ချိတ်ဆက်မှု ကွဲပြားခြင်း
- **ဖြစ်စဉ်:** Mobile Data တွင် ချိတ်သော်လည်း Wi-Fi ရောက်သည့်အခါ Handshake မတက်ခြင်း သို့မဟုတ် Wi-Fi Router က Packet drop ဖြစ်ခြင်း။
- **အကြောင်းရင်း:** ပြည်တွင်း Wi-Fi (Fiber) Router များ၏ MTU Size နှင့် Provider UDP ပိတ်ဆို့မှုများကြောင့် ဖြစ်သည်။ Client ဘက်တွင် `MTU = 1200` ထားပေးခြင်း သို့မဟုတ် Server ဘက်တွင် VPN Port အား `UDP 443` အဖြစ် အသုံးပြုခြင်းဖြင့် မည်သည့် ISP မှ ပိတ်မရအောင် ဖြေရှင်းနိုင်ပါသည်။

---

## 🛠️ အပိုင်း (၂) - QQG Node အသစ်ရရှိပါက ပထမဆုံး ကြိုတင်လုပ်ဆောင်ရမည့်အဆင့် (Pre-flight Checklist)

ဆာဗာအသစ် ဝယ်ယူပြီးသည်နှင့် မည်သည့် VPN မသွင်းမီ အောက်ပါ အဆင့် ၃ ဆင့်ကို **root** ဖြင့် အရင်ဆုံး run ပေးပါ:

### ၁။ Host MTU ကို 1400 သို့ သတ်မှတ်ခြင်း (အရေးအကြီးဆုံး)
```bash
# Default Network Interface ကို ရှာပြီး MTU 1400 သို့ လျှော့ချခြင်း
DEFAULT_IF=$(ip route show default | awk '{print $5}')
sudo ip link set dev $DEFAULT_IF mtu 1400

# Reboot တက်တိုင်း အမြဲ 1400 ဖြစ်နေစေရန် network config တွင် မှတ်ထားရန်
echo "ip link set dev $DEFAULT_IF mtu 1400" | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local 2>/dev/null || true
```

### ၂။ NAT Module နှင့် IP Forwarding ကို အမြဲတမ်း ပွင့်နေစေရန် သတ်မှတ်ခြင်း
```bash
# NAT Module ဖွင့်ခြင်း
sudo modprobe iptable_nat
echo "iptable_nat" | sudo tee /etc/modules-load.d/iptable_nat.conf

# IP Forwarding ဖွင့်ခြင်း
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# TCP MSS Clamping ဖွင့်ခြင်း
sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

### ၃။ Docker သွင်းခြင်းနှင့် DNS သတ်မှတ်ခြင်း
```bash
sudo apt update && sudo apt install -y docker.io git curl

# Docker DNS ကို Cloudflare & Google DNS သို့ ပြောင်းလဲခြင်း
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "dns": ["1.1.1.1", "8.8.8.8"]
}
EOF

sudo systemctl enable --now docker
```

---

## 🛡️ အပိုင်း (၃) - Outline VPN သွင်းသည့်အခါ သတိပြုရန် (Outline Coexistence)

Outline VPN ကို AmneziaWG ရှိပြီးသား ဆာဗာတွင် သွင်းသည့်အခါ **အောက်ပါ စည်းမျဉ်း ၃ ချက်ကို မဖြစ်မနေ လိုက်နာရပါမည်:**

### စည်းမျဉ်း (၁) - Outline Port များကို AmneziaWG နှင့် လုံးဝ မတူအောင် သီးသန့် သတ်မှတ်ပါ
Default Outline script သည် random ports များ ရွေးချယ်တတ်သဖြင့် Port ပွတ်တိုက်မှု မဖြစ်စေရန် port သီးသန့် ပေးသွင်းပါ:
```bash
# Outline API Port: 18443
# Outline VPN Keys Port: 10443
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/OutlineFoundation/outline-apps/master/server_manager/install_scripts/install_server.sh)" -- --api-port=18443 --keys-port=10443
```

### စည်းမျဉ်း (၂) - Outline သွင်းပြီးပါက `start.sh` ကို ပြန် run ပေးပါ
Outline script သည် Docker ကို reload လုပ်ပြီး iptables များကို ထိခိုက်စေတတ်သောကြောင့် Outline သွင်းပြီးသည်နှင့် AmneziaWG 3.1 folder ထဲသို့ သွား၍:
```bash
cd /home/zinko/zin-awg-easy3
./start.sh
```
ကို မဖြစ်မနေ ပြန်လည် run ပေးရပါမည်။ (ကျွန်ုပ်တို့၏ `start.sh` က NAT Forwarding rules များကို auto ပြန်လည်ပြင်ဆင်ပေးပါမည်)။

---

## ⚡ အပိုင်း (၄) - 3X-UI (VLESS / Hysteria 2) သွင်းသည့်အခါ သတိပြုရန်

3X-UI panel ကိုပါ ဤဆာဗာပေါ်တွင် ပူးတွဲတပ်ဆင်လိုပါက:

### ၁။ Web Panel Port မတူအောင် သတ်မှတ်ပါ
- AmneziaWG 3.1 Web UI: **`51833`** (TCP)
- 3X-UI Web Panel: **`2053`** သို့မဟုတ် **`2096`** (TCP)
*(တစ်ခုနှင့်တစ်ခု မငြိစွန်းပါ)*

### ၂။ Inbound Protocols Ports ခွဲဝေမှု
- AmneziaWG 3.1 VPN: **`51820`** (UDP) သို့မဟုတ် **`443`** (UDP)
- VLESS-Reality: **`443`** (TCP)
> ⚠️ **မှတ်ချက်:** အကယ်၍ VLESS-Reality ကို TCP 443 သုံးထားပါက AmneziaWG ကို **UDP 443** (သို့မဟုတ် UDP 51820) ဖြင့် အေးဆေးစွာ တွဲဖက်အသုံးပြုနိုင်ပါသည်။ (TCP နှင့် UDP သည် port နံပါတ် တူနေသော်လည်း protocol ကွဲပြား၍ ပွတ်တိုက်မှု လုံးဝမဖြစ်ပါ)။

---

## 🔍 အပိုင်း (၅) - အရေးပေါ် ချိတ်မရပါက စစ်ဆေးရမည့် Cheat Sheet

အကယ်၍ ရုတ်တရက် ချိတ်မရတော့ပါက အောက်ပါအတိုင်း ၃ မိနစ်အတွင်း စစ်ဆေးပါ:

| စစ်ဆေးမည့်အချက် | Command | အဖြေနှင့် ဖြေရှင်းချက် |
|---|---|---|
| **၁။ Client Packet ရောက်/မရောက်** | `sudo tcpdump -n -i any udp port 51820` | စာတန်းမတက်ပါက ဖုန်း Mobile Data ပြောင်းပါ သို့မဟုတ် QQG Firewall စစ်ပါ။ |
| **၂။ Handshake အခြေအနေ** | `sudo docker exec -it amnezia-wg-easy3 awg show` | `latest handshake` ပေါ်ရမည်။ မပေါ်ပါက Client Key အသစ် ပြန်ထုတ်ပါ။ |
| **၃။ IP Forwarding** | `sudo sysctl net.ipv4.ip_forward` | `net.ipv4.ip_forward = 1` ဖြစ်ရမည်။ `0` ဖြစ်နေပါက `sudo sysctl -w net.ipv4.ip_forward=1` ပေးပါ။ |
| **၄။ NAT MASQUERADE** | `sudo iptables -t nat -L POSTROUTING -n` | `10.8.1.0/24 MASQUERADE` ပါရမည်။ မပါပါက `./start.sh` ကို ပြန် run ပါ။ |
| **၅။ MTU Issue** | `curl -Iv https://registry-1.docker.io/v2/` | TLS handshake hang နေပါက `sudo ip link set dev <IF> mtu 1400` ပေးပါ။ |
