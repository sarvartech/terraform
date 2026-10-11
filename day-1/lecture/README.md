# Day 1: Terraformga Kirish & IaC Asoslari (Lecture)

Ushbu ma'ruza Terraform haqidagi eng asosiy va ko'p beriladigan savollarga aniq, tushunarli va professional javoblarni o'z ichiga oladi.

---

### ❓ 1. Terraform nima?
> **Javob:**  
> **Terraform** — bu infratuzilmani kod ko'rinishida boshqarish imkonini beruvchi **IaC (Infrastructure as Code)** vositasi.  
> Oddiy qilib aytganda: serverlar, tarmoqlar, ma'lumotlar bazalari, xavfsizlik qoidalari va boshqa IT-resurslarni qo'lda sichqoncha bilan bosib yaratish o'rniga, ularni matnli fayllarda (kodda) yozib, avtomatik ravishda yaratish, yangilash va o'chirish imkonini beruvchi quroldir.  
> Terraform **deklarativ (declarative)** yondashuvdan foydalanadi: siz tizimga "qanday qilish kerak" (imperative) emas, balki **"yakuniy natija qanday bo'lishi kerak"**ligini aytasiz, qolganini Terraformning o'zi hal qiladi.

---

### ❓ 2. Kim tomonidan yaratilgan?
> **Javob:**  
> Terraform **HashiCorp** kompaniyasi (asoschilari: *Mitchell Hashimoto* va *Armon Dadgar*) tomonidan **2014-yilda** yaratilgan.  
> HashiCorp shuningdek Vagrant, Packer, Consul, Nomad va Vault kabi mashhur DevOps vositalarining muallifi hisoblanadi.  
> *(Eslatma: 2024-yilda HashiCorp kompaniyasi IBM tomonidan sotib olindi).*

---

