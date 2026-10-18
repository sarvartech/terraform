# Day 3: Rasmiy Cloud Image orqali Minimal Template Yaratish (Lab 03-A)

Ushbu amaliy laboratoriya mashg'ulotida siz Proxmox VE serverida sof Canonical Ubuntu 24.04 LTS (Noble Numbat) tasviri asosida minimal Cloud-Init andozasini (Template) bosqichma-bosqich yaratasiz.

> [!NOTE]
> Barcha buyruqlar bevosita **Proxmox VE host konsolida** (yoki SSH orqali) `root` foydalanuvchisi sifatida bajariladi.

---

## 🛠 Dastlabki Talablar

- Ishlayotgan Proxmox VE 7.x yoki 8.x serveri;
- Serverga `root` foydalanuvchisi bilan SSH yoki Proxmox Veb GUI dagi Shell konsoli orqali kirish imkoniyati;
- Kamida 2 GB bo'sh operativ xotira (RAM) va 5 GB bo'sh disk maydoni.

---

## 0-bosqich: Dastlabki Tayyorgarlik va Tekshiruv

Virtual mashina yaratishdan oldin serverdagi xotira zaxiralari va tasvirlar saqlanadigan katalogni tayyorlab olamiz.

---

### 1-Qadam: Storage nomini aniqlash

```bash
pvesm status
```

#### ❓ Nega kerak?
Har bir Proxmox serverida disklarni saqlash uchun turli nomdagi xotira hovuzlari (masalan, `local-lvm`, `local-zfs`, `ceph` yoki `storage-pool`) bo'lishi mumkin. Agar mavjud bo'lmagan storage nomini ko'rsatsak, keyingi barcha buyruqlar xato beradi.

#### 📝 Tavsif va Parametrlar tahlili:
- `pvesm`: **Proxmox VE Storage Manager** — barcha xotira drayverlari va konfiguratsiyalarini boshqaruvchi asosiy utilita.
- `status`: Hozirda ulangan barcha storage'lar ro'yxatini, ularning turi (`dir`, `lvmthin`, `zfspool`) va ishchi holatini chiqaradi.

#### 🔍 Tekshirish va Kutilayotgan natija:
```text
Name         Type     Status           Total            Used       Available        %
local         dir     active        98497780        12480396        80983792   12.67%
local-lvm lvmthin     active       372867072        45120384       327746688   12.10%
```
`local-lvm` qatori ro'yxatda mavjud va uning `Status` ustunida `active` yozuvi bo'lishi shart. Agar sizda ZFS ishlatilsa, uning nomi `local-zfs` bo'ladi.

---

### 2-Qadam: Ishchi katalogga o'tish

```bash
cd /var/lib/vz/template/iso
```

#### ❓ Nega kerak?
Tasvir fayllarini (ISO va IMG) tasodifiy joylarga emas, balki Proxmoxning rasmiy andoza va tasvirlar uchun ajratilgan standart katalogiga yuklab olish kerak. Bu orqali fayllar tartibli saqlanadi va server xotirasi to'lib ketishining oldi olinadi.

#### 📝 Tavsif va Parametrlar tahlili:
- `cd`: *Change Directory* — joriy ishchi jildni ko'rsatilgan yo'lga o'zgartiradi.
- `/var/lib/vz/template/iso`: Proxmoxda `local` storage'ga biriktirilgan ISO va dastlabki disk fayllari turadigan xavfsiz tizimli jild.

#### 🔍 Tekshirish:
```bash
pwd
# Natija: /var/lib/vz/template/iso bo'lishi kerak
```

---

## 1-bosqich: Minimal Template Yaratish (VM ID: 9000)

Ushbu usul rasmiy Ubuntu tasviriga hech qanday tashqi o'zgartirish kiritmasdan, to'g'ridan-to'g'ri minimal shablonga aylantiradi.

---

### 1-Qadam: Rasmiy Ubuntu Cloud tasvirini yuklab olish

