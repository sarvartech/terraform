# Day 3: virt-customize orqali Custom Template Yaratish (Lab 03-B - Tavsiya etiladi)

Ushbu amaliy laboratoriyada biz **`virt-customize`** utilitasi yordamida Ubuntu 24.04 tasvirini virtual mashinani ishga tushirmasdan turib (offline) o'zgartiramiz: uning ichiga `qemu-guest-agent`, kerakli DevOps utilitalarini (`curl`, `htop`, `net-tools`) o'rnatamiz, vaqt mintaqasini **`Asia/Tashkent`** ga moslaymiz va Terraform uchun 100% tayyor bo'lgan **Custom Template (ID: 9100)** yaratamiz.

> [!TIP]
> Bu usul real kompaniyalarda va ishlab chiqarish (Production) infratuzilmasida eng ko'p qo'llaniladigan standart hisoblanadi.

---

## 🛠 Dastlabki Talablar

- Proxmox VE serveriga `root` foydalanuvchisi sifatida kirish;
- [Lab 03-A](./01-cloud-init-minimal-template.md) bosqichida yuklab olingan `ubuntu-2404-cloud.img` faylining mavjudligi;
- Proxmox serverining internetga chiqish imkoniyati (paketlarni yuklab olish uchun).

---

## 🚀 Bosqichma-bosqich Amaliy Jarayon

---

### 1-Qadam: Kerakli utilitani o'rnatish (`libguestfs-tools`)

```bash
apt update && apt install -y libguestfs-tools
```

#### ❓ Nega kerak?
Proxmoxning standart o'rnatilishida disk tasvirlarini (raw, qcow2) tizimni yoqmasdan tahrirlash utilitasi bo'lmaydi. `libguestfs-tools` to'plami bizga `virt-customize` vositasini beradi.

#### 📝 Tavsif va Parametrlar tahlili:
- `apt update`: Proxmox Debian paketlar ombori indeksini yangilaydi.
- `apt install -y libguestfs-tools`: Virtual disklar bilan offline rejimda ishlash uchun zarur bo'lgan Red Hat kutubxonasini (`virt-customize`, `virt-edit`, `guestfish`) hech qanday tasdiqlash so'rovisiz (`-y`) to'liq o'rnatadi.

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
virt-customize --version
```
Natijada utilita versiyasi (masalan, `virt-customize 1.48.x` yoki 1.50.x) xatosiz chiqishi shart.

---

### 2-Qadam: Tasvirdan nusxa olish va ichki konfiguratsiyani kiritish

```bash
# 1. Ishchi katalogga o'tish
cd /var/lib/vz/template/iso

# 2. Toza tasvirdan custom nusxa olish
cp ubuntu-2404-cloud.img ubuntu-2404-custom.img

# 3. Disk ichiga kerakli dastur va sozlamalarni kiritish
virt-customize -a ubuntu-2404-custom.img \
  --install qemu-guest-agent,curl,wget,htop,net-tools,sudo \
  --timezone "Asia/Tashkent" \
  --run-command "systemctl enable qemu-guest-agent" \
  --run-command "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config" \
  --update
```

#### ❓ Nega kerak?
1. `cp`: Original `ubuntu-2404-cloud.img` faylini buzmasdan, xavfsiz tajriba o'tkazish uchun yangi nusxa tayyorlash.
2. `virt-customize`: VMni yoqib o'tirmasdan, bir daqiqa ichida diskka barcha paketlarni o'rnatish, vaqtni Toshkentga sozlash, SSH kirishini ruxsat berish va agentni tizim xizmatiga qo'shish uchun.

#### 📝 Tavsif va Parametrlar tahlili:
- `-a ubuntu-2404-custom.img`: Tahrirlanadigan maqsadli disk faylini ko'rsatadi (*Add disk*).
- `--install qemu-guest-agent,curl,wget,htop,net-tools,sudo`:
  - `qemu-guest-agent`: Proxmox va Terraform VM ning IP manzilini bilishi uchun eng zarur agent;
  - `curl, wget`: Skriptlar va konfiguratsiyalarni yuklab olish qurollari;
  - `htop`: Server yuklamasini vizual nazorat qilish utilitasi;
  - `net-tools`: `ifconfig`, `netstat` va boshqa tarmoq diagnostika buyruqlari to'plami;
  - `sudo`: Foydalanuvchilarga ma'muriy huquqlarni berish vositasi.
- `--timezone "Asia/Tashkent"`: Tizim vaqtini O'zbekiston standart vaqtiga (`UTC+5`) o'tkazadi. Barcha loglar va audit to'g'ri vaqt bilan yoziladi.
- `--run-command "systemctl enable qemu-guest-agent"`: VM har gal yoqilganda QEMU agenti avtomatik fonda ishga tushishini sozlaydi.
- `--run-command "sed -i ..."`: SSH konfiguratsiyasida root orqali ulanish cheklovini olib tashlaydi.
- `--update`: Tizimdagi mavjud dasturiy ta'minotni eng so'nggi xavfsizlik yangilanishlariga ko'taradi (`apt-get upgrade`).

#### 🔍 Tekshirish va Kutilayotgan natija:
Buyruq bajarilishi davomida terminalda paketlar o'rnatilishi ko'rinadi va jarayon yakunida:
```text
[ OK ] Finishing off
```
yozuvi paydo bo'lishi shart!

---

### 3-Qadam: Custom tasvir uchun alohida VM yaratish (ID: 9100)

```bash
qm create 9100 --name "ubuntu-2404-custom-template" \
  --memory 2048 \
  --cores 2 \
  --cpu host \
  --net0 virtio,bridge=vmbr0
