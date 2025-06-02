terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  insecure  = true
  api_token = var.proxmox_apikey
  ssh {
    agent = true
  }
}

resource "proxmox_virtual_environment_vm" "k3s_node0" {
  count     = 1
  name      = "k3s-preprod"
  node_name = "pr1"

  vm_id = 1101
  clone {
    vm_id = var.template_id_node0
    full  = true
  }

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  scsi_hardware = "virtio-scsi-pci"
  boot_order    = ["scsi0"]

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    vendor_data_file_id = "local:snippets/vendor.yaml"
    datastore_id        = var.storage_pool
    interface           = "scsi1"
    ip_config {
      ipv4 {
        address = "10.1.1.99/24" # Manual IP
        gateway = "10.1.1.1"
      }
    }
    user_account {
      username = "alvaro"
    }
  }

  agent {
    enabled = true
  }
}

  initialization {
    vendor_data_file_id = "local:snippets/vendor.yaml"
    datastore_id        = var.storage_pool
    interface           = "scsi1"
    ip_config {
      ipv4 {
        address = "10.1.1.99/24" # Manual IP
        gateway = "10.1.1.1"
      }
    }
    user_account {
      username = "alvaro"
    }
  }

  agent {
    enabled = true
  }
}