```bash
wget -O ubuntu-2404-cloud.img https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

#### ❓ Nega kerak?
Canonical kompaniyasi tomonidan maxsus bulutli muhitlar va KVM virtualizatsiyasi uchun optimallashtirilgan eng so'nggi barqaror Ubuntu 24.04 LTS (Noble Numbat) disk tasvirini olish uchun.

#### 📝 Tavsif va Parametrlar tahlili:
- `wget`: Internetdan fayllarni HTTP/HTTPS protokoli orqali yuklab oluvchi terminal vositasi.
- `-O ubuntu-2404-cloud.img`: Yuklanayotgan uzun nomli faylni qisqa va tushunarli `ubuntu-2404-cloud.img` nomi bilan saqlashni buyuradi.
- URL manzili: Canonical rasmiy serveridagi eng oxirgi (current) 64-bitli (amd64) server tasviriga to'g'ridan-to'g'ri havola.

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
ls -lh ubuntu-2404-cloud.img
```
Natijada yuklab olingan fayl hajmi taxminan **600–700 MB** atrofida ekanligini ko'rasiz:
```text
-rw-r--r-- 1 root root 680M Oct 14 10:00 ubuntu-2404-cloud.img
```

---

### 2-Qadam: Virtual Mashina (VM) karkasini yaratish (ID: 9000)

```bash
qm create 9000 --name "ubuntu-2404-base" \
  --memory 2048 \
  --cores 2 \
  --cpu host \
  --net0 virtio,bridge=vmbr0
```

#### ❓ Nega kerak?
Proxmoxda hali diski yo'q bo'lgan, ammo CPU, xotira va tarmoq parametrlariga ega bo'sh virtual mashina profilini (ID: 9000) ro'yxatdan o'tkazish uchun.

#### 📝 Tavsif va Parametrlar tahlili:
- `qm`: **QEMU/KVM Virtual Machine Manager** — Proxmoxda virtual mashinalarni boshqarishning asosiy CLI buyrug'i.
- `create 9000`: Virtual mashinaga noyob `9000` identifikator raqamini (VMID) beradi. Shablonlar uchun odatda 9000 dan yuqori IDlar tanlanadi, bu ularni oddiy foydalanuvchi VMlaridan ajratishni osonlashtiradi.
- `--name "ubuntu-2404-base"`: Proxmox interfeysida ko'rinadigan shablon nomi.
- `--memory 2048`: VM ga boshlang'ich 2048 MB (2 GB) operativ xotira ajratadi.
- `--cores 2`: 2 ta virtual protsessor yadrosi (vCPU).
- `--cpu host`: Serveringizdagi jismoniy protsessor ko'rsatmalari (flags) VM ichiga to'g'ridan-to'g'ri o'tishi uchun. Bu maksimal unumdorlik beradi.
- `--net0 virtio,bridge=vmbr0`: Birinchi virtual tarmoq kartasi (`net0`). Drayver turi: `virtio` (Linux uchun eng tezkor), Tarmoq ko'prigi: `vmbr0` (standart LAN tarmog'i).

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
qm status 9000
```
Chiqadigan natija:
```text
status: stopped
```

---

### 3-Qadam: Diskni import qilish va tizimga ulash

Diskni Proxmox saqlagichiga ko'chiramiz va uni SCSI drayveri orqali VM ga ulaymiz:

```bash
# 1. Disk faylini LVM saqlagichiga import qilish
qm importdisk 9000 ubuntu-2404-cloud.img local-lvm

# 2. Diskni VM ga biriktirish
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
```

#### ❓ Nega kerak?
Yuklab olingan `.img` fayli oddiy fayl holatida turibdi. Proxmox uni to'g'ridan-to'g'ri ishlata olmaydi. `qm importdisk` buyrug'i uni Proxmoxning `local-lvm` blok saqlagichiga rasmiy virtual disk (`vm-9000-disk-0`) qilib o'tkazadi. `qm set` esa ushbu diskni VM apparatiga biriktiradi.

#### 📝 Tavsif va Parametrlar tahlili:
- `qm importdisk 9000 <fayl> local-lvm`: Tasvirni 9000-raqamli VM uchun `local-lvm` storage'iga mos qilib qayta yozadi.
- `qm set 9000`: 9000-raqamli VM apparat sozlamalariga o'zgartirish kiritadi.
- `--scsihw virtio-scsi-pci`: SCSI boshqaruv kontrolleri turi. `virtio-scsi-pci` KVM muhitidagi eng barqaror va yuqori tezlikdagi kontroller hisoblanadi.
- `--scsi0 local-lvm:vm-9000-disk-0`: Import qilingan yangi diskni birinchi SCSI slotiga (`scsi0`) asosiy operatsion tizim diski qilib ulaydi.

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
qm config 9000 | grep scsi0
```
Natijada disk ulanganini ko'rasiz:
```text
scsi0: local-lvm:vm-9000-disk-0,size=...
```

