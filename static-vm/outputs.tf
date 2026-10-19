# ==============================================================================
# Chiqish qiymatlari (outputs.tf)
# ==============================================================================

output "vm_id" {
  description = "Yaratilgan virtual mashinaning Proxmoxdagi ID raqami"
  value       = proxmox_vm_qemu.server.id
}

output "vm_name" {
  description = "Virtual mashina nomi"
  value       = proxmox_vm_qemu.server.name
}

output "vm_static_ip" {
  description = "VM ga biriktirilgan statik IP manzil"
  value       = split("/", var.vm_ip_cidr)[0]
}

output "ssh_command" {
  description = "Virtual mashinaga SSH orqali ulanish buyrug'i"
  value       = "ssh ${var.ci_user}@${split("/", var.vm_ip_cidr)[0]}"
}
