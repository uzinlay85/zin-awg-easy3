# Comprehensive Server Network MTU Diagnostics & Optimization Guide

ဒီ Guide သည် **QQG.NET**, **RackNerd**, **Hetzner**, **DigitalOcean**, **AWS**, **Oracle Cloud** နှင့် အခြားသော Cloud/VPS များအားလုံးတွင် **Network MTU (Maximum Transmission Unit)** ကို အတိအကျ စစ်ဆေးနည်း၊ အသင့်တော်ဆုံး MTU တန်ဖိုး ရှာဖွေနည်းနှင့် VPN (AmneziaWG, WireGuard, Outline, VLESS/Hysteria) များတွင် Packet Drop / TLS Timeout မဖြစ်စေရန် စီမံခန့်ခွဲနည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## 📖 အပိုင်း (၁) - MTU ဆိုတာ ဘာလဲ? ဘာကြောင့် အရေးကြီးသလဲ?

- **MTU (Maximum Transmission Unit)** ဆိုသည်မှာ ကွန်ရက်ချိတ်ဆက်မှုတစ်ခု (Network Packet) တစ်ခုတည်းတွင် အများဆုံး သယ်ဆောင်နိုင်သော ဒေတာအရွယ်အစား (Bytes ပမာဏ) ဖြစ်သည်။
- ပုံမှန် Ethernet Internet Standard သည် **`1500 bytes`** ဖြစ်သည်။
- သို့သော် Virtualized Cloud Providers များ (ဥပမာ- QQG, OpenStack, VXLAN, GRE Tunnel သုံးသော VPS များ) သည် ၎င်းတို့၏ Network Routing Header များအတွက် နေရာဖယ်ပေးရသဖြင့် ပြင်ပသို့ ပို့နိုင်သော MTU သည် **`1400` ~ `1450`** အထိ လျော့ကျသွားတတ်သည်။

### ⚠️ MTU မကိုက်ညီပါက ဖြစ်ပေါ်လာမည့် ဆိုးကျိုးများ (Symptoms):
1. **`TLS handshake timeout` / `Connection Hang`:** အသေးစား ping များ ရသော်လည်း `curl`, `docker pull`, `git clone`, SSL ဝဘ်ဆိုက်များ ဖွင့်သည့်အခါ SSL Certificate packet များသည် 1400 ထက် ကြီးသွားသဖြင့် Router က Drop ပစ်ချပြီး ရပ်တန့်သွားခြင်း။
2. **VPN ချိတ်သော်လည်း အင်တာနက် လိုင်းမထွက်ခြင်း:** WireGuard / AmneziaWG သည် မူလ Packet ပေါ်တွင် Header များကို ထပ်မံ Encapsulate (ထပ်ပိုး) လုပ်ရသဖြင့် MTU တွက်ချက်မှု မှားယွင်းပါက Packet များ Drop သွားခြင်း။
3. **Wi-Fi တွင် မရဘဲ Mobile Data တွင်သာ ရခြင်း (သို့မဟုတ် ပြောင်းပြန်ဖြစ်ခြင်း):** Wi-Fi Fiber Router များ၏ MTU (PPPoE 1492) နှင့် Cloud VPS MTU မကိုက်ညီခြင်း။

---

## 🔍 အပိုင်း (၂) - မည်သည့်ဆာဗာတွင်မဆို အကောင်းဆုံး MTU ကို ရှာဖွေနည်း (Path MTU Discovery)

Linux တွင် ICMP Packet ၏ **`Don't Fragment (DF)`** flag ကို အသုံးပြုပြီး ဆာဗာ၏ Gateway က အများဆုံး လက်ခံနိုင်သော MTU ကို စစ်ဆေးနိုင်ပါသည်။

> 💡 **မှတ်ချက်:** IP Header (20 bytes) + ICMP Header (8 bytes) = စုစုပေါင်း **28 bytes** နုတ်၍ စမ်းသပ်ရပါသည်။
> - MTU 1500 စစ်လိုပါက: `1500 - 28 = 1472`
> - MTU 1400 စစ်လိုပါက: `1400 - 28 = 1372`

### အဆင့် (၁) - MTU 1500 စမ်းသပ်ခြင်း
```bash
ping -c 2 -M do -s 1472 1.1.1.1
```
- **အကယ်၍ `0% packet loss` ဖြစ်ပါက:** သင့်ဆာဗာသည် Standard **MTU 1500** အပြည့် ရရှိပါသည်။
- **အကယ်၍ `message too long, mtu=1400` (သို့မဟုတ် 100% packet loss) ဖြစ်ပါက:** ဆာဗာသည် 1500 မရပါ၊ အောက်ပါ အဆင့် (၂) ကို ဆက်စမ်းပါ။

### အဆင့် (၂) - MTU 1400 စမ်းသပ်ခြင်း
```bash
ping -c 2 -M do -s 1372 1.1.1.1
```
- **အကယ်၍ `0% packet loss` ဖြင့် reply ပြန်လာပါက:** အဆိုပါဆာဗာအတွက် အသင့်တော်ဆုံးနှင့် အငြိမ်ဆုံး MTU သည် **`1400`** ဖြစ်ပါသည်။

---

## ⚙️ အပိုင်း (၃) - Cloud VPS ပေါ်တွင် MTU ကို အမြဲတမ်း (Permanently) ပြောင်းလဲသတ်မှတ်နည်း

### ၁။ အရေးပေါ် လက်တလော ပြောင်းလဲနည်း (Temporary Fix)
```bash
DEFAULT_IF=$(ip route show default | awk '{print $5}')
sudo ip link set dev $DEFAULT_IF mtu 1400
```