---

### 4-Qadam: Cloud-Init drayverini qo'shish

```bash
qm set 9000 --ide2 local-lvm:cloudinit
```

#### ❓ Nega kerak?
Cloud-Init tizimi VM ishga tushayotganda tarmoq sozlamalari (IP, Gateway, DNS), foydalanuvchi nomi va SSH kalitlarni o'qishi uchun maxsus virtual drayver kerak. Proxmox bu ma'lumotlarni virtual CD-ROM orqali uzatadi.

#### 📝 Tavsif va Parametrlar tahlili:
- `--ide2`: Virtual CD-ROM drayverini ikkinchi IDE slotiga (`ide2`) ulaydi. (IDE tanlanishining sababi — BIOS/UEFI uni darhol CD-ROM deb taniydi).
- `local-lvm:cloudinit`: Proxmoxga ushbu drayver Cloud-Init konfiguratsiyasini saqlovchi maxsus generatsiya qilinadigan virtual disk ekanligini bildiradi.

#### 🔍 Tekshirish:
```bash
qm config 9000 | grep ide2
```
Kutilayotgan natija:
```text
ide2: local-lvm:vm-9000-cloudinit,media=cdrom
```

---

### 5-Qadam: Yuklanish (boot) va boshqaruv parametrlarini sozlash

```bash
# 1. Asosiy yuklanish qurilmasi qilib scsi0 diskini tanlash
qm set 9000 --boot c --bootdisk scsi0

# 2. Seriyali konsol ulanishini yoqish
qm set 9000 --serial0 socket --vga serial0

# 3. QEMU Guest Agent aloqasini yoqish
qm set 9000 --agent enabled=1
```

#### ❓ Nega kerak?
1. **Boot parametri:** VM yoqilganda diskni qidirmasdan darhol operatsion tizim joylashgan `scsi0` diskidan yuklanishi uchun.
2. **Serial konsol:** Cloud tasvirlarda grafik desktop bo'lmagani sababli, Proxmox veb-panelida qulay xterm.js matnli konsoli ishlashi uchun.
3. **QEMU Agent:** Gipervizor VM ichki holatini, xususan uning IP manzilini bilishi uchun aloqa soketini ochish uchun.

#### 📝 Tavsif va Parametrlar tahlili:
- `--boot c`: Birinchi bo'lib qattiq diskdan yuklanish buyrug'i.
- `--bootdisk scsi0`: Aynan qaysi diskdan tizim ochilishini aniq ko'rsatadi.
- `--serial0 socket`: Tizimga virtual soket ko'rinishidagi seriyali port (`ttyS0`) qo'shadi.
- `--vga serial0`: Grafik adapter sifatida seriyali konsoldan foydalanishni belgilaydi.
- `--agent enabled=1`: Gipervizor tomondan QEMU Guest Agent soketini faollashtiradi.

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
qm config 9000 | grep -E "agent|bootdisk|serial0"
```
Kutilayotgan natija:
```text
agent: 1
boot: order=scsi0
bootdisk: scsi0
serial0: socket
vga: serial0
```

---

### 6-Qadam: Cloud-Init foydalanuvchi, parol, SSH kalit va tarmoq parametrlarini sozlash

```bash
# 1. Cloud-Init foydalanuvchi nomi va parolini belgilash
qm set 9000 --ciuser "sarvar"
qm set 9000 --cipassword "Sizning_Parolingiz"

# 2. Custom SSH Public Key ni qo'shish (Fayl yo'lini ko'rsatasiz yoki to'g'ridan-to'g'ri matnni yozasiz)
qm set 9000 --sshkeys /root/.ssh/id_rsa.pub

