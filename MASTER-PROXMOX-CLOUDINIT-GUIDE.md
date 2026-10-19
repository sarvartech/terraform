# 🏆 Proxmox VE & Terraform: Cloud-Init Shablon Yaratish va VM Klasterini Boshqarish (Master Guide)

Ushbu amaliy qo'llanma Proxmox VE muhitida yangi virtual mashinadan (VM) mustaqil ravishda **Cloud-Init shablon (Template)** yaratish, uni production talablariga moslash va **Terraform** yordamida to'liq avtomatlashtirilgan tarzda yangi VMlarni (Statik IP, SSH kalit, foydalanuvchi bilan) deployment qilish bo'yicha **Master darajadagi qo'llanma** hisoblanadi.

---

## 📑 Mundarija

1. [Arxitektura va Ichki Mexanizm (Behind the Scenes)](#1-arxitektura-va-ichki-mexanizm)
2. [1-Usul: Professional Cloud Image (.img) orqali Template yaratish (Tavsiya etiladi)](#2-1-usul-rasmiy-cloud-image-img-orqali-template-yaratish)
3. [2-Usul: Oddiy ISO orqali o'rnatilgan VMni Templatega aylantirish (Master Checklist)](#3-2-usul-oddiy-iso-orqali-ornatilgan-vmni-templatega-aylantirish)
4. [Terraform Kodini Professional Darajada Loyihalash](#4-terraform-kodini-professional-darajada-loyihalash)
5. [Senior DevOps kabi Debugging va Muammolarni Hal Qilish](#5-senior-devops-kabi-debugging-va-muammolarni-hal-qilish)
6. [Mustaqil Amaliy Laboratoriya Topshiriqlari](#6-mustaqil-amaliy-laboratoriya-topshiriqlari)

---

## 🧠 1. Arxitektura va Ichki Mexanizm

Production darajasidagi DevOps muhandisi bo'lish uchun qaysi tugma yoki buyruq qanday ishlashini tizimli tushunish shart.

```
+-------------------------------------------------------------------------------+
|                             PROXMOX VE HOST                                   |
|                                                                               |
|   +-------------------+    API (/api2/json)      +------------------------+   |
|   | Terraform         | -----------------------> | Proxmox VE API         |   |
|   | (Telmate Provider)|                          | (pve-daemon / pvedaemon|   |
|   +-------------------+                          +------------------------+   |
|                                                              |                |
|                                                     Clone / Configure         |
|                                                              v                |
|   +-----------------------------------------------------------------------+   |
|   | VM (ID: 124 / ubuntu-static-vm)                                       |   |
|   |                                                                       |   |
|   |  +--------------------+         +----------------------------------+  |   |
|   |  | scsi0: 32G OS Disk |         | ide2: Cloud-Init Drive (ISO/CD)  |  |   |
|   |  | (Clone from        |         | Volume Label: CIDATA             |  |   |
|   |  |  Template)         |         | Files: user-data, meta-data      |  |   |
|   |  +--------------------+         +----------------------------------+  |   |
|   |             ^                                      |                  |   |
|   |             |           Early Boot                 |                  |   |
|   |             +--------------------------------------+                  |   |
|   |                 Cloud-Init reads NoCloud datasource                   |   |
|   |                 1. Creates user: ubuntu                               |   |
|   |                 2. Injects ~/.ssh/authorized_keys                     |   |
|   |                 3. Generates /etc/netplan/50-cloud-init.yaml (Static) |   |
|   |                 4. Starts qemu-guest-agent                            |   |
|   +-----------------------------------------------------------------------+   |
+-------------------------------------------------------------------------------+
```

### Proxmox Cloud-Init qanday ishlaydi?
1. Proxmoxda siz `ipconfig0`, `ciuser`, `sshkeys` parametrlarini berganda, Proxmox Linux diskini to'g'ridan-to'g'ri tahrirlamaydi.
2. Proxmox `local-lvm:vm-XXX-cloudinit` nomli kichik virtual CD-ROM drayverini (`ide2`) yaratadi. Uning ichida `user-data` (foydalanuvchi, SSH kalit) va `meta-data` (tarmoq, IP, Gateway) fayllari bo'ladi.
3. Yangi VM yoqilganda uning ichidagi `cloud-init` xizmati ushbu virtual diskni (`cidata`) topadi, o'qiydi va sozlamalarni Linux yadrosiga tatbiq etadi.
4. **Xulosa:** Agar VMda Cloud-Init drayveri (`ide2: local-lvm:cloudinit`) bo'lmasa yoki OS ichida Cloud-Init o'chirib qo'yilgan bo'lsa, Terraform orqali yuborilgan sozlamalar **umuman qo'llanmaydi**.

---

## ⚡ 2. 1-Usul: Rasmiy Cloud Image (.img) orqali Template yaratish

> [!TIP]
> **Production standarti:** Dunyodagi barcha yirik kompaniyalar (AWS, GCP, OpenStack, Proxmox) ISO o'rnatuvchisidan emas, balki rasmiy minimal Cloud tasvirdan foydalanadi. U 1-2 daqiqada tayyor bo'ladi va hech qanday ortiqcha dasturlarsiz sof Linux muhitini beradi.

Barcha buyruqlar **Proxmox Host Shell** konsolida bajariladi:

### 1-Qadam: Rasmiy tasvirni yuklab olish
```bash
cd /var/lib/vz/template/iso
wget -O ubuntu-2404-cloud.img https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

### 2-Qadam: VM karkasini yaratish (Masalan, ID: 9000)
```bash
qm create 9000 --name "ubuntu-2404-cloud-template" \
  --memory 2048 \
  --cores 2 \
  --cpu host \
  --net0 virtio,bridge=wan_br
```

### 3-Qadam: Diskni import qilish va SCSI kontrolleriga ulash
```bash
# Diskni local-lvm ga import qilish
qm importdisk 9000 ubuntu-2404-cloud.img local-lvm

# Diskni scsi0 ga biriktirish
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
```

### 4-Qadam: Cloud-Init drayveri va QEMU Agentni ulash
```bash
# Cloud-Init drayverini ide2 slotiga qo'shish
qm set 9000 --ide2 local-lvm:cloudinit

# Yuklanish diskini scsi0 qilib belgilash
qm set 9000 --boot c --bootdisk scsi0

# Proxmox veb interfeysi uchun seriyali konsolni yoqish
qm set 9000 --serial0 socket --vga serial0

# QEMU Guest Agentni yoqish
qm set 9000 --agent enabled=1
```

### 5-Qadam: Shablonga aylantirish
```bash
qm template 9000
```
> ✅ **Bo'ldi!** Ushbu shablon 100% toza, hech qanday qoldiq fayllarsiz Terraform bilan ishlashga tayyor.

---

## 🛠 3. 2-Usul: Oddiy ISO orqali o'rnatilgan VMni Templatega aylantirish

Agar siz ISO orqali Ubuntu o'rnatib, uning ichiga o'zingizning maxsus dasturlaringizni, docker, monitoring agentlarini o'rnatib keyin shablonga aylantirmoqchi bo'lsangiz, **quyidagi Master Checklist ga qat'iy amal qiling**. Aks holda siz bugun duch kelgan xato takrorlanadi!

### 🛑 Master Checklist (VM ichida bajariladigan amallar):

Ubuntu ISO orqali o'rnatilgach, VM ichiga kiring va quyidagilarni bajaring:

#### 1. Zaruriy paketlarni o'rnatish:
```bash
sudo apt update
sudo apt install -y cloud-init qemu-guest-agent
sudo systemctl enable qemu-guest-agent
```

#### 2. Ubuntu ISO blokirovkasini olib tashlash (ENG MUHIM QADAM):
```bash
sudo rm -f /etc/cloud/cloud-init.disabled
```

#### 3. Proxmox NoCloud ma'lumotlar manbasini belgilash:
```bash
echo "datasource_list: [ NoCloud, ConfigDrive ]" | sudo tee /etc/cloud/cloud.cfg.d/99-pve.cfg
```

#### 4. Qadimgi tarmoq keshini tozalash:
```bash
# Cloud-Init o'zi yangi statik IP yozishi uchun eski netplanni tozalash:
sudo rm -f /etc/netplan/00-installer-config.yaml
sudo rm -f /etc/netplan/50-cloud-init.yaml
```

#### 5. Machine-ID va Cloud-Init keshini tozalash:
> [!WARNING]
> Agar `machine-id` tozalanmasa, ushbu shablondan yaratilgan 10 ta VM ning barchasida bir xil ID bo'lib qoladi va DHCP/Tarmoq to'qnashuvi (IP conflict) yuzaga keladi!

```bash
sudo cloud-init clean --logs --machine-id
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
```

#### 6. VMni to'xtatish:
```bash
sudo poweroff
```

---

### 🖥 Proxmox Host konsoli va Veb GUI'da bajariladigan yakuniy amallar:

VM o'chgandan so'ng, Proxmox host konsolida (yoki Veb GUI Hardware bo'limida):

```bash
# 1. Eski ISO CD-ROM drayverini chiqarib tashlab, o'rniga Cloud-Init drayverini qo'yish:
qm set <VMID> --ide2 local-lvm:cloudinit

# 2. QEMU Guest Agentni gipervizor tomonida faollashtirish (CLI orqali):
qm set <VMID> --agent enabled=1

# 3. Yuklanish tartibida scsi0 birinchi bo'lishini ta'minlash:
qm set <VMID> --boot order=scsi0

# 4. Endi VMni rasmiy shablonga aylantirish:
qm template <VMID>
```

#### 📸 Proxmox GUI orqali QEMU Agentni yoqish:
Agar CLI o'rniga GUI'dan yoqmoqchi bo'lsangiz:
1. VM ni tanlang -> **Options** -> **QEMU Guest Agent** ustiga 2 marta bosing.
2. **"Use QEMU Guest Agent"** katagini belgilang va **OK** bosing.

![Edit Qemu Agent oynasi](./day-3/images/qemu-agent-modal-edit.png)
*(QEMU Agent tahrirlash oynasi)*

![QEMU Guest Agent Enabled ko'rinishi](./day-3/images/qemu-agent-options-enabled.png)
*(Options bo'limida Enabled holati)*

> 📖 **To'liq 0 dan 100% amaliy dars:** Ushbu usul bo'yicha qadamma-qadam skrinshotlar va batafsil ko'rsatmalar uchun qarang: **[Lab 03-C: Custom ISO'dan Template Yaratish](./day-3/lab/03-custom-iso-template.md)**.

---

## 💻 4. Terraform Kodini Professional Darajada Loyihalash

Siz mustaqil ravishda istalgan loyihada ishlatishingiz mumkin bo'lgan professional fayllar strukturasi:

### Strukturasi:
```text
my-proxmox-project/
├── provider.tf          # Proxmox provayderi
├── variables.tf         # Barcha o'zgaruvchilar
├── main.tf              # VM resursi
├── outputs.tf           # Chiqish parametrlari
└── terraform.tfvars     # Haqiqiy qiymatlar
```

### 1. `provider.tf`
```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
  pm_parallel         = 1
}
```

### 2. `variables.tf`
```hcl
variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type    = string
  default = "Winadmin"
}

variable "template_name" {
  type    = string
  default = "ubuntu-tmp-24.04"
}

variable "vm_name" {
  type    = string
  default = "production-srv-01"
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "vm_memory" {
  type    = number
  default = 2048
}

variable "vm_disk_size" {
  type    = string
  default = "32G"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "network_bridge" {
  type    = string
  default = "wan_br"
}

variable "vm_ip_cidr" { type = string }
variable "vm_gateway" { type = string }
variable "vm_nameserver" {
  type    = string
  default = "1.1.1.1 8.8.8.8"
}

variable "ci_user" {
  type    = string
  default = "ubuntu"
}

variable "ci_password" {
  type      = string
  default   = "Ubuntu123!"
  sensitive = true
}

variable "ssh_public_key" { type = string }
```

### 3. `main.tf`
```hcl
resource "proxmox_vm_qemu" "server" {
  name        = var.vm_name
  target_node = var.target_node
  desc        = "Terraform orqali boshqariladigan VM"

  # Shablon
  clone      = var.template_name
  full_clone = true

  # Resurslar
  os_type  = "cloud-init"
  cpu_type = "host"
  cores    = var.vm_cores
  sockets  = 1
  memory   = var.vm_memory
  scsihw   = "virtio-scsi-pci"
  boot     = "order=scsi0"
  onboot   = true

  # Agent
  agent         = 1
  agent_timeout = 90

  # Disklarni aniq belgilash (SCSI va Cloud-Init IDE)
  disks {
    scsi {
      scsi0 {
        disk {
          size      = var.vm_disk_size
          storage   = var.storage_pool
          replicate = false
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }
  }

  # Tarmoq
  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Cloud-Init Sozlamalari
  ipconfig0  = "ip=${var.vm_ip_cidr},gw=${var.vm_gateway}"
  nameserver = var.vm_nameserver
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.ssh_public_key

  # MAC manzil o'zgarishini e'tiborsiz qoldirish
  lifecycle {
    ignore_changes = [
      network[0].macaddr,
    ]
  }
}
```

### 4. `outputs.tf`
```hcl
output "vm_id" {
  value = proxmox_vm_qemu.server.id
}

output "vm_ip" {
  value = split("/", var.vm_ip_cidr)[0]
}

output "ssh_command" {
  value = "ssh ${var.ci_user}@${split("/", var.vm_ip_cidr)[0]}"
}
```

---

## 🕵️‍♂️ 5. Senior DevOps kabi Debugging va Muammolarni Hal Qilish

Agar kelajakda VM yaratsangiz-u, u tarmoqqa chiqmasa yoki SSH ishlamasa, quyidagi professional diagnostika bosqichlaridan foydalaning:

### 1-Tekshiruv: Proxmox Host konsolida QEMU Agent holati:
```bash
qm guest cmd <VMID> network-get-interfaces
```
- **Natija kutilishi:** Interfeys nomi (`eth0` yoki `ens18`) va uning IP manzili chiqishi kerak.
- **Agar `QEMU guest agent is not running` xatosi chiqsa:** VM ichida `qemu-guest-agent` o'rnatilmagan yoki VM hali to'liq yuklanmagan.

### 2-Tekshiruv: Proxmox Hostda Cloud-Init drayveri mavjudligini ko'rish:
```bash
qm config <VMID> | grep ide2
```
- **To'g'ri natija:** `ide2: local-lvm:vm-<VMID>-cloudinit,media=cdrom`
- **Noto'g'ri natija:** Agar bo'sh bo'lsa yoki eski `.iso` ko'rinsa, Cloud-Init drayveri qo'shilmagan!

### 3-Tekshiruv: VM ichiga kirib (Proxmox Veb Konsoli orqali) Cloud-Init loglarini tekshirish:
```bash
# Cloud-init holatini ko'rish:
cloud-init status --long

# Qayerda xatolik berganini to'liq ko'rish:
cat /var/log/cloud-init.log | grep -E "ERROR|CRITICAL"

# Tarmoq sozlamalarini ko'rish:
cat /etc/netplan/50-cloud-init.yaml
```

---

## 🎯 6. Mustaqil Amaliy Laboratoriya Topshiriqlari (Master Darajasi uchun)

O'z mahoratingizni to'liq mustahkamlash uchun quyidagi 3 ta bosqichni bajaring:

### 🟢 1-Mashq: Desktopdagi tayyor loyihani ishga tushirish
1. Terminalda `C:\Users\user\Desktop\terraform-proxmox-vm` papkasiga o'ting.
2. `terraform apply` qilib yangi `my-test-vm` (192.168.0.159) ni yarating.
3. `ssh ubuntu@192.168.0.159` orqali ulaning.
4. `terraform destroy` orqali o'chirib, tozalang.

### 🟡 2-Mashq: Proxmoxda noldan o'zingiz yangi Cloud Template yaratish (1-Usul)
1. Proxmox host konsoliga kiring (`ssh root@192.168.100.2`).
2. Yangi VMID bilan (masalan, `9001`) Canonical rasmiy `.img` tasviri orqali minimal shablon yarating (`qm create`, `qm importdisk`, `qm set --ide2 ...`).
3. `qm template 9001` qiling.
4. Desktopdagi `terraform.tfvars` faylidagi `template_name` ni yangi shablon nomiga o'zgartirib, Terraform bilan yangi VM yarating!

### 🔴 3-Mashq: Multi-Node klaster yaratish (Kengaytirilgan)
Terraform kodida `count = 3` yoki `for_each` qo'shib, bitta buyruq bilan birdaniga 3 ta virtual mashina (`node-01: 192.168.0.161`, `node-02: 192.168.0.162`, `node-03: 192.168.0.163`) yaratishni sinab ko'ring.
