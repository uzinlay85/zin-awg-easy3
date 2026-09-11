# Linux Network BBR Blast Smooth (Aggressive TCP Optimization) Guide

ဒီ Guide သည် **Asia-Pacific Cloud Nodes** (ဥပမာ- QQG.NET, Singapore, Tokyo, Hong Kong) နှင့် **Bandwidth မြင့်သော VPS များ (1Gbps ~ 2Gbps)** တွင် ကွန်ရက်အမြန်နှုန်း (Speed & Throughput) ကို အမြင့်ဆုံး ရရှိစေရန် Linux Kernel ၏ **BBR Congestion Control** နှင့် **TCP Buffer (64MB)** များကို အကောင်းဆုံး စီမံခန့်ခွဲ အသက်သွင်းနည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## 🚀 အမြန် တပ်ဆင်အသုံးပြုနည်း (Quick Setup Command)

VPS Terminal ထဲတွင် **`root`** အနေဖြင့် အောက်ပါ command ကို Copy-Paste တိုက်ရိုက် run နိုင်ပါသည်:

```bash
# ၁။ sysctl.conf ထဲသို့ BBR Blast Smooth Setting များ ထည့်သွင်းခြင်း
sudo tee -a /etc/sysctl.conf << 'EOF'

# === BBR Blast Smooth (Smooth Aggressive Version) ===
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Large buffer (64MB) - Sufficient to max out 1G/2G, without packet loss or stuttering
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864

# Short connection & latency optimization
net.ipv4.tcp_fin_timeout=8
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1

# Avoid saving historical RTT, maintain burst flexibility
net.ipv4.tcp_no_metrics_save=1
EOF

# ၂။ Setting များကို ချက်ချင်း အသက်သွင်းခြင်း
sudo sysctl -p
```

### စစ်ဆေးရန် Command:
```bash
sysctl net.ipv4.tcp_congestion_control
```
> `net.ipv4.tcp_congestion_control = bbr` ဟု ထွက်လာပါက အောင်မြင်စွာ အသက်ဝင်သွားပါပြီ။

---

## 📊 Parameters တစ်ခုချင်းစီ၏ အလုပ်လုပ်ပုံနှင့် ရှင်းလင်းချက်

| Parameter | သတ်မှတ်တန်ဖိုး | အလုပ်လုပ်ပုံ ရှင်းလင်းချက် |
|---|---|---|
| `net.core.default_qdisc` | `fq` | Fair Queueing packet scheduling ဖြစ်ပြီး BBR algorithm ကောင်းစွာ အလုပ်လုပ်ရန် မရှိမဖြစ် လိုအပ်သည်။ |
| `net.ipv4.tcp_congestion_control` | `bbr` | Google ၏ BBR algorithm ဖြစ်ပြီး Packet loss ဖြစ်ရုံဖြင့် speed ကျမသွားဘဲ အမြန်နှုန်းအပြည့် ပို့ဆောင်ပေးသည်။ |
| `net.core.rmem_max` / `wmem_max` | `67108864` (64MB) | Socket တစ်ခုချင်းစီအတွက် အများဆုံး သုံးနိုင်သော Receive/Send Buffer ပမာဏ ဖြစ်သည်။ (1Gbps/2Gbps အတွက် လုံလောက်သည်) |
| `net.ipv4.tcp_rmem` | `4096 87380 67108864` | Minimum (4KB), Default (87KB), Maximum (64MB) Read Buffer အတိုင်းအတာများ ဖြစ်သည်။ |
| `net.ipv4.tcp_wmem` | `4096 65536 67108864` | Minimum (4KB), Default (64KB), Maximum (64MB) Write Buffer အတိုင်းအတာများ ဖြစ်သည်။ |
| `net.ipv4.tcp_fin_timeout` | `8` | ပြီးဆုံးသွားသော Connection များကို ၆၀ စက္ကန့်အထိ စောင့်မနေစေဘဲ ၈ စက္ကန့်အတွင်း Memory ရှင်းထုတ်ပေးသည်။ |
| `net.ipv4.tcp_tw_reuse` | `1` | `TIME_WAIT` ဖြစ်နေသော Socket များကို Connection အသစ်များအတွက် ချက်ချင်း ပြန်လည်အသုံးပြုခွင့်ပေးသည်။ |
| `net.ipv4.tcp_window_scaling` | `1` | Window size ကို 64KB ထက်မက ကြီးမားစွာ ချဲ့ထွင်ခွင့်ပြုပြီး Bandwidth မြင့်မားစွာ သုံးစေနိုင်သည်။ |
| `net.ipv4.tcp_timestamps` | `1` | Packet RTT အချိန်ကို တိကျစွာ တွက်ချက်နိုင်ရန် timestamp ထည့်သွင်းသည်။ |
| `net.ipv4.tcp_sack` | `1` | Selective Acknowledgment (ပျောက်ဆုံးသွားသော packet များကိုသာ ပြန်ပို့စေပြီး အားလုံးပြန်မပို့ရအောင် သက်သာစေသည်)။ |
| `net.ipv4.tcp_no_metrics_save` | `1` | ယခင် နှေးကွေးခဲ့သော Cache metrics များကို မမှတ်ထားဘဲ ချိတ်ဆက်မှုတိုင်းကို burst speed အပြည့် စတင်စေသည်။ |

