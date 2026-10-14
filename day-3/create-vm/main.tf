resource "proxmox_vm_qemu" "server" {
  name        = var.vm_name
  vmid        = var.vm_id != 0 ? var.vm_id : null
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true

  # Tizim va CPU
  os_type  = "cloud-init"
  cpu_type = "host"
  cores    = var.vm_cores
  sockets  = 1
  memory   = var.vm_memory
  scsihw   = "virtio-scsi-pci"
  boot     = "order=scsi0"
  onboot   = true

  # QEMU Guest Agent
  agent         = 1
  agent_timeout = 90

  # Asosiy disk
  disks {
    scsi {
      scsi0 {
        disk {
          size      = var.vm_disk_size
          storage   = var.storage_pool
          replicate = false
        }
      }
    }
  }

  # Tarmoq
  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Cloud-Init sozlamalari (Statik IP va SSH)
  ipconfig0  = "ip=${var.vm_ip_cidr},gw=${var.vm_gateway}"
  nameserver = var.vm_nameserver
  ciuser     = var.ci_user
  sshkeys    = var.ssh_public_key

  # Resurs o'zgarganda disk va networkni qayta yozish bo'yicha lifecycle qoidalari
  lifecycle {
    ignore_changes = [
      network[0].macaddr,
    ]
  }
}