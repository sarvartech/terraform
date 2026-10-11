# Day 1: Amaliy Mashg'ulot (Hands-on Lab)

Ushbu amaliy mashg'ulotda biz Terraformni kompyuterimizga o'rnatamiz va birinchi infratuzilma kodimizni (`main.tf`) ishga tushirib, Terraformning 4 ta oltin buyrug'ini amalda sinab ko'ramiz.

> [!NOTE]
> Ushbu lab uchun AWS yoki GCP hisobi shart emas. Mashg'ulot to'liq lokal kompyuterda `local` provayderi orqali bajariladi.

---

## 🚀 1-qadam: Terraformni o'rnatish

O'z operatsion tizimingizga qarab quyidagi usullardan birini tanlang:

### Windows:
PowerShell (Administrator) orqali:
```powershell
winget install Hashicorp.Terraform
```
*yoki Chocolatey orqali:*
```powershell
choco install terraform
```
*yoki qo'lda:* [developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install) saytidan zip arxivini yuklab olib, `PATH` o'zgaruvchisiga qo'shing.

### macOS:
Terminal orqali (Homebrew):
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux (Ubuntu/Debian):
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

---

## 🔍 2-qadam: O'rnatilganini tekshirish

Terminalda quyidagi buyruqni bering:
```bash
terraform version
```
Agar `Terraform v1.x.x` ko'rinishidagi javob chiqsa, demak hammasi to'g'ri o'rnatilgan.

---

## 🛠 3-qadam: Amaliyotni boshlash

Lab katalogiga o'ting:
```bash
cd day-1/lab
```

Katalogda [main.tf](file:///c:/Users/user/Documents/terraform/day-1/lab/main.tf) fayli mavjud. Uning ichida nima yozilganini ko'zdan kechiring.

---

## 📋 4-qadam: 4 ta oltin buyruqni bajarish

### 1. `terraform init` (Initsializatsiya)
Ushbu buyruq kodda ko'rsatilgan provayderlarni (bizning holatda `hashicorp/local`) Terraform Registry'dan yuklab oladi va `.terraform` papkasini shakllantiradi:
```bash
terraform init
```
Natijada `Terraform has been successfully initialized!` xabarini ko'rasiz.

---

### 2. `terraform plan` (Reja tuzish)
Ushbu buyruq hech narsani o'zgartirmasdan, faqat qanday o'zgarishlar kiritilishi rejalashtirilayotganini ko'rsatadi:
```bash
terraform plan
```
Terminalda yashil rangda `+ resource "local_file" "welcome_message"` (1 to add, 0 to change, 0 to destroy) degan yozuv chiqadi.

---

### 3. `terraform apply` (Rejani hayotga tatbiq etish)
Haqiqiy resursni yaratish buyrug'i:
```bash
terraform apply
```
Terraform sizdan tasdiqlashni so'raydi (`Do you want to perform these actions?`).  
Terminalga `yes` deb yozing va Enter bosing.

🎉 **Natija:**
1. Katalogda `salom_terraform.txt` fayli avtomatik paydo bo'ladi.
2. `terraform.tfstate` fayli hosil bo'ladi — bu Terraformning "xotirasi" bo'lib, yaratilgan resurslar haqidagi ma'lumotlarni saqlaydi.

---

### 4. Sinov: "Configuration Drift"ni his qilish
Endi o'sha yaratilgan `salom_terraform.txt` faylini kompyuteringizdan qo'lda o'chirib tashlang (Delete).  
So'ngra yana quyidagi buyruqni bering:
```bash
terraform plan
```
Terraform darhol fayl yo'qolganini payqaydi va uni qayta yaratish kerakligini aytadi! Qayta tiklash uchun:
```bash
terraform apply -auto-approve
```
Fayl darhol yana paydo bo'ladi. Bu Terraformning eng kuchli xususiyatlaridan biridir!

---

### 5. `terraform destroy` (Resurslarni yo'q qilish)
Ish tugagach yoki tajriba yakunlangach, yaratilgan barcha narsalarni tozalash:
```bash
terraform destroy
```
Yana `yes` deb tasdiqlang. `salom_terraform.txt` fayli toza o'chiriladi.

---

## 🎯 Mustaqil Topshiriq (Homework)
[main.tf](file:///c:/Users/user/Documents/terraform/day-1/lab/main.tf) fayliga yana bitta `local_file` resursi qo'shing:
- Fayl nomi: `server_info.json`
- Ichidagi matn: JSON formatida server konfiguratsiyasi (masalan: `{"cpu": 2, "ram": "4GB", "env": "dev"}`)
- `terraform apply` qilib natijani tekshiring va keyin `terraform destroy` qiling.
