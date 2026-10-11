# ==============================================================================
# Day 1: Birinchi Terraform Kodingiz (Local Provider)
# ==============================================================================
# Ushbu kod bulut hisobi (AWS/Azure) talab qilmaydi.
# U sizning kompyuteringizda avtomatik matnli fayl yaratadi va
# Terraformning asosiy 4 ta buyrug'ini tushunishga yordam beradi:
#   1. terraform init
#   2. terraform plan
#   3. terraform apply
#   4. terraform destroy
# ==============================================================================

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Resurs: lokal fayl yaratish
resource "local_file" "welcome_message" {
  filename = "${path.module}/salom_terraform.txt"
  content  = "Assalomu alaykum! Bu Terraform orqali yaratilgan birinchi resurs.\nKuni: Day 1 - Kirish darsi.\nMuallif: DevOps Engineer\n"
}

# Chiqish qiymati (Output) - natijani terminalda ko'rsatish
output "fayl_yo_li" {
  description = "Yaratilgan faylning to'liq yo'li"
  value       = local_file.welcome_message.filename
}
