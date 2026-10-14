# --- Proxmox API sozlamalari ---
variable "proxmox_api_url" {
  description = "Proxmox API manzili (masalan: https://192.168.1.100:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (masalan: terraform@pve!terraform-token)"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret UUID"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "O'z-o'zidan imzolangan SSL sertifikatlarini qabul qilish"
  type        = bool
  default     = true
}

# --- VM sozlamalari ---
variable "target_node" {
  description = "VM joylashadigan Proxmox tuguni (node nomi)"
  type        = string
}

variable "template_name" {
  description = "Klon qilinadigan Ubuntu Cloud-Init template nomi"
  type        = string
}

variable "vm_name" {
  description = "Yaratiladigan virtual mashina nomi"
  type        = string
  default     = "srv-app-01"
}

variable "vm_id" {
  description = "VM ID raqami (0 qo'yilsa, avtomatik keyingi bo'sh ID olinadi)"
  type        = number
  default     = 0
}

variable "vm_cores" {
  description = "CPU yadrolari soni"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM hajmi (MB)"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Disk hajmi (masalan: 20G)"
  type        = string
  default     = "20G"
}

variable "storage_pool" {
  description = "VM diski saqlanadigan storage (local-lvm, ceph, zfs)"
  type        = string
  default     = "local-lvm"
}

# --- Tarmoq va Cloud-Init sozlamalari ---
variable "network_bridge" {
  description = "Tarmoq bridge interfeysi"
  type        = string
  default     = "wan_br"
}

variable "vm_ip_cidr" {
  description = "VM uchun statik IP va prefiks (masalan: 192.168.1.150/24)"
  type        = string
}

variable "vm_gateway" {
  description = "Standart shlyuz (Gateway)"
  type        = string
}

variable "vm_nameserver" {
  description = "DNS serverlari"
  type        = string
  default     = "1.1.1.1 8.8.8.8"
}

variable "ci_user" {
  description = "Standart foydalanuvchi nomi"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Serverga ulanish uchun SSH Public Key"
  type        = string
}