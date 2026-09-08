# AmneziaWG 3.1 Web UI (zin-awg-easy3)

ဒီ repository သည် လူကြိုက်များသော `wg-easy` ကို အခြေခံပြီး **AmneziaWG 3.1 (AWG3)** protocol အသစ်ကို အပြည့်အဝ ထောက်ပံ့ပေးနိုင်ရန် ပြုပြင်ဖန်တီးထားသော Web-based Management Panel ဖြစ်ပါသည်။

မူလ AWG-2 ထက် ပိုမိုခေတ်မီပြီး DPI ပိတ်ဆို့မှုများကို အကောင်းဆုံး ကျော်ဖြတ်နိုင်သော AmneziaWG 3.1 features များ ပါဝင်ပါသည်:
- **HeaderProtectionKey** (ChaCha20-Poly1305 header encryption)
- **ContentPaddingAddition** (ကျပန်း packet padding အတိုင်းအတာ `10-54`)
- **Randomized Timings** (`RekeyAfterTime = 103-136`, `RekeyTimeout = 4-6`, `RejectAfterTime = 170-200`, `KeepaliveTimeout = 9-13`, `MaxHandshakeAttempts = 17-20`)
- **RandomTrailers** (`on`)
- **DisableCookies** (`on`)
- **Custom Protocol Signature (CPS) & HTTP/QUIC Header Ranges** (`H1..H4`, `I1..I2`)

---

## ✨ ထူးခြားချက်များနှင့် စွမ်းဆောင်ရည်များ (Features)

1. **AWG2 နှင့် တစ်ဆာဗာတည်းတွင် အတူတွဲဖက် Run နိုင်ခြင်း (Coexistence):**
   - ယခင် Server ပေါ်တွင် AWG-2 (`amnezia-wg-easy`) သို့မဟုတ် Outline VPN ရှိနေစေကာမူ port နှင့် volume မငြိဘဲ AWG-3 (`amnezia-wg-easy3`) ကို ဘေးချင်းယှဉ်၍ လွတ်လပ်စွာ install ပြုလုပ်နိုင်ပါသည်။
2. **Auto Public IP & Independent Port Detection:**
   - Domain မရှိပါက ဆာဗာ၏ Public IP ကို အလိုအလျောက် ရှာဖွေပေးပါသည်။
   - Default Web UI Port: **`51833`** (TCP)
   - Default VPN Port: **`51820`** (UDP)
   - Default VPN Subnet: **`10.8.1.x`**
3. **Auto UFW Firewall Configuration:**
   - Script run လိုက်သည်နှင့် ရွေးချယ်ထားသော VPN UDP Port နှင့် Web UI TCP Port တို့ကို UFW Firewall တွင် အလိုအလျောက် `ufw allow` ပြုလုပ်ပေးပြီး `reload` လုပ်ပေးပါသည်။
4. **Interactive Admin Password Management:**
   - Setup စတင်ချိန်တွင် Password သတ်မှတ်နိုင်သည့်အပြင်၊ နောက်ပိုင်းတွင် Password အသစ်ပြောင်းလိုပါက `./start.sh password` ဖြင့် အချိန်မရွေး လွယ်ကူစွာ ပြောင်းလဲနိုင်ပါသည်။
5. **Universal Kernel / Userspace Compatibility:**
   - VPS Linux kernel ပေါ်တွင် AmneziaWG module မရှိသေးပါက userspace fallback (`amneziawg-go`) ဖြင့် error ကင်းစွာ auto-fallback အလုပ်လုပ်ပါသည်။
6. **QQG.NET Cloud & Multi-VPN (Outline, 3X-UI) Coexistence:**
   - QQG.NET node များတွင် MTU 1400 auto-optimize လုပ်ပေးခြင်းနှင့် Outline / 3X-UI များနှင့် တွဲဖက် run နည်း အသေးစိတ် ([QQG Setup Guide](QQG_NODE_SETUP_GUIDE.md) တွင် ကြည့်ရှုနိုင်ပါသည်)။
7. **Cloud Server MTU Diagnostics & Optimization:**
   - မည်သည့် Cloud VPS တွင်မဆို အကောင်းဆုံး MTU ရှာဖွေနည်းနှင့် ပုံသေ သတ်မှတ်နည်း လမ်းညွှန် ([Server MTU Diagnostic Guide](SERVER_MTU_DIAGNOSTIC_GUIDE.md) တွင် ကြည့်ရှုနိုင်ပါသည်)။
