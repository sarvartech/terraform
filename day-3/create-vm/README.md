# Day 3: Proxmoxda Virtual Mashina Klonlash (Stream Lab)

Ushbu amaliy loyihada Proxmoxda oldindan yaratilgan Cloud-Init shablonidan (`ubuntu-2404-base` yoki `ubuntu-2404-custom-template`) foydalanib, Terraform orqali yangi to'liq virtual mashina ishga tushiriladi.

---

## 📋 Dastlabki Talablar

1. Proxmox serveringizda Cloud-Init shabloni mavjud bo'lishi kerak:
   - [Lab 03-A: Minimal Template Yaratish (ID: 9000)](../lab/01-cloud-init-minimal-template.md)
   - [Lab 03-B: Custom Template Yaratish (ID: 9100)](../lab/02-cloud-init-custom-template.md)
2. Proxmox API Token (`root@pam!terraform-token` yoki shaxsiy foydalanuvchi tokeni).
3. SSH ochiq kalitingiz (`id_rsa.pub`).

---

## ⚙️ Sozlash va Ishga Tushirish

1. Ushbu jildga o'ting:
   ```bash
   cd day-3/create-vm
   ```

2. `terraform.tfvars` faylidagi parametrlarni o'z serveringizga moslang:
   ```hcl
   proxmox_api_url          = "https://<PROXMOX_IP>:8006/api2/json"
   proxmox_api_token_id     = "root@pam!terraform-token"
   proxmox_api_token_secret = "your-api-secret-uuid"
   target_node              = "pve"
   template_name            = "ubuntu-2404-custom-template" # yoki "ubuntu-2404-base"
   vm_name                  = "srv-app-01"
   vm_ip_cidr               = "192.168.1.150/24"
   vm_gateway               = "192.168.1.1"
   ssh_public_key           = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."
   ```

3. Terraform buyruqlarini bajaring:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Natijani tekshiring:
   ```bash
   ssh ubuntu@192.168.1.150
   ```