```

#### ❓ Nega kerak?
Minimal tasvirdan (9000) alohida ajralib turishi va chalkashlik bo'lmasligi uchun yangi `9100` ID raqami bilan yangi shablon karkasini ochamiz.

#### 📝 Tavsif va Parametrlar tahlili:
- `qm create 9100`: Yangi virtual mashinaga `9100` VMID raqamini beradi.
- `--name "ubuntu-2404-custom-template"`: Proxmox interfeysida ushbu shablon custom ekanligini aniq ko'rsatuvchi nom.
- `--memory 2048`: 2048 MB operativ xotira ajratadi.
- `--cores 2`: 2 ta protsessor yadrosi.
- `--cpu host`: Protsessorning barcha zamonaviy ko'rsatmalarini to'g'ridan-to'g'ri uzatadi.
- `--net0 virtio,bridge=vmbr0`: Tezkor `virtio` drayverli tarmoq kartasi.

#### 🔍 Tekshirish:
```bash
qm status 9100
# Natija: status: stopped
```

---

### 4-Qadam: Custom diskni import qilish va sozlash

```bash
# 1. Tayyorlangan custom diskni import qilish
qm importdisk 9100 ubuntu-2404-custom.img local-lvm

# 2. Diskni SCSI qilib ulash
qm set 9100 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9100-disk-0

# 3. Cloud-Init drayverini qo'shish
qm set 9100 --ide2 local-lvm:cloudinit
```

#### ❓ Nega kerak?
Ichiga barcha paketlar o'rnatilgan `ubuntu-2404-custom.img` diskini Proxmoxning `local-lvm` saqlagichiga ko'chirib, uni 9100-VMga asosiy tizim diski (`scsi0`) va Cloud-Init CD-ROM (`ide2`) sifatida ulash uchun.

#### 📝 Tavsif va Parametrlar tahlili:
- `qm importdisk 9100 ...`: Custom diskni Proxmox LVM-Thin tizimiga kiritadi.
- `--scsihw virtio-scsi-pci`: SCSI kontroller turini o'rnatadi.
- `--scsi0 local-lvm:vm-9100-disk-0`: Diskni birinchi SCSI slotiga biriktiradi.
- `--ide2 local-lvm:cloudinit`: Cloud-Init ma'lumotlarini (IP, kalitlar) qabul qiluvchi drayverni qo'shadi.

#### 🔍 Tekshirish:
```bash
qm config 9100 | grep -E "scsi0|ide2"
```
Kutilayotgan natija:
```text
ide2: local-lvm:vm-9100-cloudinit,media=cdrom
scsi0: local-lvm:vm-9100-disk-0,size=...
```

---

### 5-Qadam: Tizim sozlamalari va Template-ga aylantirish

```bash
# 1. Asosiy yuklanish qurilmasi
qm set 9100 --boot c --bootdisk scsi0

# 2. Seriyali konsol
qm set 9100 --serial0 socket --vga serial0

# 3. QEMU Guest Agent aloqasini yoqish
qm set 9100 --agent enabled=1

# 4. Shablonga aylantirish
qm template 9100
```

#### ❓ Nega kerak?
VM to'g'ri diskdan yuklanishi, veb-konsol ishga tushishi, QEMU agent orqali Proxmox bilan ma'lumot almashishi va nihoyat shablon holatiga keltirilib, o'zgarishlardan himoyalanishi uchun.

#### 📝 Tavsif va Parametrlar tahlili:
- `--boot c --bootdisk scsi0`: Tizim yuklanganda birinchi bo'lib `scsi0` diskini o'qiydi.
- `--serial0 socket --vga serial0`: Proxmox xterm.js konsoli uchun seriyali portni ulaydi.
- `--agent enabled=1`: Gipervizorga VM ichidagi `qemu-guest-agent` bilan aloqa qilishga ruxsat beradi.
- `qm template 9100`: VMni o'zgarmas (Read-Only) shablonga aylantiradi.

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
qm list
```
Natijada `9100` ID raqami ham ro'yxatda template sifatida paydo bo'ladi:
```text
      VMID NAME                         STATUS     MEM(MB)    BOOTDISK(GB) PID
      9000 ubuntu-2404-base             stopped    2048               2.20 0
      9100 ubuntu-2404-custom-template  stopped    2048               2.50 0
```

---

## 📊 Yakuniy Tekshiruv Jadvali

| VM ID | Nomi | Maqsadi | Xususiyati |
| :---: | :--- | :--- | :--- |
| **9000** | `ubuntu-2404-base` | Sof rasmiy template | Minimal, qo‘shimcha paketlarsiz, tezkor yuklab olingan |
| **9100** | `ubuntu-2404-custom-template` | **Tayyorlangan ishchi template** | QEMU Guest Agent, htop, curl, sudo va Toshkent vaqti oldindan kiritilgan |

---

## 🎯 Ushbu Custom Template'ni Terraformda Ishlatish

Endi `day-3/lab/terraform.tfvars` yoki `day-3/create-vm/terraform.tfvars` faylingizda quyidagi o'zgaruvchini belgilashingiz kifoya:

```hcl
template_name = "ubuntu-2404-custom-template"
```

Terraform ushbu `ubuntu-2404-custom-template` shablonidan yangi virtual mashinani **15-20 soniya ichida** to'liq tayyor qilib beradi:
- VM darhol Proxmoxda o'z IP manzilini ko'rsatadi;
- Serverga SSH orqali kirganingizda Toshkent vaqti va barcha qulay vositalar (`htop`, `curl`) allaqachon tayyor bo'ladi! 🎉