8. **BBR Blast Smooth TCP Optimization (High Speed 1G/2G Nodes):**
   - 2000Mbps အထိ Bandwidth အပြည့် ဆွဲသုံးနိုင်ရန် BBR နှင့် 64MB Buffer အသက်သွင်းနည်း ([BBR Optimization Guide](BBR_OPTIMIZATION_GUIDE.md) တွင် ကြည့်ရှုနိုင်ပါသည်)။
9. **Server Network Speedtest & Benchmark Guide:**
   - ဆာဗာ၏ Bandwidth အစစ်အမှန်ကို တရားဝင် Ookla CLI နှင့် YABS ဖြင့် တိကျစွာ တိုင်းတာစစ်ဆေးနည်း ([Server Speedtest Guide](SERVER_SPEEDTEST_GUIDE.md) တွင် ကြည့်ရှုနိုင်ပါသည်)။

---

## 🚀 VPS ပေါ်တွင် အစအဆုံး အလွယ်တကူ တပ်ဆင်နည်း (Quick Setup)

Ubuntu / Debian VPS ပေါ်တွင် Terminal ဖွင့်ပြီး အောက်ပါ command များကို အစဉ်လိုက် run ပေးရုံသာ ဖြစ်ပါသည်:

### အဆင့် (၁) - Docker နှင့် NAT Module သွင်းခြင်း

Docker မရှိသေးပါက အောက်ပါ command ဖြင့် Docker နှင့် NAT Module ကို ၁ မိနစ်အတွင်း အမြန်သွင်းနိုင်ပါသည်:

```bash
# NAT module ဖွင့်ခြင်း
sudo modprobe iptable_nat
echo "iptable_nat" | sudo tee /etc/modules-load.d/iptable_nat.conf

# Docker သွင်းခြင်းနှင့် service ဖွင့်ခြင်း
sudo apt update && sudo apt install -y docker.io git
sudo systemctl enable --now docker
```

### အဆင့် (၂) - Repository ကို Clone ခေါ်ပါ

```bash
cd /home/zinko   # သို့မဟုတ် မိမိအသုံးပြုလိုသော directory (ဥပမာ cd ~)
git clone https://github.com/uzinlay85/zin-awg-easy3.git
cd zin-awg-easy3
```

### အဆင့် (၃) - Docker Image ကို Build ပြုလုပ်ပါ

```bash
sudo docker build --no-cache --network host -t amnezia-wg-easy:3.1 .
```
*(ပထမဆုံးအကြိမ် compile လုပ်ချိန် ၃ မိနစ်ခန့် ကြာနိုင်ပါသည်)*

### အဆင့် (၄) - Automation Script ကို စတင် Run ပါ

```bash
chmod +x start.sh
./start.sh
```

---

## ⚙️ Setup Process မေးခွန်းများ

`./start.sh` ကို run လိုက်ပါက script သည် Server Public IP ကို အလိုအလျောက် ရှာဖွေပေးပြီး အောက်ပါအတိုင်း မေးမြန်းပါမည်-

```text
=== Configure Settings (Press Enter to use Default) ===
Enter your VPN Domain or Server IP [Default: <YOUR_SERVER_IP>]: 
Enter Web UI Port [Default: 51833]: 
Enter VPN UDP Port [Default: 51820]: 
Enter your VPN Admin Password [Default: admin123]: 
```

> [!TIP]
> သီးသန့် ပြောင်းလဲလိုခြင်း မရှိပါက **Enter** သာ ဆက်တိုက် ခေါက်သွားနိုင်ပါသည်။ Default တန်ဖိုးများကို အလိုအလျောက် သတ်မှတ်ပေးပါမည်။

---

## 🎉 အောင်မြင်စွာ တပ်ဆင်ပြီးစီးခြင်း (Success Output)

Setup ပြီးဆုံးသည်နှင့် Console တွင် အောက်ပါအတိုင်း ဖော်ပြပေးပါမည်-

```text
==================================================
🎉 AmneziaWG 3.1 (AWG3) is now running successfully!
==================================================
🌐 Web UI Panel : http://<YOUR_IP>:51833
🔑 Admin Pass   : admin123
🛡️  VPN Endpoint : <YOUR_IP>:51820 (UDP)
📁 Volume Path  : /home/zinko/.amnezia-wg-easy3
==================================================
```

မိမိ၏ Web Browser မှတစ်ဆင့် ဖော်ပြပါ **Web UI Panel Link** သို့ ဝင်ရောက်ပြီး Admin Password ဖြင့် Login ဝင်ကာ VPN Client Key များကို ဖန်တီးအသုံးပြုနိုင်ပါပြီ။

