# 📚 မြန်မာဘာသာ လမ်းညွှန်များနှင့် လက်စွဲမှတ်တမ်းများ (Burmese Guides Directory)

ဤလမ်းညွှန်ဖိုဒါသည် **zin-awg-easy3** ပရောဂျက်နှင့် VPS စီမံခန့်ခွဲမှု၊ Network တည်ဆောက်မှု၊ အကောင်းဆုံး Performance ချိန်ညှိမှုနှင့် ပြဿနာဖြေရှင်းနည်းများအတွက် ရေးသားထားသော မြန်မာဘာသာ လမ်းညွှန်ဖိုင်များအားလုံးကို တစ်စုတစ်စည်းတည်း စုစည်းထားသော **မာတိကာ အညွှန်း (Table of Contents)** ဖြစ်ပါသည်။

---

## 📑 မာတိကာ အညွှန်း (Table of Contents)

| စဉ် | လမ်းညွှန်ဖိုင်အမည် | အဓိက အကြောင်းအရာနှင့် ရည်ရွယ်ချက် | အကျဉ်းချုပ် |
| :---: | :--- | :--- | :--- |
| **၁** | [QQG_NODE_SETUP_GUIDE.md](./QQG_NODE_SETUP_GUIDE.md) | **QQG.NET VPS ပေါ်တွင် AmneziaWG 3.1 တပ်ဆင်ခြင်း** | QQG Node သစ်တွင် Docker, AmneziaWG 3.1 သွင်းခြင်း၊ Port 51833/51820 ဖွင့်ခြင်းနှင့် TLS Handshake Error ဖြေရှင်းခြင်း |
| **၂** | [VPS_REINSTALL_GUIDE.md](./VPS_REINSTALL_GUIDE.md) | **One-Click VPS OS Reinstall (Ubuntu 24.04 / Alpine)** | KVM စစ်ဆေးနည်း၊ `bin456789/reinstall` ဖြင့် Clean Reinstall တင်ခြင်း၊ SSH Key ရှင်းနည်းနှင့် လက်တွေ့ စစ်ဆေးချက်မှတ်တမ်း |
| **၃** | [BBR_OPTIMIZATION_GUIDE.md](./BBR_OPTIMIZATION_GUIDE.md) | **BBR Blast Smooth Network & Buffer Optimization** | BBR v1/v2/v3 ဖွင့်ခြင်း၊ 64MB TCP Buffer ချိန်ညှိခြင်း၊ Asia-Pacific နှင့် US West စစ်ဆေးချက်၊ Packet Loss ကာကွယ်ခြင်း |
| **၄** | [SERVER_MTU_DIAGNOSTIC_GUIDE.md](./SERVER_MTU_DIAGNOSTIC_GUIDE.md) | **MTU 1400 Diagnostic & Packet Drop Fix** | Packet Loss ဖြစ်ခြင်း၊ TLS Handshake Timeout တက်ခြင်းကို MTU 1400 ဖြင့် အမြဲတမ်း ဖြေရှင်းနည်း (systemd-networkd / netplan) |
| **၅** | [SERVER_SPEEDTEST_GUIDE.md](./SERVER_SPEEDTEST_GUIDE.md) | **ဆာဗာ Bandwidth & Speedtest စစ်ဆေးခြင်း** | Ookla Speedtest တရားဝင် Tool သွင်းနည်း၊ Asia / US Multi-server စစ်ဆေးခြင်းနှင့် Speed Result ခွဲခြမ်းစိတ်ဖြာခြင်း |
| **၆** | [OUTLINE_COEXIST_GUIDE.md](./OUTLINE_COEXIST_GUIDE.md) | **AmneziaWG နှင့် Outline VPN ပူးတွဲ Run ခြင်း** | Port မငြိစေဘဲ Outline Shadowbox နှင့် AmneziaWG 3.1 တို့ကို ဆာဗာတစ်ခုတည်းတွင် အတူတကွ တွဲဖက် run နည်း |
| **၇** | [3XUI_COEXIST_GUIDE.md](./3XUI_COEXIST_GUIDE.md) | **AmneziaWG နှင့် 3X-UI ပူးတွဲ Run ခြင်း** | 3X-UI (VLESS/Reality) နှင့် AmneziaWG ပူးတွဲလည်ပတ်ပုံ၊ Port Routing နှင့် NAT Firewall ချိန်ညှိနည်းများ |

---

## 🔍 လမ်းညွှန်တစ်ခုချင်းစီ၏ ပါဝင်ချက် အကျဉ်းချုပ်များ

### ၁။ [QQG_NODE_SETUP_GUIDE.md](./QQG_NODE_SETUP_GUIDE.md) (QQG Node Setup)
- **ရည်ရွယ်ချက်:** QQG.NET ဆာဗာအသစ်တွင် zin-awg-easy3 စနစ်သစ်ကို အပြည့်အစုံ deploy လုပ်နိုင်ရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - Docker & Docker Compose တရားဝင် install လုပ်နည်း
  - Project clone ယူပြီး `start.sh` ဖြင့် အလိုအလျောက် config ချနည်း
  - Web UI Panel (`51833/tcp`) နှင့် VPN Endpoint (`51820/udp`) အမှီအခိုကင်းစွာ port ခွဲထားပုံ
  - QQG Node များတွင် ကြုံရတတ်သော `TLS handshake timeout` ပြဿနာ အမြစ်ပြတ်ရှင်းနည်း

