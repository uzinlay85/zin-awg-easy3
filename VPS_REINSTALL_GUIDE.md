# 🚀 VPS One-Click OS Reinstall Guide (Ubuntu 24.04 & Alpine Linux)

ဒီ Guide သည် `bin456789/reinstall` tool ကို အသုံးပြု၍ မည်သည့် KVM VPS (ဥပမာ - QQG.NET, DigitalOcean, Linode, Hetzner, AWS, GCP စသည်) တွင်မဆို **Ubuntu 24.04 LTS** သို့မဟုတ် Ultra-lightweight ဖြစ်သော **Alpine Linux** သို့ Clean Reinstall ပြုလုပ်ရန် ပြည့်စုံသော လမ်းညွှန်ချက်ဖြစ်ပါသည်။

---

## ⚠️ မပြုလုပ်မီ မဖြစ်မနေ သတိပြုရမည့် အချက်များ (Important Warnings)

> [!CAUTION]
> **Data အားလုံး အပြီးတိုင် ပျက်စီးမည် ဖြစ်သည်:**
> Reinstall စတင်ပြီး Reboot ချလိုက်ပါက VPS Hard Drive ပေါ်ရှိ လက်ရှိ Data, Website, Database, Docker containers နှင့် Configuration ဖိုင်များ အားလုံး အပြီးတိုင် ဖျက်ချခံရမည်ဖြစ်ပါသည်။ အရေးကြီးသည့် Data များရှိပါက **မိမိစက်တွင်းသို့ ကြိုတင် Backup ယူထားပါ**။

1. **Virtualization အမျိုးအစား စစ်ဆေးရန်:** KVM, Xen, Hyper-V သို့မဟုတ် Bare-metal ဆာဗာများတွင်သာ အလုပ်လုပ်ပါသည်။ (OpenVZ / LXC ကဲ့သို့သော Container-based VPS များတွင် **လုံးဝ အလုပ်မလုပ်ပါ**)
2. **RAM လိုအပ်ချက်:**
   - **Alpine Linux:** အနည်းဆုံး **256MB RAM** (RAM အလွန်နည်းသော VPS များအတွက် အသင့်တော်ဆုံး)
   - **Ubuntu 24.04:** အနည်းဆုံး **512MB RAM** (အကြံပြုချက်: 1GB RAM နှင့်အထက်)
3. **Password သတိပြုရန်:** အသုံးပြုမည့် Root Password အသစ်တွင် `#`, `$`, `"`, `'`, `\` စသည့် အထူးသင်္ကေတများ ထည့်ပါက Shell escape character ကြောင့် error မဖြစ်စေရန် ဂရုစိုက်ရွေးချယ်ပါ။

---

## 🔍 Virtualization အမျိုးအစား စစ်ဆေးနည်း (KVM ဟုတ်/မဟုတ် စစ်ဆေးခြင်း)

Reinstall မလုပ်မီ မိမိဆာဗာသည် KVM ဟုတ်မဟုတ်ကို အောက်ပါ command များဖြင့် တိကျစွာ စစ်ဆေးနိုင်ပါသည်-

### နည်းလမ်း (၁) - `systemd-detect-virt` ဖြင့် စစ်ဆေးခြင်း (အလွယ်ကူဆုံးနှင့် အတိကျဆုံး)
```bash
systemd-detect-virt
```
**ရလဒ် အဖြေများ:**
- `kvm` , `qemu` , `microsoft` (Hyper-V), `xen` သို့မဟုတ် `none` (Bare-metal Dedicated) ဟု ပြပါက **Reinstall လုပ်နိုင်ပါသည် (OK)**။
- `openvz` , `lxc` သို့မဟုတ် `docker` ဟု ပြပါက **Reinstall လုံးဝ မလုပ်သင့်ပါ (Server ပျက်သွားနိုင်ပါသည်)**။

---

### နည်းလမ်း (၂) - `hostnamectl` ဖြင့် စစ်ဆေးခြင်း
```bash
hostnamectl | grep -i "virtualization"
```
**နမူနာ ထွက်ရှိချက်:**
```text
Virtualization: kvm
```
*(KVM ပြနေပါက 100% စိတ်ချစွာ ဆက်လက်လုပ်ဆောင်နိုင်ပါသည်)*

---

### နည်းလမ်း (၃) - `lscpu` ဖြင့် စစ်ဆေးခြင်း
```bash
lscpu | grep -i "hypervisor"
```
**နမူနာ ထွက်ရှိချက်:**
```text
Hypervisor vendor:     KVM
Virtualization type:   full
```
*(Virtualization type တွင် **full** ဟု ပြပါက KVM ဖြစ်ပါသည်)*

---

### နည်းလမ်း (၄) - `virt-what` tool ဖြင့် စစ်ဆေးခြင်း
```bash
# Tool သွင်းခြင်း
sudo apt install -y virt-what || sudo apk add virt-what

