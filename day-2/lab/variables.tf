# ==============================================================================
# 1. VARIABLE (Input Variables) Namunasi
# ==============================================================================
# Ushbu faylda tashqaridan kiritiladigan parametrlarni e'lon qilamiz.
# ==============================================================================

variable "kurs_nomi" {
  description = "O'rganilayotgan kurs nomi"
  type        = string
  default     = "Terraform IaC Darslari"
}

variable "talaba_ismi" {
  description = "Talabaning ismi"
  type        = string
  default     = "Kelajakdagi DevOps Engineer"
}

variable "dars_raqami" {
  description = "Bugungi dars raqami"
  type        = number
  default     = 2
}