### ၂။ [VPS_REINSTALL_GUIDE.md](./VPS_REINSTALL_GUIDE.md) (VPS OS Reinstall)
- **ရည်ရွယ်ချက်:** VPS Provider တွေပေးထားတဲ့ Bloatware ပါသော OS အစား Clean Ubuntu 24.04 LTS သို့မဟုတ် Alpine Linux တင်ရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - VPS သည် KVM ဟုတ်မဟုတ် စစ်ဆေးနည်း (၄) မျိုး (`systemd-detect-virt`, `lscpu`, `hostnamectl`, `virt-what`)
  - `bin456789/reinstall` သုံး၍ Password, SSH Port စိတ်ကြိုက်ပေးပြီး တင်နည်း
  - Reboot ချပြီးနောက် Host Key Verification error (`ssh-keygen -R`) ရှင်းနည်း
  - QQG.NET VPS ပေါ်တွင် Ubuntu 24.04 တင်ပြီးနောက် ရရှိခဲ့သော Resource & Storage အောင်မြင်မှု မှတ်တမ်း

### ၃။ [BBR_OPTIMIZATION_GUIDE.md](./BBR_OPTIMIZATION_GUIDE.md) (BBR TCP Tuning)
- **ရည်ရွယ်ချက်:** VPN အင်တာနက် အမြန်နှုန်း အဆမတန် တက်လာစေရန်နှင့် Packet Loss လျှော့ချရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - Google BBR Congestion Control နှင့် FQ (Fair Queueing) ဖွင့်နည်း
  - 64MB TCP Window Buffer (`tcp_rmem`, `tcp_wmem`, `rmem_max`, `wmem_max`) ထည့်သွင်းပုံ
  - Asia-Pacific VPS (Ping နည်းသောနေရာ) တွင် အကျိုးသက်ရောက်မှုနှင့် US West (High latency, Low RAM) သတိပြုရန်အချက်များ
  - Systemd / Sysctl ပေါ်တွင် အမြဲတမ်း အသက်ဝင်စေရန် ထည့်သွင်းနည်း

### ၄။ [SERVER_MTU_DIAGNOSTIC_GUIDE.md](./SERVER_MTU_DIAGNOSTIC_GUIDE.md) (MTU Troubleshooting)
- **ရည်ရွယ်ချက်:** ဆာဗာတွင် Docker pull မရခြင်း၊ Curl ချိတ်မရခြင်း၊ TLS Handshake ရပ်နေခြင်းများကို ဖြေရှင်းရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - MTU ဆိုသည်မှာ အဘယ်နည်းနှင့် Cloud Provider များ၏ Tunneling ကန့်သတ်ချက်များ
  - Ping Sweep (`ping -M do -s <size>`) ဖြင့် အကောင်းဆုံး MTU ရှာဖွေနည်း
  - MTU 1400 သို့ ယာယီနှင့် အပြီးတိုင် (Netplan / Systemd) ပြောင်းလဲနည်း

### ၅။ [SERVER_SPEEDTEST_GUIDE.md](./SERVER_SPEEDTEST_GUIDE.md) (Speedtest Guide)
- **ရည်ရွယ်ချက်:** VPS ၏ အင်တာနက် Upload / Download Speed အစစ်အမှန်ကို တိုင်းတာရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - Ookla Speedtest တရားဝင် CLI Tool သွင်းယူနည်း
  - Local, Asia (Singapore/Tokyo) နှင့် US ဆာဗာများသို့ ရွေးချယ် စစ်ဆေးနည်း
  - 2Gbps Uplink နှင့် Virtual Card Speed အကြောင်း ရှင်းလင်းချက်

### ၆။ [OUTLINE_COEXIST_GUIDE.md](./OUTLINE_COEXIST_GUIDE.md) (Outline Coexistence)
- **ရည်ရွယ်ချက်:** ဆာဗာတစ်ခုတည်းတွင် AmneziaWG ရော Outline VPN (Shadowsocks) ရော တစ်ပြိုင်နက် သုံးနိုင်ရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - Outline Shadowbox Docker Container တပ်ဆင်ပုံ
  - Port 衝突 မဖြစ်စေရန် Port Setting ခွဲခြားပုံ
  - Client Access Key ထုတ်ယူနည်းနှင့် Firewall ချိန်ညှိနည်း

### ၇။ [3XUI_COEXIST_GUIDE.md](./3XUI_COEXIST_GUIDE.md) (3X-UI Coexistence)
- **ရည်ရွယ်ချက်:** AmneziaWG နှင့် 3X-UI (Xray) တို့ကို VPS တစ်ခုတည်းတွင် အတူ run ရန်။
- **အဓိက ပါဝင်ချက်များ:**
  - 3X-UI တပ်ဆင်ပုံနှင့် Web Panel Port ချိန်ညှိခြင်း
  - VLESS / Reality / Trojan Protocol များနှင့် AmneziaWG Port ခွဲဝေမှု
  - IP Forwarding နှင့် NAT Routing စနစ်များ မငြိစေရန် စီမံပုံ

---
💡 *အကြံပြုချက်: လမ်းညွှန်တစ်ခုခုကို ဖတ်ရှုလိုပါက အထက်ပါ ဇယားထဲရှိ Link များကို တိုက်ရိုက်နှိပ်၍ ကြည့်ရှုနိုင်ပါသည်။*
