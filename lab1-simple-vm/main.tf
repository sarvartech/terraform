resource "proxmox_vm_qemu" "test_vm" {
  name        = "tf-test-vm1"
  target_node = "Winadmin"
  clone       = "ubuntu-2404-tpl"

  cores   = 2
  memory  = 2048
  sockets = 1

  full_clone = true
  agent      = 1

  scsihw = "virtio-scsi-single"

  disks {
    scsi {
      scsi0 {
        disk {
          storage  = "nvme-256"
          size     = "20G"
          iothread = true
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "wan_br"
  }
}