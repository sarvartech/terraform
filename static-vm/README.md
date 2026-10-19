# Proxmox Cloud-Init: Statik IP va SSH bilan Ubuntu VM Yaratish

Ushbu alohida loyiha Proxmox VE serverida **Ubuntu 24.04** shablonidan foydalanib, to'liq avtomatlashtirilgan **statik IP**, **SSH kalit** va **foydalanuvchi yaratish** jarayonini amalga oshiradi.

---

## 🔍 1. Nima uchun oldingi VMda SSH, User va Statik IP ishlamagan edi? (Muammoning Tub Sababi)

Siz Ubuntu 24.04 ni oddiy ISO (`ubuntu-24.04.3-live-server-amd64.iso`) orqali qo'lda o'rnatib shablon (template) qilgan edingiz. Ushbu holatda 3 ta jiddiy to'siq mavjud edi:

### ❌ 1-sabab: `/etc/cloud/cloud-init.disabled` fayli
Ubuntu Live Server o'rnatuvchisi (Subiquity) o'rnatish yakunlangach, tizim ichida quyidagi faylni hosil qiladi:
```text
/etc/cloud/cloud-init.disabled
```
Ushbu fayl ichida quyidagicha yozuv bor edi:
> *"Disabled by Ubuntu live installer after first boot. To re-enable cloud-init on this image run: sudo cloud-init clean --machine-id"*

Ubuntu har safar yuklanganda ushbu faylni ko'radi va **Cloud-Init xizmatini butunlay to'xtatadi**. Natijada Terraform orqali yuborilgan `ciuser`, `cipassword`, `sshkeys` va `ipconfig0` umuman o'qilmagan.

### ❌ 2-sabab: Proxmoxda Cloud-Init drayverining yo'qligi
Proxmox Cloud-Init sozlamalarini (IP, SSH kalit, user) virtual disk (CD-ROM) orqali VM ga uzatadi.
Sizning `ubuntu-tmp-24.04` (VMID: 122) shabloningizda `ide2` slotida hali ham eski Ubuntu ISO o'rnatish fayli turgan edi va **Cloud-Init Drive** (`local-lvm:cloudinit`) biriktirilmagan edi. Drayver bo'lmagani sababli Proxmox konfiguratsiya diskini yarata olmadi.

### ❌ 3-sabab: `qemu-guest-agent` o'rnatilmagan edi
Ubuntu Live Server ISO orqali o'rnatilganda `qemu-guest-agent` paketi sukut bo'yicha o'rnatilmaydi. Shu sababli Proxmox VM ning IP manzilini va uning ichki holatini ko'ra olmadi.

---

## 🛠 2. Biz shablonni (`ubuntu-tmp-24.04`) qanday to'g'riladik?

1. **Cloud-Init Drayveri qo'shildi:**
   ```bash
   qm set 122 --ide2 local-lvm:cloudinit
   qm set 122 --agent enabled=1
   ```
2. **Bloklovchi fayl olib tashlandi:**
   `/etc/cloud/cloud-init.disabled` fayli o'chirildi.
3. **Proxmox drayveri ko'rsatildi:**
   `/etc/cloud/cloud.cfg.d/99-pve.cfg` fayliga Proxmox manbalari qo'shildi:
   ```yaml
   datasource_list: [ NoCloud, ConfigDrive ]
   ```
4. **QEMU Agent o'rnatildi:**
   Ubuntu ichiga `qemu-guest-agent` o'rnatildi va faollashtirildi.
5. **Kesh va Machine-ID tozalandi:**
   ```bash
   cloud-init clean --logs --machine-id
   truncate -s 0 /etc/machine-id
   rm -f /etc/netplan/*
   ```

