# ==============================================================================
# Proxmox Virtual Mashinasi (main.tf)
# ==============================================================================
# Ushbu kod Cloud-Init andozasidan (Template) yangi to'liq virtual mashina
# yaratadi va unga tarmoq hamda SSH sozlamalarini avtomatlashtiradi.
# ==============================================================================

resource "proxmox_vm_qemu" "server" {
  name        = var.vm_name
  target_node = var.target_node
  desc        = "Terraform orqali yaratilgan avtomatik server"

  # Cloud-Init shablonidan klonlash sozlamalari
  clone      = var.template_name
  full_clone = true

  # Virtual apparat (Hardware) resurslari
  cores   = var.vm_cores
  sockets = 1
  cpu     = "host"
  memory  = var.vm_memory

  # QEMU Guest Agent (Proxmox GUI'da VM IP manzilini ko'rsatish uchun)
  agent = 1

  # Disk sozlamalari
  scsihw = "virtio-scsi-pci"
  boot   = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.vm_disk_size
          storage = var.storage_pool
        }
      }
    }
  }

  # Tarmoq interfeysi
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Cloud-Init sozlamalari (OS sozlash)
  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp" # DHCP orqali avtomatik IP oladi

  ciuser  = var.ci_user
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # VM yaratilgach avtomatik ishga tushishi
  onboot = true
}
