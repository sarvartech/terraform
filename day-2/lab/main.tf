# ==============================================================================
# Day 2: Terminlar Birlashmasi (main.tf)
# ==============================================================================
# Ushbu fayl amaliy loyiha emas, balki Day 2 darsida o'rganilgan barcha
# asosiy terminlarning kodda qanday uchrashishini ko'rsatuvchi namunadir.
# ==============================================================================

# 1. TERRAFORM CONFIGURATION BLOKI
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# 2. PROVIDER (Provayder) BLOKI
provider "local" {
  # Local provayder uchun qo'shimcha parametrlar talab qilinmaydi
}

# 3. LOCALS (Ichki hisoblangan qiymatlar) BLOKI
locals {
  # Variable'larni birlashtirib, bitta to'liq sarlavha hosil qilamiz:
  dars_sarlavhasi = "${var.kurs_nomi} - Day ${var.dars_raqami}"

  fayl_matni = <<-EOT
    ================================================
    ${local.dars_sarlavhasi}
    ================================================
    Hurmatli: ${var.talaba_ismi}!
    
    Bugun biz quyidagi terminlarni o'rgandik:
      1. Provider
      2. Resource
      3. Data Source
      4. Variables
      5. Outputs
      6. Locals
      7. State
      8. Module
      9. Backend
      10. Provisioner

    Ushbu fayl Terraformning "Resource + Local + Variable"
    zanjiri orqali avtomatik hosil qilindi.
    ================================================
  EOT
}

# 4. RESOURCE (Infratuzilma g'ishti) BLOKI
resource "local_file" "terminlar_konspekti" {
  filename = "${path.module}/terminlar_xulosasi.txt"
  content  = local.fayl_matni
}
