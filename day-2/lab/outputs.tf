# ==============================================================================
# 5. OUTPUT (Chiqish Qiymatlari) Namunasi
# ==============================================================================
# Terraform yaratgan resurs natijalarini ekranga chiqarish.
# ==============================================================================

output "yaratilgan_fayl_nomi" {
  description = "Yaratilgan faylning to'liq manzili"
  value       = local_file.terminlar_konspekti.filename
}

output "dars_ma_lumoti" {
  description = "Local blokidan olingan dars sarlavhasi"
  value       = local.dars_sarlavhasi
}
