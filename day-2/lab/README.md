# Day 2: Sintaksis & Terminlar Laboratoriyasi (Lab 02)

Bugungi laboratoriya murakkab bulut loyihasi emas, balki nazariyada o'rganilgan barcha **asosiy terminlar** (`variable`, `local`, `resource`, `output`, `provider`) kodda bir-biri bilan qanday bog'lanishini amalda ko'rish uchun mo'ljallangan "Sintaksis laboratoriyasi"dir.

---

## 📁 1-Qadam: Fayllar tuzilishi bilan tanishish

Lab papkasida 3 ta asosiy fayl yaratilgan:
- [variables.tf](file:///c:/Users/user/Documents/terraform/day-2/lab/variables.tf) — Tashqaridan kiruvchi parametrlar (`variable`)
- [main.tf](file:///c:/Users/user/Documents/terraform/day-2/lab/main.tf) — Asosiy mantiq: `provider`, `locals` va `resource`
- [outputs.tf](file:///c:/Users/user/Documents/terraform/day-2/lab/outputs.tf) — Natijani chiqarish (`output`)

> 💡 **DevOps Best Practice:**  
> Terraform bitta papka ichidagi barcha `.tf` kengaytmali fayllarni bitta umumiy kod deb qabul qiladi. Kodlarni `main.tf`, `variables.tf` va `outputs.tf` kabi mantiqiy alohida fayllarga ajratish — jahon standartidir.

---

## 🛠 2-Qadam: Har bir DevOps bilishi shart bo'lgan 2 ta yordamchi buyruq

Lab papkasiga o'ting:
```bash
cd day-2/lab
```

### 1. `terraform fmt` (Kodni formatlash)
Kodingizdagi bo'shliqlar, qatorlar va barobarliklarni HashiCorp standartiga moslab, chiroyli qilib tekislab beradi:
```bash
terraform fmt
```

### 2. `terraform validate` (Sintaksisni tekshirish)
Kodni ishga tushirmasdan turib, unda sintaktik xato, noto'g'ri nomlangan o'zgaruvchi yoki yetishmayotgan qavslar bor-yo'qligini tekshiradi:
Avval initsializatsiya qilamiz:
```bash
terraform init
```
So'ngra tekshiramiz:
```bash
terraform validate
```
Agar hammasi to'g'ri bo'lsa: `Success! The configuration is valid.` deb chiqadi.

---

## 🚀 3-Qadam: Terminlar zanjirini sinab ko'rish

Kodni ishga tushiring:
```bash
terraform apply -auto-approve
```

Terminaldagi natijaga e'tibor bering:
1. **Outputlar** ekranda ko'rinadi (`dars_ma_lumoti` va `yaratilgan_fayl_nomi`).
2. Katalogda `terminlar_xulosasi.txt` nomli yangi fayl paydo bo'ladi.
3. Fayl ichini ochib qarang: kiritilgan `variable`lar `local` orqali matnga aylanib, `resource` orqali faylga yozilgan!

---

## ⚡ 4-Qadam: O'zgaruvchilar (Variables) qudratini his qilish

Kodimiz ichidagi faylni tahrirlamasdan turib, konsol orqali boshqa ism berib ko'ramiz:
```bash
terraform apply -var="talaba_ismi=Sardor" -auto-approve
```
Endi `terminlar_xulosasi.txt` faylini qayta ochib ko'ring:
*"Hurmatli: Sardor!"* deb avtomatik o'zgarganini ko'rasiz! Mana bu **Input Variables**ning amaliy kuchi.

---

## 🧹 5-Qadam: Tozalash
Mashg'ulot yakunlangach, laboratoriyani tozalab qo'yamiz:
```bash
terraform destroy -auto-approve
```

---

## 🎯 Talabalar uchun savollar (O'z-o'zini tekshirish):
1. `variable` va `local` o'rtasidagi asosiy farq nima?
2. Nima uchun kodlarni `main.tf`, `variables.tf`, `outputs.tf` ga bo'lib yozamiz?
3. `terraform fmt` va `terraform validate` buyruqlari nima vazifani bajaradi?
