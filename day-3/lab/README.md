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
Terraform VM yaratishdan oldin Proxmoxda tayanch shablon bo'lishi shart. Siz quyidagi 2 ta to'liq qo'llanmadan birini tanlab shablon yaratishingiz mumkin:

| Qo'llanma | Usul | VM ID | Xususiyati | Havola |
| :--- | :--- | :---: | :--- | :---: |
| **Lab 03-A** | **Minimal Rasmiy Tasvir** | `9000` | Sof Canonical Ubuntu 24.04 tasviri, qo'shimcha paketlarsiz | 📖 **[Lab 03-A Qo'llanmasi](./01-cloud-init-minimal-template.md)** |
| **Lab 03-B** | **Custom Template (`virt-customize`)** | `9100` | **Tavsiya etiladi!** `qemu-guest-agent`, `curl`, `htop` va Toshkent vaqti kiritilgan | 🚀 **[Lab 03-B Qo'llanmasi](./02-cloud-init-custom-template.md)** |

> [!TIP]
> Agar shoshilinch bo'lsa yoki eng barqaror natija kerak bo'lsa, **[Lab 03-B (Custom Template)](./02-cloud-init-custom-template.md)** orqali 9100-shablonni yaratishni tavsiya qilamiz. U orqali yaratilgan VMlar Terraform bilan 100% integratsiyada ishlaydi.


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
