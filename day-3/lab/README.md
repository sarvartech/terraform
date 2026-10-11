# Day 3: Proxmoxda Virtual Mashina Yaratish (Lab 03)

Ushbu amaliy laboratoriyada biz **Terraform** orqali **Proxmox VE** serverimizga ulanib, Cloud-Init andozasi asosida avtomatik ravishda yangi Linux Virtual Mashinasini (VM) ishga tushiramiz.

---

## 📋 1-Qadam: Proxmox Serverda Tayyorgarlik

Terraform Proxmox bilan ishlashi uchun bizga 2 ta narsa kerak:
1. **API Token** (Ulanish ruxsati uchun)
2. **Cloud-Init VM Template** (Klonlash uchun shablon)

---

### A) Proxmoxda API Token yaratish (GUI orqali):
1. Proxmox veb-interfeysiga kiring (`https://<PROXMOX_IP>:8006`).
2. Chap menyudan **Datacenter** -> **Permissions** -> **API Tokens** bo'limiga o'ting.
3. **Add** tugmasini bosing:
   - **User:** `root@pam` (yoki maxsus yaratilgan foydalanuvchi)
   - **Token ID:** `terraform-token`
   - **Privilege Separation:** Belgini olib tashlang *(unchecked qiling)*.
4. **Add** ni bosing. Ekranda **Token ID** va **Secret** chiqadi.
   > ⚠️ **DIQQAT:** `Secret` faqat bir marta ko'rsatiladi! Uni nusxalab xavfsiz joyga saqlab oling.

---

### B) Proxmoxda Cloud-Init Shablonini (Template) tayyorlash:
Agar sizda hali tayyor Cloud-Init shabloni bo'lmasa, Proxmox konsolida (Shell) quyidagi buyruqlarni bir marta bajaring:

```bash
# 1. Ubuntu 22.04 Cloud rasmini yuklab olish
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# 2. Yangi VM yaratish (ID: 9000)
qm create 9000 --name "ubuntu-2204-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

# 3. Diskni Proxmox storage'iga import qilish
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm

# 4. Diskni SCSI qilib ulash va Cloud-Init drayverini qo'shish
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1

# 5. Shablonga (Template) aylantirish
qm template 9000
```
*(Endi sizda `ubuntu-2204-cloudinit-template` nomli tayyor shablon mavjud!)*

---

## ⚙️ 2-Qadam: Terraform Sozlamalarini Kiritish

1. Terminalda `day-3/lab` papkasiga o'ting:
   ```bash
   cd day-3/lab
   ```

2. Namunaviy sozlamalar faylidan nusxa oling:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   *(Windows PowerShell'da: `Copy-Item terraform.tfvars.example terraform.tfvars`)*

3. [terraform.tfvars](file:///c:/Users/user/Documents/terraform/day-3/lab/terraform.tfvars) faylini oching va unga o'zingizning Proxmox serveringiz ma'lumotlarini kiriting:
   - `proxmox_api_url` — serveringiz IP manzili (masalan: `https://192.168.1.50:8006/api2/json`)
   - `proxmox_api_token_id` — `root@pam!terraform-token`
   - `proxmox_api_token_secret` — Proxmox bergan maxfiy kalit
   - `ssh_public_key` — kompyuteringizdagi ochiq SSH kalit (`cat ~/.ssh/id_rsa.pub`)

---

## 🚀 3-Qadam: Kodni Ishga Tushirish

### 1. Initsializatsiya (Proxmox provayderini yuklash):
```bash
terraform init
```

### 2. Rejani tekshirish:
```bash
terraform plan
```
Terraform Proxmoxda qanday parametrlar bilan VM yaratilishini ko'rsatadi.

### 3. Virtual mashinani yaratish:
```bash
terraform apply
```
Tasdiqlash so'ralganda `yes` deb yozing.  
Proxmox shablonni klonlashni boshlaydi va taxminan **30-60 soniya ichida** yangi virtual server to'liq tayyor bo'ladi! 🎉

---

## 🖥 4-Qadam: Natijani Tekshirish va Ulanish

1. Proxmox veb-paneliga kiring: siz bergan nomdagi (`devops-server-01`) yangi VM yoqilgan va ishlab turganini ko'rasiz.
2. Konsol orqali unga SSH bilan ulaning:
   ```bash
   ssh ubuntu@<VM_IP_MANZILI>
   ```
   *(Cloud-Init SSH kalitingizni o'rnatgani sababli, ulanish hech qanday parolsiz amalga oshadi).*

---

## 🧹 5-Qadam: Resursni Yo'q Qilish (Tozalash)

Tajriba tugagach, serverni 1 ta buyruq bilan o'chirib tashlashingiz mumkin:
```bash
terraform destroy
```
`yes` deb yozsangiz, Terraform Proxmoxdan ushbu VMni toza o'chirib tashlaydi.