### ၂။ ဆာဗာ Reboot တက်တိုင်း အမြဲ အသက်ဝင်စေရန် ပြုလုပ်နည်း (Permanent Fix)

#### နည်းလမ်း (A) - Netplan ဖြင့် ပြင်ဆင်ခြင်း (Ubuntu 20.04, 22.04, 24.04 အတွက် အကောင်းဆုံး)
`/etc/netplan/` အောက်ရှိ `.yaml` ဖိုင် (ဥပမာ- `50-cloud-init.yaml`) ကို ဖွင့်ပါ:
```bash
sudo nano /etc/netplan/*.yaml
```
Interface အောက်တွင် `mtu: 1400` ထည့်သွင်းပါ:
```yaml
network:
    version: 2
    ethernets:
        eth0:   # သို့မဟုတ် သင့် network interface နာမည် (ens17/eth0)
            dhcp4: true
            mtu: 1400
```
သိမ်းဆည်းပြီး အသက်သွင်းပါ:
```bash
sudo netplan apply
```

#### နည်းလမ်း (B) - `/etc/rc.local` ဖြင့် အမြဲ အသက်သွင်းခြင်း (Universal Method)
```bash
DEFAULT_IF=$(ip route show default | awk '{print $5}')
sudo tee /etc/rc.local << EOF
#!/bin/bash
ip link set dev $DEFAULT_IF mtu 1400
exit 0
EOF
sudo chmod +x /etc/rc.local
```

---

## 🧮 အပိုင်း (၄) - VPN Protocol များအတွက် MTU တွက်ချက်မှု စံနှုန်းများ

ဆာဗာ၏ Host MTU ပေါ် မူတည်၍ VPN Client Configurations များတွင် အောက်ပါအတိုင်း MTU သတ်မှတ်ရပါမည်:

| Host VPS MTU | AmneziaWG 3.1 (AWG3) Client MTU | Standard WireGuard Client MTU | အကြံပြုချက် |
|---|---|---|---|
| **1500** (RackNerd, Hetzner, DO) | **`1280`** | `1420` | Default 1280 ဖြင့် Mobile Data ရော Wi-Fi ပါ အလွန်ငြိမ်သည်။ |
| **1400** (QQG.NET, VXLAN Nodes) | **`1200`** ~ **`1280`** | `1320` | Wi-Fi တွင် drop ဖြစ်ပါက Client config တွင် `MTU = 1200` ထားပါ။ |
| **PPPoE Fiber Wi-Fi** (Home Router) | **`1200`** | `1280` | Router ၏ MSS Clamping မမိပါက MTU ကို 1200 ထိ လျှော့ချပါ။ |

> 📌 **ရွှေစည်းမျဉ်း (Golden Rule):**
> AmneziaWG 3.1 တွင် **HeaderProtectionKey** နှင့် **ContentPaddingAddition (10-54 bytes)** ကဲ့သို့သော Obfuscation data များ ထပ်ပေါင်းထည့်ရသောကြောင့် WireGuard ထက် Packet ပိုကြီးပါသည်။ ထို့ကြောင့် AWG3 Client တွင် MTU ကို အများဆုံး **`1280`** ထက် ပိုမထားသင့်ဘဲ Wi-Fi မချိတ်ပါက **`1200`** အထိ လျှော့ချအသုံးပြုရပါမည်။

---

## 🛡️ အပိုင်း (၅) - TCP MSS Clamping ဖွင့်ထားခြင်း (မဖြစ်မနေ လုပ်ဆောင်ရမည့် ကာကွယ်မှု)

MTU မညီမျှမှုကြောင့် Packet များ လမ်းခုလတ်တွင် drop မသွားစေရန် Linux Kernel ၏ TCP MSS Clamping ကို ဆာဗာတိုင်းတွင် အမြဲ ဖွင့်ထားသင့်ပါသည်:

```bash
# TCP MSS Clamping ဖွင့်ခြင်း
sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Reboot တက်တိုင်း အလိုအလျောက် ပွင့်နေစေရန် iptables-persistent တွင် သိမ်းခြင်း
sudo apt install -y iptables-persistent
sudo netfilter-persistent save
```

---

## 📋 အပိုင်း (၆) - Cloud Providers များအလိုက် MTU သတိပြုရန်ဇယား

| Cloud Provider | ပုံမှန် MTU | သတိပြုရမည့် အချက် |
|---|---|---|
| **QQG.NET** | **1400** | MTU 1500 ထားပါက TLS Handshake timeout ဖြစ်ပြီး Docker pull မရပါ။ 1400 သို့ လျှော့ချပေးရမည်။ |
| **RackNerd** | **1500** | Standard 1500 ရရှိသည်။ Docker Restart လုပ်ပါက iptables NAT rule ပြန်စစ်ရမည်။ |
| **Hetzner Cloud** | **1500** | Standard 1500 ရရှိသည်။ Cloud Firewall တွင် UDP Port Allow ပေးရန် လိုသည်။ |
| **Oracle Cloud** | **1500** | Oracle Virtual Cloud Network (VCN) Inbound Security List တွင် UDP/TCP ဖွင့်ပေးရန် လိုသည်။ |
| **DigitalOcean** | **1500** | Standard 1500 ရရှိသည်။ အထူး MTU ပြင်ဆင်ရန် မလိုပါ။ |
| **AWS EC2** | **9001 / 1500** | VPC အချင်းချင်း 9001 ရသော်လည်း Internet Gateway သို့ 1500 သာ ရသည်။ |
