# ==============================================================================
# Proxmox O'zgaruvchilari (variables.tf)
# ==============================================================================

# --- Proxmox Ulanish Sozlamalari ---

variable "proxmox_api_url" {
  description = "Proxmox API manzili (https://<IP>:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (masalan: terraform-user@pve!token-name)"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Maxfiy Kaliti (UUID)"
  type        = string
  sensitive   = true
}

variable "target_node" {
  description = "VM yaratilishi kerak bo'lgan Proxmox Node nomi"
  type        = string
  default     = "Winadmin"
}

# --- Virtual Mashina Sozlamalari ---

variable "template_name" {
  description = "Klonlanadigan Cloud-Init shablonining nomi"
  type        = string
  default     = "ubuntu-2204-cloudinit-template"
}

variable "vm_name" {
  description = "Yaratiladigan VM nomi"
  type        = string
  default     = "terraform-ubuntu-vm"
}

variable "vm_cores" {
  description = "CPU yadrolar soni"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM hajmi (Megabaytda)"
  type        = number
  default     = 2048 # 2 GB
}

variable "vm_disk_size" {
  description = "Asosiy disk hajmi"
  type        = string
  default     = "20G"
}

variable "storage_pool" {
  description = "Disk saqlanadigan Proxmox storage nomi (local-lvm yoki local-zfs)"
  type        = string
  default     = "local-lvm"
}

# --- Cloud-Init & Tarmoq Sozlamalari ---

variable "ssh_public_key" {
  description = "VM ichiga yuklanadigan ochiq SSH kalit (ssh-rsa AAAA...)"
  type        = string
  default     = ""
}

variable "ci_user" {
  description = "Cloud-Init tomonidan yaratiladigan standart foydalanuvchi"
  type        = string
  default     = "ubuntu"
}
