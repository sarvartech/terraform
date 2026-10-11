# ==============================================================================
# Proxmox Chiqish Qiymatlari (outputs.tf)
# ==============================================================================

output "vm_nomi" {
  description = "Yaratilgan virtual mashina nomi"
  value       = proxmox_vm_qemu.server.name
}

output "vm_id" {
  description = "Proxmoxdagi VM ID raqami"
  value       = proxmox_vm_qemu.server.id
}

output "ssh_ulanish_buyrug_i" {
  description = "Serverga SSH orqali ulanish namunasi"
  value       = "ssh ${var.ci_user}@<VM_IP_MANZILI>"
}
