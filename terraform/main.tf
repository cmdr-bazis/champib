locals {
  bucket_name = "www.comp6.hackatom.ru"
}

resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "tf-test-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = local.bucket_name
}

resource "yandex_compute_instance" "example_vm" {
  name         = var.vm_name
  zone         = var.yandex_zone
  resources {
    cores  = 1
    memory = 1024
  }
  boot_disk {
    initialize_params {
      image_id = "fd8d7b00-4393-4f87-8369-9edb1c67d5e2" # Debian 11
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.example_subnet.id
  }
  metadata = {
    user-data = <<-EOF
                #!/bin/bash
                useradd -m -s /bin/bash ansible
                echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
                mkdir /home/ansible/.ssh
                echo "SSH_PUBLIC_KEY" > /home/ansible/.ssh/authorized_keys
                chown -R ansible:ansible /home/ansible/.ssh
                chmod 700 /home/ansible/.ssh
                chmod 600 /home/ansible/.ssh/authorized_keys
                EOF
  }
}
