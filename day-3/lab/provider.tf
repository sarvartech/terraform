# ==============================================================================
# Proxmox Provider Konfiguratsiyasi (provider.tf)
# ==============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6" # Eng barqaror va ommabop versiya
    }
  }
}

provider "proxmox" {
  # Proxmox VE serverining API URL manzili (masalan: https://192.168.1.100:8006/api2/json)
  pm_api_url = var.proxmox_api_url

  # API Token ma'lumotlari (Xavfsiz usul)
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  # O'z-o'zidan imzolangan (Self-signed) SSL sertifikatlar uchun tekshiruvni o'chirish
  pm_tls_insecure = true

  # Parallel bajariladigan amallar soni
  pm_parallel = 2
}
