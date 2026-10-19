# ==============================================================================
# Proxmox Statik IP va SSH bilan VM yaratish (main.tf)
# ==============================================================================

resource "proxmox_vm_qemu" "server" {
  name        = var.vm_name
  vmid        = var.vm_id != 0 ? var.vm_id : null
  target_node = var.target_node
  desc        = "Terraform orqali yaratilgan statik IP va SSH kalitli Ubuntu VM"

  # Shablon sozlamalari
  clone      = var.template_name
  full_clone = true

  # OS va CPU/Xotira
  os_type  = "cloud-init"
  cpu_type = "host"
  cores    = var.vm_cores
  sockets  = 1
  memory   = var.vm_memory
  scsihw   = "virtio-scsi-pci"
  boot     = "order=scsi0"
  onboot   = true

  # QEMU Guest Agent (IP manzilini ko'rish va tizim holatini bilish uchun)
  agent         = 1
  agent_timeout = 90

  # Disk sozlamalari: Asosiy SCSI disk va Cloud-Init IDE drayveri
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
    ide {
      ide2 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }
  }

  # Tarmoq interfeysi
  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Cloud-Init: Statik IP, DNS, Foydalanuvchi va SSH kalit
  ipconfig0  = "ip=${var.vm_ip_cidr},gw=${var.vm_gateway}"
  nameserver = var.vm_nameserver
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.ssh_public_key

  # Resurs yangilanganda MAC manzilni o'zgartirmaslik
  lifecycle {
    ignore_changes = [
      network[0].macaddr,
    ]
  }
}
