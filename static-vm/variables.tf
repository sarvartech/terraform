# ==============================================================================
# O'zgaruvchilar ta'rifi (variables.tf)
# ==============================================================================

variable "proxmox_api_url" {
  description = "Proxmox API URL manzili (masalan: https://192.168.100.2:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (masalan: terra-user@pam!terra-token)"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret (UUID formatida)"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Self-signed SSL sertifikat tekshiruvini o'chirish"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "VM joylashadigan Proxmox tuguni (Node) nomi"
  type        = string
  default     = "Winadmin"
}

variable "template_name" {
  description = "Klonlash uchun ishlatiladigan Cloud-Init shabloni nomi"
  type        = string
  default     = "ubuntu-tmp-24.04"
}

variable "vm_id" {
  description = "Virtual mashina ID raqami (0 bo'lsa Proxmox avtomatik keyingi bo'sh ID ni tanlaydi)"
  type        = number
  default     = 0
}

variable "vm_name" {
  description = "Yangi virtual mashina nomi"
  type        = string
  default     = "ubuntu-static-srv"
}

variable "vm_cores" {
  description = "Virtual protsessor (vCPU) yadrolari soni"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Operativ xotira (RAM) hajmi (MB)"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Asosiy disk hajmi (masalan: 20G, 32G)"
  type        = string
  default     = "32G"
}

variable "storage_pool" {
  description = "Disk va Cloud-init saqlanadigan xotira hovuzi (storage)"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Virtual tarmoq interfeysi ulanadigan ko'prik (bridge)"
  type        = string
  default     = "wan_br"
}

variable "vm_ip_cidr" {
  description = "Statik IP manzil va prefiks (masalan: 192.168.0.158/24)"
  type        = string
}

variable "vm_gateway" {
  description = "Standart tarmoq shlyuzi (Default Gateway)"
  type        = string
}

variable "vm_nameserver" {
  description = "DNS serverlar ro'yxati (bo'sh joy bilan ajratilgan)"
  type        = string
  default     = "1.1.1.1 8.8.8.8"
}

variable "ci_user" {
  description = "Cloud-Init yaratadigan standart sudo foydalanuvchi"
  type        = string
  default     = "ubuntu"
}

variable "ci_password" {
  description = "Foydalanuvchi paroli (ixtiyoriy, konsol orqali kirish uchun)"
  type        = string
  default     = "Ubuntu123!"
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Foydalanuvchi uchun ochiq SSH kaliti (id_rsa.pub yoki id_ed25519.pub)"
  type        = string
}