---

## 🔑 Web UI Password ပြန်လည်ပြောင်းလဲနည်း (Change Password)

Web UI Panel ၏ Admin Password ကို နောက်ပိုင်းတွင် ပြောင်းလဲလိုပါက အောက်ပါနည်းလမ်း (၂) မျိုးဖြင့် ပြုလုပ်နိုင်ပါသည်:

### နည်းလမ်း (၁) - Command တိုက်ရိုက် run ၍ ပြောင်းလဲခြင်း (အမြန်ဆုံး)

```bash
cd /home/zinko/zin-awg-easy3
./start.sh password
```
*(သို့မဟုတ် `./start.sh passwd` သို့မဟုတ် `./start.sh -p` ဟု ရိုက်ပါ)*  
စနစ်က Password အသစ်တောင်းပြီး Container ကို auto reload ချပေးပါမည်။

### နည်းလမ်း (၂) - Menu မှတစ်ဆင့် ရွေးချယ်ခြင်း

`./start.sh` ကို run လိုက်ပါက menu ဖော်ပြပေးပါမည်:
```text
Current setup detected with existing config.env.
1) Keep current settings and start
2) Change Web UI Admin Password
3) Reconfigure everything (Domain, Ports, Password)
Select option [Default: 1]: 2
```
နံပါတ် `2` ကို ရွေးချယ်ပြီး Password အသစ် ထည့်သွင်းနိုင်ပါသည်။

---

## 📱 AmneziaWG Client တွင် အသုံးပြုနည်း

1. မိမိဖုန်း (Android / iOS) သို့မဟုတ် Computer (Windows / macOS) တွင် **AmneziaWG** (သို့မဟုတ် **AmneziaVPN**) App ကို ဒေါင်းလုဒ်ရယူပါ။
2. Web UI (`http://<YOUR_IP>:51833`) သို့ ဝင်ပါ။
3. **+ New Client** နှိပ်ပြီး နာမည်တစ်ခု ပေးပါ။
4. ဖုန်းအတွက် **QR Code** scan ဖတ်ပါ (သို့မဟုတ် PC အတွက် **.conf** ဖိုင်ကို ဒေါင်းလုဒ်ဆွဲပြီး Import လုပ်ပါ)။
5. Connect နှိပ်၍ ချိတ်ဆက်အသုံးပြုနိုင်ပါပြီ။

---

## 🛡️ Firewall & Port Information

`start.sh` က UFW firewall ပေါက်များကို auto ဖွင့်ပေးထားပြီး ဖြစ်ပါသည်:
- **VPN UDP Traffic:** `51820/udp`
- **Web UI Management:** `51833/tcp`

*(အကယ်၍ AWS, Oracle, Google Cloud, QQG စသော Cloud Provider များ သုံးစွဲနေပါက Provider Dashboard ၏ Security Group / Inbound Rules တွင် အဆိုပါ port များကို ဖွင့်ပေးထားရန် လိုအပ်ပါသည်)*

---

## 🔄 စနစ်ကို Update ရယူနည်း (Update Guide)

GitHub မှ နောက်ဆုံး update များကို ရယူရန်:

```bash
cd /home/zinko/zin-awg-easy3
git pull
sudo docker build --no-cache --network host -t amnezia-wg-easy:3.1 .
./start.sh
```

---

## 🗑️ စနစ်ကို ပြန်လည်ဖျက်သိမ်းနည်း (Uninstall Guide)

AWG-3 container နှင့် data များကိုသာ သီးသန့်ဖျက်လိုပါက (AWG-2 ကို လုံးဝမထိခိုက်ပါ):

```bash
sudo docker stop amnezia-wg-easy3
sudo docker rm amnezia-wg-easy3
sudo docker rmi amnezia-wg-easy:3.1
sudo rm -rf ~/.amnezia-wg-easy3 /home/zinko/.amnezia-wg-easy3
sudo rm -f config.env
```


---

## 📊 ဆာဗာ၏ အင်တာနက် အဝင်အထွက် စစ်ဆေးခြင်း (Server Monitoring & Speed Test)

ဆာဗာ၏ ကွန်ရက်အမြန်နှုန်းနှင့် bandwidth ကို စောင့်ကြည့်လိုပါက:

```bash
# Speed Test စမ်းသပ်ရန်
sudo apt install speedtest-cli -y && speedtest-cli

# Real-time Traffic (Bandwidth) စောင့်ကြည့်ရန်
sudo apt install nload -y && nload
```



