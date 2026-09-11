# Linux Server Network Speedtest & Benchmark Guide

ဒီ Guide သည် **VPS Server များ (QQG.NET, RackNerd, Hetzner, DO, AWS စသည်)** တွင် Provider များ ကြော်ငြာထားသော **Bandwidth (1Gbps ~ 2Gbps)** အမှန်တကယ် ရရှိခြင်း ရှိ/မရှိ တရားဝင် **Ookla Speedtest CLI** နှင့် **YABS (Yet Another Bench Script)** တို့ကို အသုံးပြု၍ တိကျစွာ တိုင်းတာစစ်ဆေးနည်း အပြည့်အစုံ ဖြစ်ပါသည်။

---

## ⚠️ Python speedtest-cli အဟောင်းနှင့် တရားဝင် Ookla CLI ကွာခြားချက်

- **Python `speedtest-cli` (အဟောင်း):** Single-connection သာ သုံးနိုင်သဖြင့် 1Gbps ကျော်သော အမြန်နှုန်းများကို တိုင်းတာနိုင်စွမ်းမရှိဘဲ 100Mbps ~ 200Mbps ဝန်းကျင်သာ ပြသတတ်ပြီး Upload တွင် 0.00Mbps error တက်တတ်သည်။
- **Official Ookla `speedtest` (အသစ် - အကြံပြုထားသော နည်းလမ်း):** C++ ဖြင့် ရေးသားထားပြီး Multi-Connection (Multi-Stream) စနစ် ပါဝင်သောကြောင့် 1Gbps / 2Gbps / 10Gbps အထိ အမှန်တကယ် စီးဆင်းနိုင်သော Bandwidth ကို အတိအကျ တိုင်းတာပေးနိုင်သည်။

---

## 🚀 နည်းလမ်း (၁) - တရားဝင် Ookla Speedtest CLI သွင်းပြီး စစ်ဆေးနည်း (Official Method)

### အဆင့် (၁) - Python အဟောင်းရှိပါက ရှင်းထုတ်ပြီး Ookla Repository ထည့်ခြင်း
```bash
# speedtest အဟောင်းများ ရှိပါက ရှင်းလင်းခြင်း
sudo apt remove -y speedtest-cli 2>/dev/null || true
sudo rm -f /usr/bin/speedtest /usr/local/bin/speedtest-cli

# Ookla တရားဝင် repository ထည့်သွင်းခြင်း
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

# Ookla speedtest ကို သွင်းယူခြင်း
sudo apt install -y speedtest
```

### အဆင့် (၂) - Speedtest စတင် စစ်ဆေးခြင်း
```bash
speedtest --accept-license --accept-gdpr
```

### စိတ်ကြိုက် Server ရွေးချယ်ပြီး စမ်းသပ်လိုပါက (ဥပမာ- စင်ကာပူ သို့မဟုတ် ဂျပန်):
```bash
# ၁။ အနီးအနားရှိ Server List များကို ရှာဖွေခြင်း
speedtest -L

# ၂။ နှစ်သက်ရာ Server ID ဖြင့် စမ်းသပ်ခြင်း (ဥပမာ ID: 13623)
speedtest -s 13623
```

---

## 🌍 နည်းလမ်း (၂) - ကမ္ဘာအနှံ့ Speedtest စစ်ဆေးခြင်း (YABS Benchmark)

အမေရိက၊ ဥရောပနှင့် အာရှဆာဗာများဆီသို့ တစ်ပြိုင်နက် Speed စမ်းသပ်လိုပါက VPS အသိုင်းအဝိုင်းတွင် အသုံးအများဆုံး benchmark ဖြစ်သော **YABS** ကို အသုံးပြုနိုင်ပါသည်:

```bash
# Network Speed တစ်ခုတည်းကိုသာ ချက်ချင်း စစ်ဆေးရန် (-r ထည့်ပါ)
curl -sL yabs.sh | bash -s -- -r
```

---

## 📊 ရလဒ်များအား ခွဲခြမ်းစိတ်ဖြာခြင်း (Result Interpretation)

### ဥပမာ စမ်းသပ်တွေ့ရှိချက် (QQG.NET VPS):
```text
   Speedtest by Ookla
      Server: Fastnet Data
Idle Latency:    36.07 ms
    Download:   835.15 Mbps (1.3 GB used)
      Upload:   783.62 Mbps (984.1 MB used)
 Packet Loss:     0.0%
```

### သုံးသပ်ချက်များ:
1. **Download 800+ Mbps / Upload 700+ Mbps ရရှိခြင်း:**
   - Single-node စမ်းသပ်မှုတွင် 800+ Mbps ရရှိနေခြင်းသည် Server Port အား **1Gbps ~ 2Gbps Shared Port** အပြည့်အဝ ဖွင့်ပေးထားခြင်း ဖြစ်သည်။
   - VPN Clients များစွာ (Multi-Connections) တစ်ပြိုင်နက် ချိတ်ဆက်သုံးစွဲချိန်တွင် 2000Mbps အပြည့် စီးဆင်းနိုင်မည် ဖြစ်သည်။
2. **Packet Loss 0.0% ဖြစ်ခြင်း:**
   - Network Routing အလွန်သန့်ရှင်းပြီး Packet Drop မရှိကြောင်း အတည်ပြုနိုင်သည်။
3. **BBR နှင့် Buffer ကြီးမားခြင်း၏ အကျိုး:**
   - Linux sysctl တွင် BBR နှင့် 64MB buffer ဖွင့်ထားမှသာ ဤကဲ့သို့ 800+ Mbps အထိ latency နည်းပါးစွာဖြင့် တက်လှမ်းနိုင်ခြင်း ဖြစ်သည်။

---

## 🛠️ အဖြစ်များသော ပြဿနာများနှင့် ဖြေရှင်းနည်းများ (Troubleshooting)

### ၁။ `trying to overwrite '/usr/bin/speedtest', which is also in package speedtest-cli`
- **အကြောင်းရင်း:** Ubuntu တွင် Python speedtest-cli သွင်းထားပြီးဖြစ်၍ Ookla နှင့် ဖိုင်နာမည် တိုက်ဆိုင်နေခြင်း။
- **ဖြေရှင်းနည်း:**
  ```bash
  sudo apt remove -y speedtest-cli
  sudo apt install -y --fix-broken
  sudo apt install -y speedtest
  ```

### ၂။ `Hosted by ... [8000+ km]: Latency ကြီးပြီး Speed နှေးနေခြင်း`
- **အကြောင်းရင်း:** IP Geolocation မတိကျ၍ ကမ္ဘာတစ်ဖက်ခြမ်း အမေရိကဆာဗာသို့ အလိုအလျောက် သွားရောက် စမ်းသပ်မိခြင်း။
- **ဖြေရှင်းနည်း:** `speedtest -L` ဖြင့် အနီးစပ်ဆုံး Singapore / Tokyo server ID ကို ရွေးချယ်ပြီး `speedtest -s <ID>` ဖြင့် စမ်းသပ်ပါ။