# စစ်ဆေးခြင်း
sudo virt-what
```
Output တွင် `kvm` သို့မဟုတ် `qemu` ပေါ်လာပါက သုံးနိုင်ပါသည်။

---

## 🛠️ အဆင့် (၁) - VPS ပြင်ဆင်ခြင်းနှင့် Script ဒေါင်းယူခြင်း

VPS သို့ လက်ရှိ SSH ဖြင့် ဝင်ရောက်ပြီး root permission ယူပါ:

```bash
sudo -i
```

လိုအပ်သော tool များ (curl / wget) ရှိမရှိ စစ်ဆေးပြီး Reinstall Script ကို ဒေါင်းယူပါ:

```bash
# Ubuntu / Debian ဖြစ်ပါက
apt update -y && apt install -y curl wget ca-certificates

# Script ကို တရားဝင် GitHub မှ ဒေါင်းယူခြင်း
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
```

---

## 🐧 အဆင့် (၂) - OS ရွေးချယ်၍ Reinstall စတင်ခြင်း

သင်တင်လိုသော OS အမျိုးအစားအလိုက် အောက်ပါ command များထဲမှ တစ်ခုကို ရွေးချယ် run ပေးပါ:

### ရွေးချယ်မှု (A) - Ubuntu 24.04 LTS တင်လိုပါက

Default SSH Port (22) ဖြင့် တင်ခြင်း:
```bash
bash reinstall.sh ubuntu 24.04 --password "YourStrongPassword123"
```

စိတ်ကြိုက် SSH Port (ဥပမာ `2222`) ပြောင်းလဲပြီး တင်လိုပါက:
```bash
bash reinstall.sh ubuntu 24.04 --password "YourStrongPassword123" --ssh-port 2222
```

Cloud-kernel အစား Generic Kernel သွင်းလိုပါက:
```bash
bash reinstall.sh ubuntu 24.04 --password "YourStrongPassword123" --no-cloud-kernel
```

---

### ရွေးချယ်မှု (B) - Alpine Linux တင်လိုပါက (Ultra-Lightweight & High Performance)

> [!TIP]
> Alpine Linux သည် RAM 50MB အောက်သာ သုံးစွဲပြီး အလွန်ပေါ့ပါးမြန်ဆန်သောကြောင့် RAM နည်းသော VPS များ (256MB / 512MB / 1GB) အတွက် အထူးသင့်တော်ပါသည်။

Default SSH Port (22) ဖြင့် တင်ခြင်း:
```bash
bash reinstall.sh alpine --password "YourStrongPassword123"
```

စိတ်ကြိုက် SSH Port (ဥပမာ `2222`) ပြောင်းလဲပြီး တင်လိုပါက:
```bash
bash reinstall.sh alpine --password "YourStrongPassword123" --ssh-port 2222
```

---

## 🔄 အဆင့် (၃) - စနစ်ကို Reboot ချခြင်း

Script က Network configuration များနှင့် Boot image များကို RAM ထဲသို့ ဒေါင်းယူ configure လုပ်ပြီးပါက အောက်ပါ message ပေါ်လာပါမည်:
```text
System is ready to reboot...
```

ထိုအခါ VPS ကို Reboot ချပေးလိုက်ပါ:
```bash
reboot
```

> [!NOTE]
> Reboot ချလိုက်သည်နှင့် SSH Connection ပြတ်တောက်သွားပါမည်။
> - **Alpine Linux:** ၁ မိနစ်မှ ၂ မိနစ်ခန့်သာ ကြာမြင့်ပါသည်။
> - **Ubuntu 24.04:** ၃ မိနစ်မှ ၇ မိနစ်ခန့် (VPS Network speed ပေါ်မူတည်၍) ကြာမြင့်နိုင်ပါသည်။
> အဆိုပါအချိန်အတွင်း စိတ်ရှည်လက်ရှည် စောင့်ဆိုင်းပေးပါ။

---

## 🔑 အဆင့် (၄) - SSH ဝင်ရောက်ရာတွင် ပြောင်းလဲမည့် အချက်များနှင့် ဝင်ရောက်ခြင်း

OS အသစ်တက်လာပြီးနောက် SSH ဝင်ရောက်ရာတွင် အောက်ပါ အချက်များကို သတိပြုပါ-

### ၁။ Host Identification Changed Warning တက်လာပါက ဖြေရှင်းခြင်း:
OS အသစ်တင်လိုက်သဖြင့် SSH Server Fingerprint ပြောင်းလဲသွားသောကြောင့် သင့်စက်တွင် အောက်ပါ error ပြတတ်ပါသည်-
`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`
သင့်ကွန်ပျူတာ (Terminal) ပေါ်မှ Key အဟောင်းကို အောက်ပါ command ဖြင့် clear လုပ်ပေးပါ:
```bash
ssh-keygen -R <YOUR_VPS_IP>
```

### ၂။ SSH ဝင်ရောက်ခြင်း:
- **Username:** ယခင် user (ဥပမာ `zinko` စသည်) ပျက်သွားပြီး **`root`** တစ်ခုတည်းသာ ရှိပါမည်။
- **Password:** Script ထဲတွင် သင်ပေးခဲ့သော **Password အသစ်** ကိုသာ အသုံးပြုရပါမည်။

```bash
# Default Port 22 ဖြစ်ပါက
ssh root@<YOUR_VPS_IP>