### ❓ 3. Terraform nima muammoni hal qiladi?
> **Javob:**  
> Terraform an'anaviy IT va Cloud boshqaruvidagi bir qator jiddiy muammolarni bartaraf etadi:
> 1. **"ClickOps" (qo'lda konsoldan bosish):** Cloud konsolida (AWS/Azure/GCP) yuzlab tugmalarni bosib adashish, biror sozlamani unutib qoldirish xavfini yo'qotadi.
> 2. **Inson omili (Human error):** Bir xil muhitni (Dev, Staging, Production) qo'lda yaratganda doim tafovutlar yuzaga keladi. Terraform barchasini 100% bir xil qilib klonlash imkonini beradi.
> 3. **Konfiguratsiya siljishi (Configuration Drift):** Kimdir serverga yashirincha kirib nimadir o'zgartirsa, Terraform buni darhol aniqlaydi va asl holiga qaytara oladi.
> 4. **Hujjatlashtirish va Versiyalash muammosi:** Infratuzilma kod ko'rinishida Git'ga yuklanadi. Kim, qachon, nima o'zgartirganini `git log` orqali ko'rish mumkin.
> 5. **Tezlik va Xarajat:** Serverlar kerak bo'lganda bir necha daqiqada yaratiladi, kerak bo'lmaganda esa 1 ta buyruq (`terraform destroy`) bilan butunlay o'chirilib, pul tejaladi.

---

### ❓ 4. Terraform orqali nimalarni boshqarsa bo'ladi?
> **Javob:**  
> Terraform deyarli **har qanday API'ga ega tizimni** boshqara oladi. Buning uchun **Provider** (provayderlar) mexanizmidan foydalanadi:
> - **Public Cloud:** AWS, Google Cloud (GCP), Microsoft Azure, DigitalOcean, Hetzner, Alibaba Cloud, Oracle Cloud va boshqalar.
> - **On-Premise va Virtualizatsiya:** VMware vSphere, Proxmox, OpenStack, Nutanix.
> - **Konteynerlar va Orchestration:** Docker, Kubernetes (K8s), Helm.
> - **SaaS va Xizmatlar:** Cloudflare (DNS/CDN), GitHub (repozitoriy va ruxsatlar), Datadog, New Relic, PagerDuty, GitLab.
> - **Lokal Tizimlar:** Hatto oddiy operatsion tizimdagi fayllar, kataloglar yoki buyruqlar (`local_file` provayderi orqali).

---

### ❓ 5. Buni ishlatish uchun nima talablar kerak?
> **Javob:**  
> Terraformni o'rganish va ishlatishni boshlash uchun katta resurs talab etilmaydi:
> - **Kompyuter/OS:** Windows, macOS yoki Linux (hatto oddiy ofis noutbuki ham yetadi).
> - **Terraform CLI:** HashiCorp rasmiy saytidan yuklab olinadigan kichik bitta binary fayl (o'lchami ~70-90 MB).
> - **Kod muharriri:** Visual Studio Code (tavsiya etiladi) va uning rasmiy **HashiCorp Terraform** kengaytmasi (syntax highlighting va autocomplete uchun).
> - **Terminal:** PowerShell, Bash yoki Zsh.
> - **Bulut hisobi (ixtiyoriy):** AWS, GCP yoki Azure akkaunti (lekin darslarning boshida cloud hisobsiz ham local rejimda bemalol o'rganish mumkin).

---

### ❓ 6. Local kompyuterda yoki online sinab ko'rsa bo'ladimi?
> **Javob:**  
> **Ha, mutlaqo!** Bulutli akkaunt (kredit karta) bo'lishi shart emas:
> - **Local kompyuterda sinash:**
>   - `local` provayderi orqali fayl va tizim resurslarini boshqarish.
>   - `docker` provayderi orqali kompyuterdagi Docker Engine bilan Nginx/Postgres konteynerlarini boshqarish.
>   - `LocalStack` orqali lokal ravishda soxta AWS muhitini ishga tushirib sinash.
> - **Online sinab ko'rish:**
>   - [Killercoda Terraform Interactive Scenarios](https://killercoda.com) (brauzerda bepul terminal va tayyor muhit).
>   - AWS Free Tier / GCP $300 bepul kreditlari orqali real bulutda sinash.

---

### ❓ 7. Necha foiz odam/kompaniyalar Terraform ishlatadi? (Bozor ulushi)
> **Javob:**  
> Terraform — bugungi kunda **IaC (Infrastructure as Code) bo'yicha dunyodagi mutlaq yetakchi (de-facto standart)** hisoblanadi:
> - Turli tadqiqotlar va so'rovnomalarga ko'ra (*HashiCorp State of Cloud Strategy*, *Datadog Cloud Report*, *Stack Overflow Developer Survey*), ko'p bulutli (multi-cloud) infratuzilmaga ega kompaniyalarning **70% dan 80% gacha** qismi aynan Terraformdan foydalanadi.
> - AWS o'zining *CloudFormation*, Azure esa *Bicep/ARM* vositasiga ega bo'lsa-da, kompaniyalar bitta bulutga bog'lanib qolmaslik (vendor lock-in) uchun deyarli har doim Terraformni tanlaydilar.
> - Har qanday zamonaviy DevOps / Cloud Engineer vakansiyalarining **85-90%ida** Terraform talab qilinadi.

---

### ❓ 8. Bu DevOps toolmi yoki Sysadminlarning qurolimi?
> **Javob:**  
> **Ikkalasiga ham tegishli**, ammo bugungi kunda bu **DevOps, SRE va Platform Engineering**ning ajralmas ustuni:
> - **Klassik Sysadmin** an'anaviy ravishda server ichidagi konfiguratsiyani (operatsion tizim, foydalanuvchilar, paketlar) boshqargan (masalan, Ansible, Bash yoki Puppet bilan).
> - **DevOps/Cloud Engineer** esa serverning o'zini, tarmoqni, VPC, Load Balancer va Cloud resurslarni kod sifatida yaratish uchun **Terraform**dan foydalanadi.
> - Hozirgi kunda zamonaviy Sysadminlar ham bulutli texnologiyalarga o'tayotgani sababli Terraform ularning ham birinchi darajali quroliga aylangan.

---

### ❓ 9. Pullikmi yoki tekinmi?
> **Javob:**  
> - **Terraform CLI (Core engine):** Mutlaqo **TEKIN (bepul)**. Har kim o'z kompyuterida yoki CI/CD serverida cheklovsiz ishlatishi mumkin.
> - **Litsenziyasi haqida (BSL vs OpenTofu):** 2023-yil avgust oyida HashiCorp o'z litsenziyasini MPL'dan BSL 1.1 ga o'zgartirdi (bu faqat HashiCorp bilan bevosita raqobatlashuvchi tijoriy bulut xizmatlariga taalluqli). Oddiy foydalanuvchilar va kompaniyalar uchun u baribir bepul qoladi. Shuningdek, to'liq ochiq kodli alternativa sifatida Linux Foundation ostida **OpenTofu** forki ham mavjud.
> - **Terraform Cloud / Enterprise:** HashiCorp shuningdek jamoaviy boshqaruv, GUI interfeys va qo'shimcha xavfsizlik funksiyalari uchun pullik SaaS xizmatlarini ham taklif qiladi (ammo boshlang'ich 500 ta resursgacha bo'lgan rejasi bepul).

---

### ❓ 10. Terraformning asosiy foydalari (Benefits) nimalardan iborat?
> **Javob:**  
> 1. **Platformalararo erkinlik (Multi-Cloud):** Bitta vosita va bitta sintaksis bilan AWS, Azure, Google Cloud, Docker va Kubernetesni boshqarish mumkin.
> 2. **Idempotentlik:** Kodni necha marta bajarmang (`terraform apply`), agar o'zgarish bo'lmasa, ortiqcha hech narsa yaratilmaydi va buzilmaydi.
> 3. **Ko'rib chiqish rejasi (`Execution Plan`):** `terraform plan` buyrug'i orqali o'zgarishlarni kiritishdan oldin: nima yaratilishi (+), nima o'zgarishi (~) va nima o'chirilishini (-) aniq ko'rish mumkin.
> 4. **State Management:** Terraform har bir resursning haqiqiy holatini `terraform.tfstate` faylida saqlaydi va nazorat qiladi.
> 5. **Modullilik (Terraform Modules):** Murakkab arxitekturalarni modullarga ajratib, kodni qayta-qayta ishlatish imkoniyati.
> 6. **Katta Hamjamiyat:** Terraform Registry'da dunyo bo'ylab minglab tayyor provayderlar va modullar mavjud.
