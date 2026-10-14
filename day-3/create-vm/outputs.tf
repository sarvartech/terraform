output "vm_id" {
  description = "Yaratilgan VM ning Proxmox ID raqami"
  value       = proxmox_vm_qemu.server.id
}

output "vm_nomi" {
  description = "Virtual mashina nomi"
  value       = proxmox_vm_qemu.server.name
}

output "vm_statik_ip" {
  description = "Biriktirilgan statik IP manzili"
  value       = split("/", var.vm_ip_cidr)[0]
}

output "ssh_ulanish_buyrug_i" {
  description = "SSH orqali to'g'ridan-to'g'ri ulanish buyrug'i"
  value       = "ssh ${var.ci_user}@${split("/", var.vm_ip_cidr)[0]}"
}