# စိတ်ကြိုက် Port (ဥပမာ 2222) သတ်မှတ်ခဲ့ပါက
ssh -p 2222 root@<YOUR_VPS_IP>
```

---

## ⚙️ အဆင့် (၅) - OS အသစ် တင်ပြီးနောက် စစ်ဆေးခြင်းနှင့် အကြံပြုချက်များ

### ၁။ OS Version မှန်မမှန် စစ်ဆေးခြင်း:
```bash
cat /etc/os-release
uname -a
```

### ၂။ Disk Size အပြည့်ရမရ စစ်ဆေးခြင်း:
```bash
df -h
```
*(Script မှ Hard drive partition ကို အပြည့် auto expand လုပ်ပေးထားသည်ကို တွေ့ရပါမည်)*

### ၃။ Post-Install Update လုပ်ခြင်း:

* **Ubuntu 24.04 တွင်:**
  ```bash
  apt update && apt upgrade -y
  apt install -y curl wget git ufw htop
  ```

* **Alpine Linux တွင်:**
  ```bash
  apk update && apk upgrade
  apk add curl wget git bash htop nano
  ```

---

## 🆘 အရေးပေါ် Reset ပြုလုပ်နည်း (စိတ်ပြောင်းသွားပါက)

အကယ်၍ `bash reinstall.sh ...` ကို run ပြီးသော်လည်း `reboot` မချမီ Reinstall လုပ်ခြင်းကို ဖျက်သိမ်းပြီး မူလအတိုင်း ပြန်ထားလိုပါက အောက်ပါ command ကို ချက်ချင်း run နိုင်ပါသည်:

```bash
bash reinstall.sh reset
```

---

## 📋 Command အကျဉ်းချုပ် ဇယား (Quick Reference Cheat Sheet)

| အသုံးပြုလိုသော လုပ်ဆောင်ချက် | Command |
| :--- | :--- |
| **Virtualization စစ်ဆေးခြင်း** | `systemd-detect-virt` (kvm ပြပါက OK) |
| **Ubuntu 24.04 (Default Port 22)** | `bash reinstall.sh ubuntu 24.04 --password "YourPass"` |
| **Ubuntu 24.04 (Custom Port 2222)** | `bash reinstall.sh ubuntu 24.04 --password "YourPass" --ssh-port 2222` |
| **Alpine Linux (Default Port 22)** | `bash reinstall.sh alpine --password "YourPass"` |
| **Alpine Linux (Custom Port 2222)** | `bash reinstall.sh alpine --password "YourPass" --ssh-port 2222` |
| **Reboot စတင်ခြင်း** | `reboot` |
| **SSH Key အဟောင်းရှင်းခြင်း** | `ssh-keygen -R <YOUR_VPS_IP>` |
| **Reinstall ဖျက်သိမ်းခြင်း** | `bash reinstall.sh reset` |