> 💡 **0 dan ISO orqali yangi toza shablon yaratish va QEMU Agentni GUI'da yoqish bo'yicha to'liq qo'llanma:**  
> Qarang: **[Lab 03-C: Custom ISO'dan Template Yaratish (0 dan)](../day-3/lab/03-custom-iso-template.md)**

---

## 📁 3. Loyiha Strukturasi (`static-vm/`)

```text
c:\Users\user\Documents\terraform\static-vm\
├── provider.tf          # Proxmox Telmate provayderi (API URL va Token)
├── variables.tf         # O'zgaruvchilar tavsifi va turlari
├── main.tf              # VM resursi (cores, ram, scsi0 disk, ide2 cloudinit, statik IP)
├── outputs.tf           # VM ID, Statik IP va SSH ulanish buyrug'i
├── terraform.tfvars     # Haqiqiy parametrlar (Token, IP: 192.168.0.158, SSH kalit)
└── README.md            # Ushbu hujjat
```

---

## ⚙️ 4. Asosiy Sozlamalar (`terraform.tfvars`)

```hcl
proxmox_api_url          = "https://192.168.100.2:8006/api2/json"
proxmox_api_token_id     = "terra-user@pam!terra-token"
proxmox_api_token_secret = "fe8b1c66-16d5-4a0c-a67a-bd32b1b28dfc"
proxmox_tls_insecure     = true

target_node   = "Winadmin"
template_name = "ubuntu-tmp-24.04"

vm_name      = "ubuntu-static-vm"
vm_cores     = 2
vm_memory    = 2048
vm_disk_size = "32G"
storage_pool = "local-lvm"

# Tarmoq (Statik IP va Gateway)
network_bridge = "wan_br"
vm_ip_cidr     = "192.168.0.158/24"
vm_gateway     = "192.168.0.1"
vm_nameserver  = "1.1.1.1 8.8.8.8"

# Foydalanuvchi va SSH
ci_user        = "ubuntu"
ci_password    = "Ubuntu123!"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... tmp-vm-uchun@gmail.com"
```

---

## 🚀 5. Virtual Mashinaga Ulanish

Terraform orqali **VMID 124** (`ubuntu-static-vm`) muvaffaqiyatli ishga tushirildi va sinovdan o'tkazildi:

Terminalda to'g'ridan-to'g'ri SSH kalitingiz bilan ulanishingiz mumkin:
```powershell
ssh ubuntu@192.168.0.158
```
*(Parol so'ralmaydi, chunki ochiq SSH kalitingiz Cloud-Init orqali avtomatik joylashtirildi).*

---

## 📌 6. Kelgusida ISO orqali Cloud-Init shablon yaratish qoidasi

Agar yana yangi Ubuntuni ISO orqali o'rnatib shablonga aylantirmoqchi bo'lsangiz, VM ni shablonga (Convert to template) aylantirishdan **OLDIN** VM ichida quyidagi buyruqlarni bering:

```bash
# 1. Zarur paketlarni o'rnatish
sudo apt update
sudo apt install -y cloud-init qemu-guest-agent
sudo systemctl enable qemu-guest-agent

# 2. Bloklovchi faylni o'chirish (Agar mavjud bo'lsa)
sudo rm -f /etc/cloud/cloud-init.disabled

# 3. Proxmox manbasini ko'rsatish
echo "datasource_list: [ NoCloud, ConfigDrive ]" | sudo tee /etc/cloud/cloud.cfg.d/99-pve.cfg

# 4. Netplan keshini tozalash (Cloud-init o'zi yangisini yozishi uchun)
sudo rm -f /etc/netplan/*

# 5. Tizim identifikatorlarini va loglarni tozalash
sudo cloud-init clean --logs --machine-id
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id

# 6. VM ni o'chirish
sudo poweroff
```

VM o'chgach, Proxmox konsolida:
```bash
# ISO diskni chiqarib, Cloud-Init drayverini ulash:
qm set <VMID> --ide2 local-lvm:cloudinit
qm set <VMID> --agent enabled=1

# Shablonga aylantirish:
qm template <VMID>
```
Shu tartibda tayyorlangan har qanday shablon Terraform bilan 100% muammosiz ishlaydi!