---

## 🎯 မည်သည့်ဆာဗာများတွင် သုံးသင့်သလဲ? (Hardware & Region Matrix)

### ✅ အသုံးပြုရန် အလွန်သင့်တော်သော ဆာဗာများ (Recommended):
- **ဆာဗာတည်နေရာ:** Asia-Pacific Nodes (Singapore, Hong Kong, Tokyo) - မြန်မာနိုင်ငံနှင့် Ping နည်းသော နေရာများ (Ping < 80ms)။
- **ဆာဗာ Hardware:** RAM **2GB နှင့် အထက်** ရှိသော VPS များ (ဥပမာ- QQG 2Core 2GB RAM 2000Mbps)။
- **ကွန်ရက် Bandwidth:** 500Mbps ~ 2000Mbps (2Gbps) ရှိသော မြန်နှုန်းမြင့်လိုင်းများ။
- **အကျိုးကျေးဇူး:** YouTube 4K/8K streaming ချောမွေ့ခြင်း၊ Download မြန်ဆန်ခြင်း၊ Buffer ပြည့်ပြီး လိုင်းထစ်ခြင်းမဖြစ်ပေါ်ခြင်း။

---

### ⚠️ သတိထားရမည့် ဆာဗာများနှင့် မသုံးသင့်သော အခြေအနေများ:
- **US West / Europe (High Latency Nodes):** 
  - မြန်မာနိုင်ငံနှင့် Ping 200ms+ ကွာဝေးသော အဝေးဆာဗာများတွင် 64MB buffer ထားပါက **Bufferbloat** (Packet များ Buffer ထဲတွင် တန်းစီစောင့်ဆိုင်းနေရသဖြင့် Latency ပိုဆိုးသွားခြင်း) ဖြစ်တတ်ပါသည်။
- **RAM 1GB အောက် (512MB ~ 768MB VPS):** 
  - Connection များပြားလာပါက RAM မလုံလောက်ဘဲ Linux OOM (Out of Memory) Killer ကြောင့် Service များ Crash ဖြစ်တတ်ပါသည်။

---

## 💡 RAM 1GB သို့မဟုတ် US Server များအတွက် Safe Tuning (Alternative)

အကယ်၍ သင့်ဆာဗာသည် **RAM 1GB သို့မဟုတ် US West** ဖြစ်နေပါက 64MB အစား **16MB Buffer** ကို သုံးရန် အကြံပြုပါသည်:

```ini
# Safe Version for 1GB RAM / US West VPS
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_no_metrics_save=1
```
