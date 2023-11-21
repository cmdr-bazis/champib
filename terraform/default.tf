terraform {  
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.102.0"
    }
  }
}

locals {
   folder_id = "b1gone6i3v8dcn7gkptc"
   cloud_id = "b1gtrb1pnt0mnhlbb7nc"
}

provider "yandex" {
  folder_id = local.cloud_id
  cloud_id = local.cloud_id
  service_account_key_file = "/home/kali/champ-ib/authorized_key.json"
}