# 3. Tarmoqni sozlash (Masalan: DHCP)
qm set 9000 --ipconfig0 ip=dhcp
```

#### ❓ Nega kerak?
1. **Foydalanuvchi va parol (`--ciuser`, `--cipassword`):** Rasmiy Ubuntu Cloud tasvirlarida sukut bo'yicha hech qanday parol o'rnatilmagan bo'ladi (parolli kirish qulflangan). Agar foydalanuvchi va parol oldindan kiritilmasa, VM ishga tushganda uning konsoliga yoki SSH tarmog'iga login/parol bilan kirib bo'lmaydi.
2. **SSH kalit (`--sshkeys`):** Serverga parolsiz, yuqori xavfsizlik darajasida va tezkor ulanish uchun o'zingizning ochiq SSH kalitingizni (`id_rsa.pub`) Cloud-Init orqali tizimga oldindan joylashtirish imkonini beradi.
3. **Tarmoq konfiguratsiyasi (`--ipconfig0`):** Virtual mashina birinchi marta yoqilishi bilanoq lokal tarmoqdagi DHCP serverdan avtomatik ravishda IP manzil olishini ta'minlaydi.

#### 📝 Tavsif va Parametrlar tahlili:
- `--ciuser "sarvar"`: Cloud-Init orqali yaratiladigan standart foydalanuvchi logini (masalan, `sarvar` yoki `ubuntu`).
- `--cipassword "Sizning_Parolingiz"`: Ushbu foydalanuvchi uchun o'rnatiladigan maxfiy parol. Proxmox uni avtomatik xeshlab Cloud-Init konfiguratsiyasiga xavfsiz yozadi.
- `--sshkeys /root/.ssh/id_rsa.pub`: Ko'rsatilgan fayldagi SSH ochiq kalitini yangi VM ichidagi foydalanuvchining `~/.ssh/authorized_keys` fayliga yuklaydi. (Fayl yo'li o'rniga to'g'ridan-to'g'ri kalit matnini ham kiritish mumkin).
- `--ipconfig0 ip=dhcp`: Birinchi virtual tarmoq interfeysi (`net0`) uchun IP manzil taqsimotini DHCP orqali avtomatik olish rejimiga sozlaydi. (Agar statik IP kerak bo'lsa, masalan `ip=192.168.1.50/24,gw=192.168.1.1` ko'rinishida beriladi).

> [!TIP]
> Agar Proxmox xostingizda hali SSH kalit yaratilmagan bo'lsa, uni quyidagi buyruq bilan bir necha soniyada hosil qilishingiz mumkin:
> ```bash
> ssh-keygen -t rsa -b 4096 -N "" -f /root/.ssh/id_rsa
> ```

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
qm config 9000 | grep -E "ciuser|cipassword|sshkeys|ipconfig0"
```
Kutilayotgan natija:
```text
cipassword: ...
ciuser: sarvar
ipconfig0: ip=dhcp
sshkeys: ssh-rsa%20AAAAB3Nza... (yoki kalitingiz)
```

---

### 7-Qadam: Template (Shablon) holatiga o'tkazish

```bash
qm template 9000
```

#### ❓ Nega kerak?
Oddiy virtual mashinani tasodifan yoqib yuborish yoki uning ichki fayllarini buzib qo'yish mumkin. `qm template` buyrug'i VM ni o'zgarmas (Read-Only) shablonga aylantiradi. Endi uni to'g'ridan-to'g'ri ishga tushirib bo'lmaydi, faqat undan yangi VMlar klonlanadi.

#### 📝 Tavsif va Parametrlar tahlili:
- `qm template 9000`: 9000 identifikatorli VM konfiguratsiyasini shablon rejimiga o'tkazadi va uning disklarini o'zgarmas qilib belgilaydi.

#### 🔍 Tekshirish va Kutilayotgan natija:
```bash
qm list
```
Natijada `9000` ID raqami yonida uning shablon ekanligini ko'rasiz:
```text
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
      9000 ubuntu-2404-base     stopped    2048               2.20 0
```
Proxmox Veb GUI da ushbu VM belgisi oddiy kompyuter belgisidan **qog'oz va varaq (template)** belgisiga o'zgaradi!

---

## 🚀 Keyingi Qadam

Siz birinchi minimal shabloningizni muvaffaqiyatli tayyorladingiz!  
Endi ishlab chiqarish muhiti uchun barcha utilitalar (`qemu-guest-agent`, `htop`, `curl`) oldindan o'rnatilgan takomillashgan shablon yaratish uchun **[2-Laboratoriya: virt-customize orqali Custom Template](./02-cloud-init-custom-template.md)** qo'llanmasiga o'ting!
